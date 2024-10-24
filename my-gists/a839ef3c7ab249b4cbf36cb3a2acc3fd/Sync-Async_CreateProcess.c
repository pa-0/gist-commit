#include <windows.h>
#include <stdio.h>

static HANDLE myCreateProcess(TCHAR* cmd, BOOL sync)
{
    PROCESS_INFORMATION ProcInfo = {0};
    STARTUPINFO StartUp = {sizeof(STARTUPINFO)};
    
    if (CreateProcess(NULL, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &StartUp, &ProcInfo))
    {
        CloseHandle(ProcInfo.hThread);
        if(sync)
        {
            WaitForSingleObject(ProcInfo.hProcess, INFINITE);
            CloseHandle(ProcInfo.hProcess);
        }
        return ProcInfo.hProcess;
    }
    else
    {
        if (sync == FALSE)
            ShellExecute(0, "open", cmd, 0, 0, SW_SHOW /*SW_HIDE*/);
        return NULL;
    }
}

int main()
{
    // Async
    printf("Asynchronous process was opened.\n");
    HANDLE hProcess = myCreateProcess(TEXT("calc.exe"), FALSE);
    for(int i = 0; i <= 100; i++)
    {
        printf("\rLoading... %d%%", i);
        Sleep(50);
    }
    CloseHandle(hProcess);
    printf("\n");
    
    // Sync
    printf("Synchronous process was opened.\n");
    myCreateProcess(TEXT("calc.exe"), TRUE);
    printf("Synchronous process was closed.\n");
    for(int i = 0; i <= 100; i++)
    {
        printf("\rLoading... %d%%", i);
        Sleep(50);
    }
    printf("\n");
    
    return 0;
}


