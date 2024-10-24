#include <windows.h>

int main()
{
    // Example: Hide all windows
    while(1)
    {
        HWND window = GetForegroundWindow();
        ShowWindow(window, false);
    }
}
