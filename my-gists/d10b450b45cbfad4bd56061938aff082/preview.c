// example of using Windows Preview Handler
// https://learn.microsoft.com/en-us/windows/win32/shell/preview-handlers

#define COBJMACROS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shlwapi.h>
#include <shellapi.h>
#include <shobjidl.h>

#include <intrin.h>
#define Assert(cond) do { if (!(cond)) __debugbreak(); } while (0)
#define AssertHR(hr) Assert(SUCCEEDED(hr))

#pragma comment (lib, "user32")
#pragma comment (lib, "ole32")
#pragma comment (lib, "shell32")
#pragma comment (lib, "shlwapi")

static IPreviewHandler* CreatePreview(LPWSTR FilePath)
{
	IPreviewHandler* Preview = NULL;

	LPWSTR Extension = PathFindExtensionW(FilePath);
	if (Extension)
	{
		// alternatively just hardcode L"{8895b1c6-b41f-4c1c-a562-0d564250836f}" string
		LPOLESTR PreviewStr;
		AssertHR(StringFromIID(&IID_IPreviewHandler, &PreviewStr));

		WCHAR ClassIdStr[128];
		DWORD ClassIdStrSize = ARRAYSIZE(ClassIdStr);
		if (SUCCEEDED(AssocQueryStringW(ASSOCF_INIT_DEFAULTTOSTAR, ASSOCSTR_SHELLEXTENSION, Extension, PreviewStr, ClassIdStr, &ClassIdStrSize)))
		{
			CLSID ClassId;
			AssertHR(CLSIDFromString(ClassIdStr, &ClassId));

			if (FAILED(CoCreateInstance(&ClassId, NULL, CLSCTX_LOCAL_SERVER, &IID_IPreviewHandler, (void**)&Preview)))
			{
				Preview = NULL;
			}
		}

		CoTaskMemFree(PreviewStr);
	}

	if (Preview)
	{
		IInitializeWithFile* InitWithFile;
		IInitializeWithStream* InitWithStream;
		if (SUCCEEDED(IPreviewHandler_QueryInterface(Preview, &IID_IInitializeWithFile, (void**)&InitWithFile)))
		{
			if (FAILED(IInitializeWithFile_Initialize(InitWithFile, FilePath, STGM_READ)))
			{
				IPreviewHandler_Release(Preview);
				Preview = NULL;
			}
			IInitializeWithFile_Release(InitWithFile);
		}
		else if (SUCCEEDED(IPreviewHandler_QueryInterface(Preview, &IID_IInitializeWithStream, (void**)&InitWithStream)))
		{
			IStream* Stream;
			if (SUCCEEDED(SHCreateStreamOnFileW(FilePath, STGM_READ, &Stream)))
			{
				if (FAILED(IInitializeWithStream_Initialize(InitWithStream, Stream, STGM_READ)))
				{
					IPreviewHandler_Release(Preview);
					Preview = NULL;
				}
				IStream_Release(Stream);
			}
			IInitializeWithStream_Release(InitWithStream);
		}
		else
		{
			IPreviewHandler_Release(Preview);
			Preview = NULL;
		}
	}

	return Preview;
}

static IPreviewHandler* Preview;

static LRESULT CALLBACK WindowProc(HWND Window, UINT Message, WPARAM WParam, LPARAM LParam)
{
	switch (Message)
	{
	case WM_SIZE:
		if (Preview && LParam != 0)
		{
			RECT Rect;
			GetClientRect(Window, &Rect);
			AssertHR(IPreviewHandler_SetRect(Preview, &Rect));
			return 0;
		}
		break;

	case WM_DESTROY:
		PostQuitMessage(0);
		return 0;

	case WM_DROPFILES:
	{
		HDROP Drop = (HDROP)WParam;

		WCHAR FilePath[MAX_PATH];
		if (DragQueryFileW(Drop, 0, FilePath, ARRAYSIZE(FilePath)))
		{
			IPreviewHandler* NewPreview = CreatePreview(FilePath);
			if (NewPreview)
			{
				if (Preview)
				{
					AssertHR(IPreviewHandler_Unload(Preview));
					IPreviewHandler_Release(Preview);
				}
				Preview = NewPreview;

				RECT Rect;
				GetClientRect(Window, &Rect);
				AssertHR(IPreviewHandler_SetWindow(Preview, Window, &Rect));
				AssertHR(IPreviewHandler_DoPreview(Preview));
			}
			else
			{
				MessageBoxW(0, FilePath, L"Cannot create preview for file!", MB_ICONEXCLAMATION);
			}
		}
		DragFinish(Drop);
		
		return 0;
	}

	}

	return DefWindowProcW(Window, Message, WParam, LParam);
}

int WINAPI wWinMain(HINSTANCE Instance, HINSTANCE PrevInstance, LPWSTR CmdLine, int CmdShow)
{
	AssertHR(CoInitializeEx(NULL, COINIT_APARTMENTTHREADED));

	WNDCLASSEXW WindowClass =
	{
		.cbSize = sizeof(WindowClass),
		.style = CS_HREDRAW | CS_VREDRAW,
		.lpfnWndProc = WindowProc,
		.hInstance = Instance,
		.hIcon = LoadIcon(NULL, IDI_APPLICATION),
		.hCursor = LoadCursor(NULL, IDC_ARROW),
		.lpszClassName = L"PreviewClass",
	};
	ATOM Atom = RegisterClassExW(&WindowClass);
	Assert(Atom && "Failed to register window class");

	HWND Window = CreateWindowExW(
		WS_EX_APPWINDOW, WindowClass.lpszClassName, L"Preview", WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		NULL, NULL, Instance, NULL);
	Assert(Window && "Failed to create window");

	DragAcceptFiles(Window, TRUE);

	MSG Message;
	while (GetMessage(&Message, NULL, 0, 0) > 0)
	{
		TranslateMessage(&Message);
		DispatchMessageW(&Message);
	}

	ExitProcess(0);
}
