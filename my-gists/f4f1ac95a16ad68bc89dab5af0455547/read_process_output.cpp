// make sure hook.dll (compiled from hook.c) exists in current folder

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <intrin.h>

#define Assert(cond) do { if (!(cond)) __debugbreak(); } while (0)

static void CreateNamedPipePair(
    HANDLE* read,
    HANDLE* write,
    DWORD bufferSize,
    SECURITY_ATTRIBUTES* sattr)
{
    static DWORD id = 0;

    char name[MAX_PATH];
    wsprintfA(name, "\\\\.\\Pipe\\WhateverUniqueName.%08x.%08x", GetCurrentProcessId(), id++);

    *read = CreateNamedPipeA(
        name,
        PIPE_ACCESS_INBOUND | FILE_FLAG_OVERLAPPED,
        PIPE_TYPE_BYTE | PIPE_WAIT,
        1,
        bufferSize,
        bufferSize,
        0,
        sattr);
    Assert(*read != INVALID_HANDLE_VALUE);

    *write = CreateFileA(
        name,
        GENERIC_WRITE,
        0,
        sattr,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL | FILE_FLAG_OVERLAPPED,
        NULL);
    Assert(*write != INVALID_HANDLE_VALUE);
}

int main(int argc, char* argv[])
{
    if (argc > 1)
    {
        // client
        DWORD written;

        WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), "stdout_console", 14, &written, NULL);
        Sleep(1000);
        WriteConsole(GetStdHandle(STD_ERROR_HANDLE), "stderr_console", 14, &written, NULL);
        Sleep(1000);

        WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), "stdout", 6, &written, NULL);
        Sleep(1000);
        WriteFile(GetStdHandle(STD_ERROR_HANDLE), "stderr", 6, &written, NULL);
        Sleep(1000);

        return 0;
    }

    enum { BUFFER_SIZE = 4 * 1024 };

    BOOL ok;

    SECURITY_ATTRIBUTES sattr = {};
    sattr.nLength = sizeof(sattr);
    sattr.bInheritHandle = TRUE;

    HANDLE inRpipe, inWpipe;
    CreateNamedPipePair(&inRpipe, &inWpipe, BUFFER_SIZE, &sattr);

    HANDLE outRpipe, outWpipe;
    CreateNamedPipePair(&outRpipe, &outWpipe, BUFFER_SIZE, &sattr);

    HANDLE errRpipe, errWpipe;
    CreateNamedPipePair(&errRpipe, &errWpipe, BUFFER_SIZE, &sattr);

    STARTUPINFOA sinfo = {};
    sinfo.cb = sizeof(sinfo);
    sinfo.dwFlags = STARTF_USESTDHANDLES;
    sinfo.hStdInput = inRpipe;
    sinfo.hStdOutput = outWpipe;
    sinfo.hStdError = errWpipe;

    char cmdline[1024];
    wsprintfA(cmdline, "%s client", argv[0]);

    PROCESS_INFORMATION pinfo;
    ok = CreateProcessA(argv[0], cmdline, NULL, NULL, TRUE, CREATE_NO_WINDOW | CREATE_SUSPENDED, NULL, NULL, &sinfo, &pinfo);
    Assert(ok);

    // load "hook.dll" into target process
    {
        LPVOID addr = VirtualAllocEx(pinfo.hProcess, NULL, 4096, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
        Assert(addr);

        const char dll[] = "hook.dll";
        ok = WriteProcessMemory(pinfo.hProcess, addr, dll, sizeof(dll), NULL);
        Assert(addr);

        HMODULE kernel32 = GetModuleHandleA("kernel32.dll");
        Assert(kernel32);

        FARPROC loadLibA = GetProcAddress(kernel32, "LoadLibraryA");
        Assert(loadLibA);

        HANDLE remote = CreateRemoteThread(pinfo.hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)loadLibA, addr, 0, NULL);
        Assert(remote);

        WaitForSingleObject(remote, INFINITE);
        CloseHandle(remote);

        VirtualFreeEx(pinfo.hProcess, addr, 4096, MEM_RELEASE);
    }

    DWORD resume = ResumeThread(pinfo.hThread);
    Assert(resume >= 0);

    CloseHandle(pinfo.hThread);
    CloseHandle(inRpipe);
    CloseHandle(inWpipe);
    CloseHandle(outWpipe);
    CloseHandle(errWpipe);

    HANDLE outEvent = CreateEvent(NULL, TRUE, TRUE, NULL);
    Assert(outEvent);

    HANDLE errEvent = CreateEvent(NULL, TRUE, TRUE, NULL);
    Assert(errEvent);

    char outTemp[BUFFER_SIZE];
    char errTemp[BUFFER_SIZE];

    OVERLAPPED outO = {};
    OVERLAPPED errO = {};

    HANDLE handles[] = { outEvent, errEvent, pinfo.hProcess };
    DWORD count = _countof(handles);
    while (count != 0)
    {
        DWORD wait = WaitForMultipleObjects(count, handles, FALSE, INFINITE);
        Assert(wait >= WAIT_OBJECT_0 && wait < WAIT_OBJECT_0 + count);

        DWORD index = wait - WAIT_OBJECT_0;
        HANDLE h = handles[index];
        if (h == outEvent)
        {
            if (outO.hEvent != NULL)
            {
                DWORD read;
                if (GetOverlappedResult(outRpipe, &outO, &read, TRUE))
                {
                    printf("STDOUT received: %.*s\n", (int)read, outTemp);
                    memset(&outO, 0, sizeof(outO));
                }
                else
                {
                    Assert(GetLastError() == ERROR_BROKEN_PIPE);

                    handles[index] = handles[count - 1];
                    count--;

                    CloseHandle(outRpipe);
                    CloseHandle(outEvent);
                    continue;
                }
            }

            outO.hEvent = outEvent;
            ReadFile(outRpipe, outTemp, sizeof(outTemp), NULL, &outO);
        }
        else if (h == errEvent)
        {
            if (errO.hEvent != NULL)
            {
                DWORD read;
                if (GetOverlappedResult(errRpipe, &errO, &read, TRUE))
                {
                    printf("STDERR received: %.*s\n", (int)read, errTemp);
                    memset(&errO, 0, sizeof(errO));
                }
                else
                {
                    Assert(GetLastError() == ERROR_BROKEN_PIPE);

                    handles[index] = handles[count - 1];
                    count--;

                    CloseHandle(errRpipe);
                    CloseHandle(errEvent);
                    continue;
                }
            }

            errO.hEvent = errEvent;
            ReadFile(errRpipe, errTemp, sizeof(errTemp), NULL, &errO);
        }
        else if (h == pinfo.hProcess)
        {
            handles[index] = handles[count - 1];
            count--;

            DWORD exitCode;
            ok = GetExitCodeProcess(pinfo.hProcess, &exitCode);
            Assert(ok);
            CloseHandle(pinfo.hProcess);

            printf("exit code = %u\n", exitCode);
        }
    }
}
