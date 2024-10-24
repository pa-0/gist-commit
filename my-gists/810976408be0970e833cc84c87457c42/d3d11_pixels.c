#define COBJMACROS
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <d3d11.h>

#include <stdint.h>
#include <string.h>
#include <intrin.h>

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxguid.lib")
#pragma comment(lib, "user32.lib")

#define Assert(cond) do { if (!(cond)) __debugbreak(); } while (0)

static LRESULT WINAPI WindowProc(HWND wnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
	switch (msg)
	{
	case WM_DESTROY:
		PostQuitMessage(0);
		return 0;
	}
	return DefWindowProcW(wnd, msg, wparam, lparam);
}

int WINAPI wWinMain(HINSTANCE instance, HINSTANCE prev, LPWSTR cmdline, int cmdshow)
{
	WNDCLASSEXW wc =
	{
		.cbSize = sizeof(wc),
		.lpfnWndProc = WindowProc,
		.hInstance = instance,
		.lpszClassName = L"pixels",
	};

	ATOM atom = RegisterClassExW(&wc);
	Assert(atom);

	HWND window = CreateWindowExW(
		WS_EX_APPWINDOW,
		wc.lpszClassName, L"pixels",
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		NULL, NULL, instance, NULL);
	Assert(window);

	ID3D11Device* device;
	ID3D11DeviceContext* context;
	IDXGISwapChain* swapChain;
	ID3D11Texture2D* backBuffer = NULL;
	ID3D11Texture2D* cpuBuffer = NULL;

	RECT rect;
	GetClientRect(window, &rect);

	DWORD width = rect.right;
	DWORD height = rect.bottom;

	DXGI_SWAP_CHAIN_DESC desc =
	{
		.BufferDesc =
		{
			.Width = width,
			.Height = height,
			.RefreshRate = { 60, 1 },
			.Format = DXGI_FORMAT_B8G8R8A8_UNORM,
		},
		.SampleDesc = { 1, 0 },
		.BufferUsage = DXGI_USAGE_BACK_BUFFER,
		.BufferCount = 1,
		.OutputWindow = window,
		.Windowed = TRUE,
		.SwapEffect = DXGI_SWAP_EFFECT_DISCARD,
	};

	DWORD flags = 0;
#ifndef NDEBUG
	flags |= D3D11_CREATE_DEVICE_DEBUG;
#endif

	HRESULT hr = D3D11CreateDeviceAndSwapChain(
		NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, flags, NULL, 0, D3D11_SDK_VERSION,
		&desc, &swapChain, &device, NULL, &context);
	if (FAILED(hr))
	{
		// try WARP software driver in case hardware one failed (like in RDP session)
		hr = D3D11CreateDeviceAndSwapChain(
			NULL, D3D_DRIVER_TYPE_WARP, NULL, flags, NULL, 0, D3D11_SDK_VERSION,
			&desc, &swapChain, &device, NULL, &context);
	}
	Assert(SUCCEEDED(hr));

	uint32_t* pixels = NULL;

	ShowWindow(window, SW_SHOWDEFAULT);

	for (;;)
	{
		MSG msg;
		while (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE))
		{
			if (msg.message == WM_QUIT)
			{
				ExitProcess(0);
			}
			TranslateMessage(&msg);
			DispatchMessageW(&msg);
		}

		GetClientRect(window, &rect);
		DWORD newWidth = rect.right;
		DWORD newHeight = rect.bottom;

		// handle resize
		if ((width != newWidth || height != newHeight) || !pixels)
		{
			if (pixels)
			{
				VirtualFree(pixels, 0, MEM_RELEASE);
				ID3D11Texture2D_Release(backBuffer);
				ID3D11Texture2D_Release(cpuBuffer);
				backBuffer = NULL;
				cpuBuffer = NULL;
				pixels = NULL;
			}

			width = newWidth;
			height = newHeight;

			// in case window is minimized, the size will be 0, no need to allocate resources
			if (width && height)
			{
				pixels = VirtualAlloc(NULL, width * height * sizeof(*pixels), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
				Assert(pixels);

				hr = IDXGISwapChain_ResizeBuffers(swapChain, 1, width, height, DXGI_FORMAT_B8G8R8A8_UNORM, 0);
				Assert(SUCCEEDED(hr));

				hr = IDXGISwapChain_GetBuffer(swapChain, 0, &IID_ID3D11Texture2D, (void**)&backBuffer);
				Assert(SUCCEEDED(hr));

				D3D11_TEXTURE2D_DESC texDesc =
				{
					.Width = width,
					.Height = height,
					.MipLevels = 1,
					.ArraySize = 1,
					.Format = DXGI_FORMAT_B8G8R8A8_UNORM,
					.SampleDesc = { 1, 0 },
					.Usage = D3D11_USAGE_DYNAMIC,
					.BindFlags = D3D11_BIND_SHADER_RESOURCE,
					.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE,
				};

				hr = ID3D11Device_CreateTexture2D(device, &texDesc, NULL, &cpuBuffer);
				Assert(SUCCEEDED(hr));
			}
		}

		// do your drawing to memory
		if (pixels)
		{
			static DWORD counter;
			for (int y = 0; y < height; y++)
			{
				for (int x = 0; x < width; x++)
				{
					DWORD r = (((x + counter) % width) * 255 / width);
					DWORD g = (y * 255 / height);
					DWORD b = 0;
					pixels[y * width + x] = (r << 16) | (g << 8) | (b << 0);
				}
			}
			counter++;
		}

		// copy pixel memory to GPU
		if (width && height)
		{
			D3D11_MAPPED_SUBRESOURCE mapped;

			hr = ID3D11DeviceContext_Map(context, (ID3D11Resource*)cpuBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped);
			Assert(SUCCEEDED(hr));
			
			// you can avoid doing this loop by writing your pixels directly to this memory
			// then you won't need VirtualAlloc/VirtualFree for "pixels" pointer
			for (DWORD y=0; y<height; y++)
			{
				memcpy((BYTE*)mapped.pData + y * mapped.RowPitch, pixels + y * width, width * sizeof(uint32_t));
			}

			ID3D11DeviceContext_Unmap(context, (ID3D11Resource*)cpuBuffer, 0);
			ID3D11DeviceContext_CopyResource(context, (ID3D11Resource*)backBuffer, (ID3D11Resource*)cpuBuffer);
		}

		// swap buffers to display to window, 1 here means use vsync
		hr = IDXGISwapChain_Present(swapChain, 1, 0);
		if (hr == DXGI_STATUS_OCCLUDED)
		{
			// window is not visible, no vsync is possible, so sleep a bit instead
			// no need for this if you don't use vsync
			Sleep(5);
		}
		else
		{
			Assert(SUCCEEDED(hr));
		}
	}
}
