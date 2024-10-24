#include <windows.h>

#define MONITOR_ON -1
#define MONITOR_OFF 2
#define MONITOR_STANBY 1

int main()
{
    SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, MONITOR_OFF);
}