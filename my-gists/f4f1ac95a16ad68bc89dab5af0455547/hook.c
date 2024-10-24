// compile this to hook.dll
// for example, with MSVC: cl.exe /LD /MT /O2 hook.c /Fehook.dll

#include <windows.h>

// get this from https://github.com/kubo/plthook
#include "plthook_win32.c"

static plthook_t* hook;

static BOOL WINAPI WriteConsoleHook(HANDLE hConsoleOutput, const VOID *lpBuffer, DWORD nNumberOfCharsToWrite, LPDWORD lpNumberOfCharsWritten, LPVOID lpReserved)
{
    return WriteFile(hConsoleOutput, lpBuffer, nNumberOfCharsToWrite, lpNumberOfCharsWritten, NULL);
}

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    if (fdwReason == DLL_PROCESS_ATTACH)
    {
        plthook_open(&hook, "kernel32.dll");
        plthook_replace(hook, "WriteConsoleA", (void*)&WriteConsoleHook, NULL);
        plthook_replace(hook, "WriteConsoleW", (void*)&WriteConsoleHook, NULL);
    }
    else if (fdwReason == DLL_PROCESS_DETACH)
    {
        plthook_close(hook);
    }
    return TRUE;
}
