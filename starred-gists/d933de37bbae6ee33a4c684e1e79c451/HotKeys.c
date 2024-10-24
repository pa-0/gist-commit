#include <windows.h>

#define CTRL_ALT_F1 101
#define CTRL_F2     102
#define ALT_F3      103
#define CTRL_UP     104
#define CTRL_DOWN   105
#define CTRL_RIGHT  106
#define CTRL_LEFT   107
#define EXIT_KEYS   108

LRESULT CALLBACK WinProc(HWND, UINT, WPARAM, LPARAM);
char Name[] = "HotKey demo - DavidXL";

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst, LPSTR lpszArgument, int nFunsterStil)
{
    HWND hwnd;
    MSG messages;

    WNDCLASSEX wincl = {sizeof(WNDCLASSEX),0,WinProc,0,0,hInst,0,0,0,0,Name,0};
    if (!RegisterClassEx (&wincl)) return 1;
    hwnd = CreateWindowEx(0, Name, Name, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,
                          CW_USEDEFAULT, 0, 0, HWND_DESKTOP, NULL, hInst, NULL);

    RegisterHotKey(hwnd, CTRL_ALT_F1, MOD_CONTROL|MOD_ALT, VK_F1);
    RegisterHotKey(hwnd, CTRL_F2, MOD_CONTROL, VK_F2);
    RegisterHotKey(hwnd, ALT_F3, MOD_ALT, VK_F3);
    RegisterHotKey(hwnd, CTRL_UP, MOD_CONTROL, VK_UP);
    RegisterHotKey(hwnd, CTRL_DOWN, MOD_CONTROL, VK_DOWN);
    RegisterHotKey(hwnd, CTRL_RIGHT, MOD_CONTROL, VK_RIGHT);
    RegisterHotKey(hwnd, CTRL_LEFT, MOD_CONTROL, VK_LEFT);
    RegisterHotKey(hwnd, EXIT_KEYS, 0 , VK_ESCAPE);

    while (GetMessage (&messages, NULL, 0, 0))
    {
        TranslateMessage(&messages);
        DispatchMessage(&messages);
    }
    return messages.wParam;
}

LRESULT CALLBACK WinProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
{
    switch (message)
    {
    case WM_HOTKEY:
        switch(wParam)
        {
        case CTRL_ALT_F1:
            MessageBox(NULL, "CTRL_ALT_F1", Name, MB_OK);
            break;
        case CTRL_F2:
            MessageBox(NULL, "CTRL_F2", Name, MB_OK);
            break;
        case ALT_F3:
            MessageBox(NULL, "ALT_F3", Name, MB_OK);
            break;
        case CTRL_UP:
            MessageBox(NULL, "CTRL_UP", Name, MB_OK);
            break;
        case CTRL_DOWN:
            MessageBox(NULL, "CTRL_DOWN", Name, MB_OK);
            break;
        case CTRL_RIGHT:
            MessageBox(NULL, "CTRL_RIGHT", Name, MB_OK);
            break;
        case CTRL_LEFT:
            MessageBox(NULL, "CTRL_LEFT", Name, MB_OK);
            break;
        case EXIT_KEYS:
            MessageBox(NULL, "bye bye", Name, MB_OK);
            for (int i = CTRL_ALT_F1; i <= EXIT_KEYS; i++)
				UnregisterHotKey(hwnd, i);
            PostQuitMessage(0);
            break;
        }
        break;
    case WM_DESTROY:
        PostQuitMessage (0);
        break;
    default:
        return DefWindowProc(hwnd, message, wParam, lParam);
    }
    return 0;
}
