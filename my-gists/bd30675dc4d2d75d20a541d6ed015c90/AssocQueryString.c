#include <windows.h>
#include <Shlwapi.h>
#include <stdio.h>
#pragma comment(lib, "shlwapi.lib")

char* assocStr[] =
{
    "ASSOCSTR_COMMAND",
    "ASSOCSTR_EXECUTABLE",
    "ASSOCSTR_FRIENDLYDOCNAME",
    "ASSOCSTR_FRIENDLYAPPNAME",
    "ASSOCSTR_NOOPEN",
    "ASSOCSTR_SHELLNEWVALUE",
    "ASSOCSTR_DDECOMMAND",
    "ASSOCSTR_DDEIFEXEC",
    "ASSOCSTR_DDEAPPLICATION",
    "ASSOCSTR_DDETOPIC",
    "ASSOCSTR_INFOTIP",
    "ASSOCSTR_QUICKTIP",
    "ASSOCSTR_TILEINFO",
    "ASSOCSTR_CONTENTTYPE",
    "ASSOCSTR_DEFAULTICON",
    "ASSOCSTR_SHELLEXTENSION",
    "ASSOCSTR_DROPTARGET",
    "ASSOCSTR_DELEGATEEXECUTE",
    "ASSOCSTR_MAX"
};


int main()
{
    char buffer[256];
    DWORD bufferLen = 256;
    HRESULT hres;

    int i;
    for (i = 0; i < 20; i++)
    {
        hres = AssocQueryString(0, i, ".doc", NULL, buffer, &bufferLen);
        if (S_OK == hres)
            printf("%s\n%s\n\n", assocStr[i], buffer);
        bufferLen = 256;
    }

    return 0;
}
