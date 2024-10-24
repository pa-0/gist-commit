#include <windows.h>

int main()
{
    SendMessage(GetForegroundWindow(), WM_SYSCOMMAND, SC_SCREENSAVE, 0);
}