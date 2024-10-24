#include <stdio.h>
#include <windows.h>

// If have compile errors:
// Replace TokenElevation by (TOKEN_INFORMATION_CLASS)20
// Uncomment next struct
/*
typedef struct _TOKEN_ELEVATION {
    DWORD TokenIsElevated;
} TOKEN_ELEVATION, *PTOKEN_ELEVATION;
*/

BOOL IsElevated()
{
    DWORD dwSize = 0;
    HANDLE hToken = NULL;
    BOOL bReturn = FALSE;
    
    TOKEN_ELEVATION tokenInformation;
    
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
        return FALSE;
    
    if (GetTokenInformation(hToken, TokenElevation, &tokenInformation, sizeof(TOKEN_ELEVATION), &dwSize))
        bReturn = (BOOL)tokenInformation.TokenIsElevated;
    
    CloseHandle(hToken);
    return bReturn;
}

int main(int argc, char *argv[])
{
    if (IsElevated())
        printf("Process is elevated\n");
    else
        printf("Process is not elevated\n");
    
    getchar();
    return 0;
}
