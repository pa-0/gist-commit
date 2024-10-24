#include <windows.h>

int main()
{
    int width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
    int height = GetSystemMetrics(SM_CYVIRTUALSCREEN);
    int top = GetSystemMetrics(SM_YVIRTUALSCREEN);
    int left = GetSystemMetrics(SM_XVIRTUALSCREEN);
    int size = width * height * 3;
    int headerSize = sizeof(BITMAPINFOHEADER) + sizeof(BITMAPFILEHEADER);

    BITMAPFILEHEADER bmFile = {0x4D42, headerSize + size, 0, 0, headerSize};
    BITMAPINFO bmInfo = {{sizeof(BITMAPINFOHEADER), width, height, 1, 24, BI_RGB, size, 0, 0, 0, 0}};
    LPBYTE pixels;

    HDC hdc = CreateCompatibleDC(0);
    HBITMAP hBMP = CreateDIBSection(hdc, &bmInfo, DIB_RGB_COLORS, (LPVOID*)&pixels, 0, 0);
    SelectObject(hdc, hBMP);
    BitBlt(hdc, 0, 0, width, height, GetDC(0), left, top, SRCCOPY);
    DeleteDC(hdc);

    HANDLE hFile = CreateFile("c:\\Screenshot.bmp", FILE_WRITE_DATA, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (hFile != INVALID_HANDLE_VALUE)
    {
        DWORD dwOut;
        WriteFile(hFile,&bmFile, sizeof(BITMAPFILEHEADER), &dwOut, NULL);
        WriteFile(hFile,&bmInfo, sizeof(BITMAPINFOHEADER), &dwOut, NULL);
        WriteFile(hFile, pixels, size, &dwOut, NULL);
        CloseHandle(hFile);
    }

    DeleteObject(hBMP);

    return 0;
}