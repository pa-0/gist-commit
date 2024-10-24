/* We need this to properly get reported a mouse button release outside a window when there was a drag. */
static unsigned win32_mousebuttonMask; /* a mask of 1<<button for each button that is down. */
static int win32_isMouseCaptured;

static void win32_process_mouse_event(HWND hwnd, UINT msg)
{
        /* We capture the mouse using SetCapture() and release the mouse
        using ReleaseCapture() when the mouse state changes between having
        any or no depressed mouse buttons.
        This makes sure that we get notified when the mouse is released
        during a drag - even when the mouse is currently outside the window
        that receives events. */

        static const struct {
                UINT msg;
                int mousebuttonKind;
                int mousebuttonEventKind;
        } table[] = {
                { WM_LBUTTONDOWN, MOUSEBUTTON_1, MOUSEBUTTONEVENT_PRESS },
                { WM_LBUTTONUP, MOUSEBUTTON_1, MOUSEBUTTONEVENT_RELEASE },
                { WM_MBUTTONDOWN, MOUSEBUTTON_2, MOUSEBUTTONEVENT_PRESS },
                { WM_MBUTTONUP, MOUSEBUTTON_2, MOUSEBUTTONEVENT_RELEASE },
                { WM_RBUTTONDOWN, MOUSEBUTTON_3, MOUSEBUTTONEVENT_PRESS },
                { WM_RBUTTONUP, MOUSEBUTTON_3, MOUSEBUTTONEVENT_RELEASE },
        };

        for (int i = 0; i < sizeof table / sizeof table[0]; i++) {
                if (table[i].msg == msg) {
                        int buttonKind = table[i].mousebuttonKind;
                        int buttonEventKind = table[i].mousebuttonEventKind;
                        unsigned mask = 1 << buttonKind;
                        if (buttonEventKind == MOUSEBUTTONEVENT_PRESS) {
                                if (!win32_mousebuttonMask)
                                        SetCapture(hwnd);
                                win32_mousebuttonMask |= mask;
                        }
                        else if (buttonEventKind == MOUSEBUTTONEVENT_RELEASE) {
                                win32_mousebuttonMask &= ~mask;
                                if (!win32_mousebuttonMask)
                                        ReleaseCapture();
                        }
                }
        }
}