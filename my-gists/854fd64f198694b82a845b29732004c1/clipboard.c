#include <Windows.h>
#include <stdio.h>
#include <wchar.h>

#if !defined(_MSC_VER)
static_assert(0, "MSVC compiler required!");
#endif

wchar_t* clipboard_get() {
    if (!IsClipboardFormatAvailable(CF_UNICODETEXT) || !OpenClipboard(NULL)) {
        fprintf(stderr, "Error: Failed to access the clipboard!\n");
        return NULL;
    }
    const GLOBALHANDLE globalhandle = GetClipboardData(CF_UNICODETEXT);
    if (!globalhandle) {
        fprintf(stderr, "Error: Failed to retrieve clipboard data!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            exit(EXIT_FAILURE);
        }
        return NULL;
    }
    const SIZE_T size = GlobalSize(globalhandle);
    if (!size) {
        fprintf(stderr, "Error: Failed to determine clipboard data size!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            exit(EXIT_FAILURE);
        }
        return NULL;
    }
    wchar_t* text = (wchar_t*)malloc(size);
    if (!text) {
        fprintf(stderr, "Error: Failed to allocate memory!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            free(text);
            exit(EXIT_FAILURE);
        }
        return NULL;
    }
    const wchar_t* pcd = (const wchar_t*)GlobalLock(globalhandle);
    if (!pcd) {
        fprintf(stderr, "Error: Failed to lock clipboard data!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            free(text);
            exit(EXIT_FAILURE);
        }
        free(text);
        return NULL;
    }
    if (wcscpy_s(text, size / sizeof(wchar_t), pcd)) {
        fprintf(stderr, "Error: Failed to copy clipboard data!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            free(text);
            exit(EXIT_FAILURE);
        }
        free(text);
        return NULL;
    }
    if (!GlobalUnlock(globalhandle)) {
        fprintf(stderr, "Error: Failed to unlock clipboard data!\n");
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close clipboard!\n");
            free(text);
            exit(EXIT_FAILURE);
        }
        free(text);
        return NULL;
    }
    if (!CloseClipboard()) {
        fprintf(stderr, "Error: Failed to close clipboard!\n");
        free(text);
        exit(EXIT_FAILURE);
    }
    return text;
}

void clipboard_set(const wchar_t *wcs) {
    if (!wcs || !*wcs) {
        fprintf(stderr, "Error: Null Pointer!\n");
        return;
    }
    const size_t len = (wcslen(wcs) + 1) * sizeof(wchar_t);
    const GLOBALHANDLE globalHandle = GlobalAlloc(GHND | GMEM_SHARE, len);
    if (!globalHandle) {
        fprintf(stderr, "Error: Failed to allocate memory!\n");
        return;
    }
    LPVOID globalHandleLock = GlobalLock(globalHandle);
    if (!globalHandleLock) {
        fprintf(stderr, "Error: failed to lock memory!\n");
        exit(EXIT_FAILURE);
    }
    if (!memcpy(globalHandleLock, wcs, len)) {
        fprintf(stderr, "Error: failed to copy data to the clipboard!\n");
        GlobalFree(globalHandle);
        return;
    }
    if (GlobalUnlock(globalHandleLock)) {
        fprintf(stderr, "Error: failed to unlock memory!\n");
        GlobalFree(globalHandleLock);
        return;
    }
    if (!OpenClipboard(NULL)) {
        fprintf(stderr, "Error: failed to open the clipboard!\n");
        globalHandleLock = GlobalLock(globalHandle);
        if (!globalHandleLock) {
            fprintf(stderr, "Error: failed to lock memory\n");
            exit(1);
        }
        GlobalFree(globalHandleLock);
        return;
    }
    if (!EmptyClipboard()) {
        fprintf(stderr, "Error: Failed to empty the clipboard!\n");
        globalHandleLock = GlobalLock(globalHandle);
        if (!globalHandleLock) {
            fprintf(stderr, "Error: failed to lock memory\n");
            exit(1);
        }
        GlobalFree(globalHandleLock);
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close the clipboard!\n");
            exit(1);
        }
        return;
    }
    if (!SetClipboardData(CF_UNICODETEXT, globalHandle)) {
        fprintf(stderr, "Error: Failed to set clipboard data!\n");
        globalHandleLock = GlobalLock(globalHandle);
        if (!globalHandleLock) {
            fprintf(stderr, "Error: failed to lock memory\n");
            exit(1);
        }
        GlobalFree(globalHandleLock);
        if (!CloseClipboard()) {
            fprintf(stderr, "Error: Failed to close the clipboard!\n");
            exit(1);
        }
        return;
    }
    if (!CloseClipboard()) {
        fprintf(stderr, "Error: Failed to close the clipboard!\n");
        exit(1);
    }
}