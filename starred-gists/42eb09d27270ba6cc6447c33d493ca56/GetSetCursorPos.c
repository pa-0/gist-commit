#include <stdio.h>
#include <windows.h>

int main()
{
    // GetCursorPos
    puts("Press F8 to next example\n");
    POINT p;
    while(!GetAsyncKeyState(VK_F8))
    {
        GetCursorPos(&p);
        printf("\rX: %d\t Y: %d      ",p.x, p.y);
        Sleep(25);
    }

    Sleep(500);
    // SetCursorPos to (0,0) position until you press F8.
    //FreeConsole();
    puts("\rPress F8 to end\n");
    while(!GetAsyncKeyState(VK_F8))
        SetCursorPos(0,0);

    return 0;
}