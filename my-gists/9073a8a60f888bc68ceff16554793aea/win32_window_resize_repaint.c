// Example how screen updates can be done even when DefaultWindowProc is
// resizing or moving the window. We catch WM_ENTERMENULOOP and WM_ENTERSIZEMOVE
// to start a timer to notify us every so often. This way we regain some of the
// control that DefaultWindowProc takes from us in these modal loops.
//
// When resizing or moving the window, you should see a glimmering red
// background that turns from dark to bright and back again in 180 screen
// updates. That cycle should take a few seconds - it's hard to say how long
// exactly since we're not explicitly synchronizing with the monitor and I'm not
// sure how often we can receive WM_PAINT. The 4ms from the SetTimer() call are
// a lower bound on how often we call InvalidateRect(), though.

#include <Windows.h>
#include <stdio.h>
#include <math.h>

static float phase;
static unsigned int paint_count;
#define PI 3.141592653f

static LRESULT CALLBACK my_window_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
        switch (msg)
        {
        case WM_ENTERMENULOOP:
        case WM_ENTERSIZEMOVE:
        {
                //fprintf(stderr, "SET TIMER\n");
                // Let's be notified after 4 ms - probably soon enough to
                // schedule a repaint within a 16 ms interval.
                SetTimer(hwnd, 0, 4, NULL);
                return 0;
        } break;
        case WM_EXITMENULOOP:
        case WM_EXITSIZEMOVE:
        {
                //fprintf(stderr, "KILL TIMER\n");
                KillTimer(hwnd, 0);
                return 0;
        } break;
        case WM_TIMER:
        {
                //fprintf(stderr, "TIMER!\n");
                InvalidateRect(hwnd, NULL, TRUE);
                return 0;
        } break;
        case WM_PAINT:
        {
                //fprintf(stderr, "PAINT %u!\n", paint_count);
                paint_count++;

                phase += 2.0f * PI / 180.0f;
                if (phase > 2.0f * PI)
                        phase -= 2.0f * PI;

                float opacity = (1.0f + sinf(phase)) / 2.0f;

                PAINTSTRUCT ps = {0};
                HDC hdc = BeginPaint(hwnd, &ps);
                if (hdc)
                {
                        //RECT rect = ps.rcPaint;
                        //fprintf(stderr, "Got HDC. Rect %d, %d, %d, %d\n", rect.left, rect.right, rect.top, rect.bottom);

                        HBRUSH brush = CreateSolidBrush(RGB(255.0f * opacity, 0, 0));
                        if (brush)
                        {
                                FillRect(hdc, &ps.rcPaint, brush);
                                DeleteObject(brush);
                        }
                }
                EndPaint(hwnd, &ps);
                return 0;
        };
        default:
        {
                return DefWindowProcW(hwnd, msg, wparam, lparam);
        } break;
        }
}

int main(void)
{
        // I wouldn't particularly care about DPI awareness for this example,
        // but somehow if I don't set this there is a graphics glitch on my
        // Win10 workstation: most of the time my bottom window border (just one
        // or few pixels wide) would not be painted (or be overpainted by window
        // content?).
        SetProcessDPIAware();

        WNDCLASSW wc = {0};
        wc.lpszClassName = L"RESIZE-TEST";
        wc.lpfnWndProc = &my_window_proc;
        wc.hCursor = LoadCursor(NULL, IDC_ARROW);

        if (! RegisterClassW(&wc))
        {
                fprintf(stderr, "Failed to register window class\n");
                exit(1);
        }

        HWND hwnd = CreateWindowW(wc.lpszClassName,
                                  wc.lpszClassName,
                                  WS_OVERLAPPEDWINDOW | WS_BORDER | WS_VISIBLE,
                                  0, 0, 640, 480,
                                  NULL,
                                  NULL,
                                  GetModuleHandle(NULL),
                                  NULL);

        if (! hwnd)
        {
                fprintf(stderr, "Failed to CreateWindowW()\n");
                exit(1);
        }

        for (;;)
        {
                MSG msg;
                BOOL ret = GetMessageW(&msg, NULL, 0, 0);

                if (ret == 0)
                        break;
                if (ret == -1)
                {
                        fprintf(stderr, "Failed to GetMessage()\n");
                        exit(1);
                }
                TranslateMessage(&msg);
                DispatchMessage(&msg);
        }

        return 0;
}
