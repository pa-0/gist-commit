#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

int main()
{
    sndPlaySound("file.wav", SND_ASYNC | SND_FILENAME | SND_LOOP);
    getchar();
    return 0;
}
