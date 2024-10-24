#include <windows.h>

int main()
{
    //allocate a data
    INPUT *data = new INPUT[3];
    
    // Move to position. data
    data->type = INPUT_MOUSE;
    data->mi.dx = 0;  // Position x
    data->mi.dy = 0;  // Position y
    data->mi.mouseData = 0;
    data->mi.dwFlags = (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE);
    data->mi.time = 0;
    data->mi.dwExtraInfo = 0;
    
    // Mouse down data
    (data+1)->type = INPUT_MOUSE;
    (data+1)->mi.dx = 0;
    (data+1)->mi.dy = 0;
    (data+1)->mi.mouseData = 0;
    (data+1)->mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    (data+1)->mi.time = 0;
    (data+1)->mi.dwExtraInfo = 0;
    
    // Mouse up data
    (data+2)->type = INPUT_MOUSE;
    (data+2)->mi.dx = 0;
    (data+2)->mi.dy = 0;
    (data+2)->mi.mouseData = 0;
    (data+2)->mi.dwFlags = MOUSEEVENTF_LEFTUP;
    (data+2)->mi.time = 0;
    (data+2)->mi.dwExtraInfo = 0;
    
    
    SendInput(3, data, sizeof(INPUT));
    delete (data);
    return 0;
}