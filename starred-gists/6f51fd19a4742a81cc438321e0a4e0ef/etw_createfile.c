// this code will work only when compiled as 64-bit code, and on Windows 10
// older Windows version might require different structure definitions

#define NOMINMAX
#define INITGUID
#include <windows.h>
#include <evntrace.h>
#include <evntcons.h>

#pragma comment (lib, "shell32.lib")
#pragma comment (lib, "advapi32.lib")

#include <stdio.h>
#include <stdint.h>
#include <string.h>

// https://docs.microsoft.com/en-us/windows/win32/etw/nt-kernel-logger-constants
// http://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/etw/callouts/hookid.htm
static const GUID FileIoGuid = { 0x90cbdc39, 0x4a3e, 0x11d1, { 0x84, 0xf4, 0x00, 0x00, 0xf8, 0x04, 0x64, 0xe3 } };
static const GUID PerfInfoGuid = { 0xce1dbfb4, 0x137e, 0x4da6, { 0x87, 0xb0, 0x3f, 0x59, 0xaa, 0x10, 0x2c, 0xbc } };

// structures from "C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\km\wmicore.mof" (in Windows DDK)
struct FileIo_Create
{
    uint64_t IrpPtr;
    uint64_t FileObject;
    uint32_t TTID;
    uint32_t CreateOptions;
    uint32_t FileAttributes;
    uint32_t ShareAccess;
    wchar_t OpenPath[];
};

// check if current process is elevated
static BOOL IsElevated(void)
{
    BOOL result = FALSE;

    HANDLE token;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token))
    {
        TOKEN_ELEVATION elevation;
        DWORD size;
        if (GetTokenInformation(token, TokenElevation, &elevation, sizeof(elevation), &size))
        {
            result = elevation.TokenIsElevated;
        }
        CloseHandle(token);
    }

    return result;
}

// enables profiling privilege
static BOOL EnableProfilePrivilge(void)
{
    BOOL result = FALSE;

    HANDLE token;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &token))
    {
        LUID luid;
        if (LookupPrivilegeValueA(NULL, SE_SYSTEM_PROFILE_NAME, &luid))
        {
            TOKEN_PRIVILEGES tp =
            {
                .PrivilegeCount = 1,
                .Privileges[0].Luid = luid,
                .Privileges[0].Attributes = SE_PRIVILEGE_ENABLED,
            };
            if (AdjustTokenPrivileges(token, FALSE, &tp, sizeof(tp), NULL, NULL))
            {
                result = TRUE;
            }
        }
        CloseHandle(token);
    }

    return result;
}

struct
{
    EVENT_TRACE_PROPERTIES Properties;
    WCHAR SessionName[1024];
}
static gTrace;

static TRACEHANDLE gTraceHandle;
static HANDLE gTraceThread;
static DWORD gProcessFilter;

static void WINAPI TraceEventRecordCallback(EVENT_RECORD* event)
{
    DWORD pid = event->EventHeader.ProcessId;

    GUID* provider = &event->EventHeader.ProviderId;
    UCHAR opcode = event->EventHeader.EventDescriptor.Opcode;

    if (pid == gProcessFilter)
    {
        if (IsEqualGUID(provider, &FileIoGuid))
        {
            if (opcode == 0x40) // (byte)PERFINFO_LOG_TYPE_FILE_IO_CREATE
            {
                struct FileIo_Create* data = event->UserData;
                printf("%S\n", data->OpenPath);
            }
        }
    }
};

static DWORD WINAPI TraceProcessThread(LPVOID arg)
{
    ProcessTrace(&gTraceHandle, 1, NULL, NULL);
    return 0;
}

static BOOL StartTraceSession()
{
    SYSTEM_INFO sysinfo;
    GetSystemInfo(&sysinfo);

    EVENT_TRACE_PROPERTIES* p = &gTrace.Properties;

    // stop existing trace, in case it is running
    ZeroMemory(p, sizeof(*p));
    p->Wnode.BufferSize = sizeof(gTrace);
    p->Wnode.Guid = SystemTraceControlGuid;
    p->LogFileMode = EVENT_TRACE_REAL_TIME_MODE;
    p->LoggerNameOffset = sizeof(gTrace.Properties);
    ControlTraceW(0, KERNEL_LOGGER_NAMEW, p, EVENT_TRACE_CONTROL_STOP);

    // setup trace properties
    ZeroMemory(p, sizeof(*p));
    p->Wnode.BufferSize = sizeof(gTrace);
    p->Wnode.Guid = SystemTraceControlGuid;
    p->Wnode.ClientContext = 1;
    p->Wnode.Flags = WNODE_FLAG_TRACED_GUID;
    p->BufferSize = 1024; // 1MiB
    p->MinimumBuffers = 2 * sysinfo.dwNumberOfProcessors;
    p->MaximumBuffers = p->MinimumBuffers + 20;
    p->LogFileMode = EVENT_TRACE_REAL_TIME_MODE | EVENT_TRACE_SYSTEM_LOGGER_MODE;
    p->LoggerNameOffset = sizeof(gTrace.Properties);
    p->FlushTimer = 1;
    p->EnableFlags = EVENT_TRACE_FLAG_FILE_IO_INIT;

    // start the trace
    TRACEHANDLE session;
    if (StartTraceW(&session, KERNEL_LOGGER_NAMEW, p) != ERROR_SUCCESS)
    {
        return FALSE;
    }

    EVENT_TRACE_LOGFILEW logfile =
    {
        .LoggerName = KERNEL_LOGGER_NAMEW,
        .ProcessTraceMode = PROCESS_TRACE_MODE_EVENT_RECORD | PROCESS_TRACE_MODE_RAW_TIMESTAMP | PROCESS_TRACE_MODE_REAL_TIME,
        .EventRecordCallback = TraceEventRecordCallback,
    };

    // open trace for processing
    gTraceHandle = OpenTraceW(&logfile);
    if (gTraceHandle == INVALID_PROCESSTRACE_HANDLE)
    {
        ControlTraceW(0, KERNEL_LOGGER_NAMEW, p, EVENT_TRACE_CONTROL_STOP);
        return FALSE;
    }

    // start processing in background thread
    gTraceThread = CreateThread(NULL, 0, TraceProcessThread, NULL, 0, NULL);
    if (gTraceThread == NULL)
    {
        ControlTraceW(0, KERNEL_LOGGER_NAMEW, p, EVENT_TRACE_CONTROL_STOP);
        CloseTrace(gTraceHandle);
        return FALSE;
    }

    return TRUE;
}

static void StopTraceSession(void)
{
    // stop the trace
    ControlTraceW(0, KERNEL_LOGGER_NAMEW, &gTrace.Properties, EVENT_TRACE_CONTROL_STOP);

    // close processing loop, this will wait until all pending buffers are flushed
    // and TraceEventRecordCallback called on all pending events in buffers
    CloseTrace(gTraceHandle);

    // wait for processing thread to finish
    WaitForSingleObject(gTraceThread, INFINITE);
}

int main()
{
    if (!IsElevated())
    {
        fprintf(stderr, "Using ETW with NT kernel logger requires elevated process!\n");
        exit(EXIT_FAILURE);
    }

    if (!EnableProfilePrivilge())
    {
        fprintf(stderr, "Cannot enable profiling privilege for process!\n");
        exit(EXIT_FAILURE);
    }

    if (!StartTraceSession())
    {
        fprintf(stderr, "Cannot start ETW session for NT kernel logger!\n");
        exit(EXIT_FAILURE);
    }

    int argc;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);

    STARTUPINFOW si =
    {
        .cb = sizeof(si),
    };
    PROCESS_INFORMATION pi;
    if (!CreateProcessW(NULL, argv[1], NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &si, &pi))
    {
        fprintf(stderr, "Cannot create process!\n");
    }
    else
    {
        gProcessFilter = pi.dwProcessId;
        ResumeThread(pi.hThread);

        printf("Running...\n");
        WaitForSingleObject(pi.hProcess, INFINITE);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    }

    LocalFree(argv);

    printf("Stopping...\n");
    StopTraceSession();

    printf("Done!\n");
}
