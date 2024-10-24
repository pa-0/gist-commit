#include <windows.h>
#include <stdio.h>

int main(void) {
    if (!OpenClipboard(NULL)) {
        fprintf(stderr, "Failed to open clipboard!\n");
        return 1;
    }

    HANDLE clipboard;
    if (!(clipboard = GetClipboardData(CF_TEXT))) {
        fprintf(stderr, "Failed to get clipboard data handle!\n");
        return 2;
    }

    const char* text = (const char*)GlobalLock(clipboard);
    if (!text) {
        fprintf(stderr, "Failed to lock clipboard data handle!\n");
        return 3;
    }

    printf("%s", text);

    GlobalUnlock(clipboard);
    CloseClipboard();
}