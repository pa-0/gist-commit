// PoC code to demonstrate clipboard monitoring in Windows
// using an event-based listener.
#include <stdio.h>
#include <Windows.h>

#define CLASS_NAME L"MY_CLASS"
#define WINDOW_NAME L"MY_WINDOW"

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	HANDLE hClipData = NULL;
	LPVOID data = NULL;

	switch (uMsg) {
		case WM_CLIPBOARDUPDATE:
			if (IsClipboardFormatAvailable(CF_TEXT)) {
				if (OpenClipboard(hwnd)) {
					hClipData = GetClipboardData(CF_TEXT);
					data = GlobalLock(hClipData);

					// Print the clipboard data.
					printf("%s\n\n", (LPSTR)data);

					GlobalUnlock(hClipData);
					CloseClipboard();
				}
			}
			break;

		default:
			break;
	}

	return DefWindowProc(hwnd, uMsg, wParam, lParam);;
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nShow) {
	WNDCLASSEX wc;
	HWND hwnd = NULL;

	// Create console to print clipboard data.
	AllocConsole();
	AttachConsole(GetCurrentProcessId());
	freopen("CON", "w", stdout);

	ZeroMemory(&wc, sizeof(WNDCLASSEX));
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.lpfnWndProc = WindowProc;
	wc.hInstance = hInstance;
	wc.lpszClassName = CLASS_NAME;

	// Create invisible window.
	RegisterClassEx(&wc);
	hwnd = CreateWindowEx(0, 
						  CLASS_NAME, 
						  WINDOW_NAME, 
						  0, 
						  0, 
						  0, 
						  0, 
						  0, 
						  NULL, 
						  NULL, 
						  hInstance,
						  NULL
	);

	// Add listener.
	AddClipboardFormatListener(hwnd);

	MSG msg;
	while (GetMessage(&msg, 0, 0, 0) > 0) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	RemoveClipboardFormatListener(hwnd);
	FreeConsole();

	return 0;
}