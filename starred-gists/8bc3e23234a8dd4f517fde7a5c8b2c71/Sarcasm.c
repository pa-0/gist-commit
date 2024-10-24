#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <locale.h>

int main(void)
{
    if (!OpenClipboard(NULL))
    {
        fprintf(stderr, "Could not access clipboard!\n");
        return EXIT_FAILURE;
    }

    setlocale(LC_ALL, "");
    HANDLE hClipboard = GetClipboardData(CF_UNICODETEXT);

    if (hClipboard == NULL)
    {
        fprintf(stderr, "Bad clipboard format!\n");
        CloseClipboard();
        return EXIT_FAILURE;
    }

    size_t textLen = wcslen(hClipboard),
           textLenBytes = textLen * sizeof(WCHAR);

    HGLOBAL hBuffer = GlobalAlloc(GMEM_MOVEABLE, textLenBytes + 1);
    LPWSTR pBuffer = GlobalLock(hBuffer);

    memcpy(pBuffer, hClipboard, textLenBytes);
    
    size_t charIndex = 0;
    for (size_t i = 0; i < textLen; i++)
    {
        if (pBuffer[i] == L' ')
            continue;

        pBuffer[i] = charIndex++ & 1 
                   ? towupper(pBuffer[i])
                   : towlower(pBuffer[i]);
    }

    GlobalUnlock(hBuffer);

    EmptyClipboard();
    SetClipboardData(CF_UNICODETEXT, hBuffer);

    CloseClipboard();
    return EXIT_SUCCESS;
}