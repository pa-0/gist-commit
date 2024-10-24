// https://gist.github.com/stefansundin/9d95826a712096b24ae2
// https://devblogs.microsoft.com/oldnewthing/?p=3023
// gcc -s -o clop clop.c

// Usage:
// clop | gpg -v
// clop /u = output is printed in Unicode
// clop /a = output is printed in ANSI
// otherwise, output is printed in OEM codepage

#define UNICODE
#define _UNICODE

#include <windows.h>
#include <stdio.h>
#include <tchar.h>
#include <strsafe.h>

int main(int argc, wchar_t *argv[]) {
	DWORD cbWritten;
	HANDLE _stdout = GetStdHandle(STD_OUTPUT_HANDLE);
	HANDLE _stderr = GetStdHandle(STD_ERROR_HANDLE);
	BOOL opt_unicode = (argc == 2 && wcsicmp(argv[1],L"/u") == 0);
	BOOL opt_ansi = (argc == 2 && wcsicmp(argv[1],L"/a") == 0);

	if (OpenClipboard(NULL) == 0) {
		char error[] = "clop: OpenClipboard() failed!\n";
		WriteFile(_stderr, error, sizeof(error), &cbWritten, NULL);
		return 1;
	}

	HANDLE h = GetClipboardData(CF_UNICODETEXT);
	if (h == NULL) {
		// This most likely means the user has something other than text in the clipboard, e.g. a file
		char error[] = "clop: GetClipboardData() failed!\n";
		WriteFile(_stderr, error, sizeof(error), &cbWritten, NULL);
		CloseClipboard();
		return 2;
	}

	wchar_t *text = (wchar_t*) GlobalLock(h);
	if (text == NULL) {
		char error[] = "clop: GlobalLock() failed!\n";
		WriteFile(_stderr, error, sizeof(error), &cbWritten, NULL);
		CloseClipboard();
		return 3;
	}

	SIZE_T clipboard_size = GlobalSize(h);
	if (clipboard_size > 0x10000000) {
		// arbitrary limit because I am lazy
		clipboard_size = 0x10000000;
		char error[] = "clop: clipboard size > 256 MB. Clipped!\n";
		WriteFile(_stderr, error, sizeof(error), &cbWritten, NULL);
	}

	size_t cbActual;
	if (FAILED(StringCbLengthW(text, clipboard_size, &cbActual))) {
		char error[] = "clop: StringCbLengthW() failed!\n";
		WriteFile(_stderr, error, sizeof(error), &cbWritten, NULL);
		GlobalUnlock(h);
		CloseClipboard();
		return 4;
	}

	if (opt_unicode) {
		WriteFile(_stdout, text, cbActual, &cbWritten, NULL);
	}
	else {
		UINT cp = opt_ansi ? CP_ACP : CP_OEMCP;
		int cch = WideCharToMultiByte(cp, 0, text, cbActual/sizeof(wchar_t), NULL, 0, NULL, NULL);
		if (cch > 0) {
			char *psz = malloc(cch);
			if (psz != NULL) {
				WideCharToMultiByte(cp, 0, text, cbActual/sizeof(wchar_t), psz, cch, NULL, NULL);
				WriteFile(_stdout, psz, cch, &cbWritten, NULL);
				free(psz);
			}
		}
	}

	GlobalUnlock(h);
	CloseClipboard();
	return 0;
}
