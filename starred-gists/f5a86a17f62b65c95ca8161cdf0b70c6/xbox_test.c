// cl.exe xbox_test.c /link setupapi.lib user32.lib

#include <windows.h>
#include <setupapi.h>
#include <dbt.h>
#include <stdio.h>

/// interface

#define XBOX_MAX_CONTROLLERS 16

#define XBOX_DPAD_UP          0x0001
#define XBOX_DPAD_DOWN        0x0002
#define XBOX_DPAD_LEFT        0x0004
#define XBOX_DPAD_RIGHT       0x0008
#define XBOX_START            0x0010 // or "view"
#define XBOX_BACK             0x0020 // or "menu"
#define XBOX_LEFT_THUMB       0x0040
#define XBOX_RIGHT_THUMB      0x0080
#define XBOX_LEFT_SHOULDER    0x0100
#define XBOX_RIGHT_SHOULDER   0x0200
#define XBOX_GUIDE            0x0400 // or "xbox" button
#define XBOX_A                0x1000
#define XBOX_B                0x2000
#define XBOX_X                0x4000
#define XBOX_Y                0x8000

typedef struct 
{
    DWORD packet;
    WORD buttons;
    BYTE left_trigger;
    BYTE right_trigger;
    SHORT left_thumb_x;
    SHORT left_thumb_y;
    SHORT right_thumb_x;
    SHORT right_thumb_y;
} xbox_state;

typedef struct
{
    BYTE type;
    BYTE subtype;
    WORD flags;

    DWORD buttons;
    BYTE left_trigger;
    BYTE right_trigger;
    SHORT left_thumb_x;
    SHORT left_thumb_y;
    SHORT right_thumb_x;
    SHORT right_thumb_y;

    BYTE low_freq;
    BYTE high_freq;
} xbox_caps;

typedef struct
{
    BYTE type;
    BYTE level;
} xbox_battery;

// populate initial list of devices
void xbox_init();

// add new device, call this from WM_DEVICECHANGE message when wparam is DBT_DEVICEARRIVAL
// returns index on success, or negative number on failure
int xbox_connect(LPWSTR path);

// removes existing device, call this from WM_DEVICECHANGE message when wparam is DBT_DEVICEREMOVECOMPLETE
// returns index on success, or negative number on failure (wrong path)
int xbox_disconnect(LPWSTR path);

// functions return 0 on success, negative value most likely means disconnect
int xbox_get_caps(DWORD index, xbox_caps* caps);
int xbox_get_battery(DWORD index, xbox_battery* bat);
int xbox_get(DWORD index, xbox_state* state);
int xbox_set(DWORD index, BYTE low_freq, BYTE high_freq);


/// implementation

struct
{
    HANDLE handle;
    WCHAR path[MAX_PATH];
}
static xbox_devices[XBOX_MAX_CONTROLLERS];

static const GUID xbox_guid = { 0xec87f1e3, 0xc13b, 0x4100, { 0xb5, 0xf7, 0x8b, 0x84, 0xd5, 0x42, 0x60, 0xcb } };

void xbox_init()
{
    DWORD count = 0;
    HANDLE new_handles[XBOX_MAX_CONTROLLERS];
    ZeroMemory(new_handles, sizeof(new_handles));

    HDEVINFO dev = SetupDiGetClassDevsW(&xbox_guid, NULL, NULL, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT);
    if (dev != INVALID_HANDLE_VALUE)
    {
        SP_DEVICE_INTERFACE_DATA idata;
        idata.cbSize = sizeof(idata);

        DWORD index = 0;
        while (SetupDiEnumDeviceInterfaces(dev, NULL, &xbox_guid, index, &idata))
        {
            DWORD size;
            SetupDiGetDeviceInterfaceDetailW(dev, &idata, NULL, 0, &size, NULL);

            PSP_DEVICE_INTERFACE_DETAIL_DATA_W detail = LocalAlloc(LMEM_FIXED, size);
            if (detail != NULL)
            {
                detail->cbSize = sizeof(*detail); // yes, sizeof of structure, not allocated memory

                SP_DEVINFO_DATA data;
                data.cbSize = sizeof(data);

                if (SetupDiGetDeviceInterfaceDetailW(dev, &idata, detail, size, &size, &data))
                {
                    xbox_connect(detail->DevicePath);
                }
                LocalFree(detail);
            }
            index++;
        }

        SetupDiDestroyDeviceInfoList(dev);
    }
}

int xbox_connect(LPWSTR path)
{
    for (DWORD i=0; i<XBOX_MAX_CONTROLLERS; i++)
    {
        // yes, _wcsicmp, because SetupDi* functions and WM_DEVICECHANGE message provides different case paths...
        if (xbox_devices[i].handle != NULL && _wcsicmp(xbox_devices[i].path, path) == 0)
        {
            return i;
        }
    }
    
    HANDLE handle = CreateFileW(path, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (handle == INVALID_HANDLE_VALUE)
    {
        return -1;
    }

    for (DWORD i=0; i<XBOX_MAX_CONTROLLERS; i++)
    {
        if (xbox_devices[i].handle == NULL)
        {
            xbox_devices[i].handle = handle;
            wcsncpy(xbox_devices[i].path, path, MAX_PATH);
            printf("[%u] Connected\n", i);
            return i;
        }
    }

    return -1;
}

int xbox_disconnect(LPWSTR path)
{
    for (DWORD i=0; i<XBOX_MAX_CONTROLLERS; i++)
    {
        if (xbox_devices[i].handle != NULL && _wcsicmp(xbox_devices[i].path, path) == 0)
        {
            CloseHandle(xbox_devices[i].handle);
            xbox_devices[i].handle = NULL;
            return i;
        }
    }

    return -1;
}

int xbox_get_caps(DWORD index, xbox_caps* caps)
{
    if (index >= XBOX_MAX_CONTROLLERS || xbox_devices[index].handle == NULL)
    {
        return -1;
    }

    BYTE in[3] = { 0x01, 0x01, 0x00 };
    BYTE out[24];
    DWORD size;
    if (!DeviceIoControl(xbox_devices[index].handle, 0x8000e004, in, sizeof(in), out, sizeof(out), &size, NULL) || size != sizeof(out))
    {
        // NOTE: could check GetLastError() here, if it is ERROR_DEVICE_NOT_CONNECTED - that means disconnect
        return -1;
    }

    caps->type = out[2];
    caps->subtype = out[3];
    caps->flags = 4; // yes, always 4
    caps->buttons = *(WORD*)(out + 4);
    caps->left_trigger = out[6];
    caps->right_trigger = out[7];
    caps->left_thumb_x = *(SHORT*)(out + 8);
    caps->left_thumb_y = *(SHORT*)(out + 10);
    caps->right_thumb_x = *(SHORT*)(out + 12);
    caps->right_thumb_y = *(SHORT*)(out + 14);
    caps->low_freq = out[22];
    caps->high_freq = out[23];
    return 0;
}

int xbox_get_battery(DWORD index, xbox_battery* bat)
{
    if (index >= XBOX_MAX_CONTROLLERS || xbox_devices[index].handle == NULL)
    {
        return -1;
    }

    BYTE in[4] = { 0x02, 0x01, 0x00, 0x00 };
    BYTE out[4];
    DWORD size;
    if (!DeviceIoControl(xbox_devices[index].handle, 0x8000e018, in, sizeof(in), out, sizeof(out), &size, NULL) || size != sizeof(out))
    {
        // NOTE: could check GetLastError() here, if it is ERROR_DEVICE_NOT_CONNECTED - that means disconnect
        return -1;
    }

    bat->type = out[2];
    bat->level = out[3];
    return 0;
}


int xbox_get(DWORD index, xbox_state* state)
{
    if (index >= XBOX_MAX_CONTROLLERS || xbox_devices[index].handle == NULL)
    {
        return -1;
    }

    BYTE in[3] = { 0x01, 0x01, 0x00 };
    BYTE out[29];
    DWORD size;
    if (!DeviceIoControl(xbox_devices[index].handle, 0x8000e00c, in, sizeof(in), out, sizeof(out), &size, NULL) || size != sizeof(out))
    {
        // NOTE: could check GetLastError() here, if it is ERROR_DEVICE_NOT_CONNECTED - that means disconnect
        return -1;
    }

    state->packet = *(DWORD*)(out + 5);
    state->buttons = *(WORD*)(out + 11);
    state->left_trigger = out[13];
    state->right_trigger = out[14];
    state->left_thumb_x = *(SHORT*)(out + 15);
    state->left_thumb_y = *(SHORT*)(out + 17);
    state->right_thumb_x = *(SHORT*)(out + 19);
    state->right_thumb_y = *(SHORT*)(out + 21);
    return 0;
}


int xbox_set(DWORD index, BYTE low_freq, BYTE high_freq)
{
    if (index >= XBOX_MAX_CONTROLLERS || xbox_devices[index].handle == NULL)
    {
        return -1;
    }

    BYTE in[5] = { 0, 0, low_freq, high_freq, 2 };
    if (!DeviceIoControl(xbox_devices[index].handle, 0x8000a010, in, sizeof(in), NULL, 0, NULL, NULL))
    {
        // NOTE: could check GetLastError() here, if it is ERROR_DEVICE_NOT_CONNECTED - that means disconnect
        return -1;
    }
    return 0;
}


/// example code

LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wparam, LPARAM lparam)
{
    switch (message)
    {
        case WM_DEVICECHANGE:
        {    
            DEV_BROADCAST_HDR* hdr = (void*)lparam;
            if (hdr->dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
            {
                DEV_BROADCAST_DEVICEINTERFACE_W* dif = (void*)hdr;
                if (wparam == DBT_DEVICEARRIVAL)
                {
                    DWORD index = xbox_connect(dif->dbcc_name);

                    xbox_caps caps;
                    xbox_battery bat;
                    if (xbox_get_caps(index, &caps) == 0 && xbox_get_battery(index, &bat) == 0)
                    {
                        printf("[%u] Type=%u SubType=%u ButtonsMask=%04x BatteryType=%u BatteryLevel=%u\n", index, caps.type, caps.subtype, caps.buttons, bat.type, bat.level);
                    }
                }
                else if (wparam == DBT_DEVICEREMOVECOMPLETE)
                {
                    DWORD index = xbox_disconnect(dif->dbcc_name);
                    printf("[%u] Disconnected\n", index);
                }
            }
            return 0;
        }

        case WM_DESTROY:
        {
            PostQuitMessage(0);
            return 0;
        }
    }

    return DefWindowProcW(window, message, wparam, lparam);
}

int main()
{
    WNDCLASSW wc =
    {
        .lpfnWndProc = WindowProc,
        .lpszClassName = L"xbox_example",
    };
    RegisterClassW(&wc);

    HWND window = CreateWindowW(
        wc.lpszClassName, L"xbox_example", WS_OVERLAPPED,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        HWND_MESSAGE, NULL, NULL, NULL);

    DEV_BROADCAST_DEVICEINTERFACE_W db =
    {
        .dbcc_size = sizeof(db),
        .dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE,
        .dbcc_classguid = xbox_guid,
    };
    RegisterDeviceNotificationW(window, &db, DEVICE_NOTIFY_WINDOW_HANDLE);

    xbox_init();

    for (;;)
    {
        MSG msg;
        if (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
            continue;
        }

        for (DWORD i=0; i<XBOX_MAX_CONTROLLERS; i++)
        {
            xbox_state state;
            if (xbox_get(i, &state) == 0)
            {
                printf("[%u] Packet=%-6u ", i, state.packet);
                printf("Buttons=%s%s%s%s %s %s %s ",
                    (state.buttons & XBOX_A) ? "A" : " ",
                    (state.buttons & XBOX_B) ? "B" : " ",
                    (state.buttons & XBOX_X) ? "X" : " ",
                    (state.buttons & XBOX_Y) ? "Y" : " ",
                    (state.buttons & XBOX_BACK)  ? "BACK"  : "    ",
                    (state.buttons & XBOX_START) ? "START" : "     ",
                    (state.buttons & XBOX_GUIDE) ? "GUIDE" : "     ");
                printf("Dpad=%s%s%s%s ",
                    (state.buttons & XBOX_DPAD_UP)    ? "U" : " ",
                    (state.buttons & XBOX_DPAD_DOWN)  ? "D" : " ",
                    (state.buttons & XBOX_DPAD_LEFT)  ? "L" : " ",
                    (state.buttons & XBOX_DPAD_RIGHT) ? "R" : " ");
                printf("Shoulders=%s%s ",
                    (state.buttons & XBOX_LEFT_SHOULDER)  ? "L" : " ",
                    (state.buttons & XBOX_RIGHT_SHOULDER) ? "R" : " ");
                printf("Thumb=%s%s ",
                    (state.buttons & XBOX_LEFT_THUMB)  ? "L" : " ",
                    (state.buttons & XBOX_RIGHT_THUMB) ? "R" : " ");
                printf("LeftThumb=(% 0.3f,% 0.3f) ",  (state.left_thumb_x / 32768.f),  (state.left_thumb_y / 32768.f));
                printf("RightThumb=(% 0.3f,% 0.3f) ", (state.right_thumb_x / 32768.f), (state.right_thumb_y / 32768.f));
                printf("Trigger=(% 0.3f,% 0.3f) ",    (state.left_trigger / 255.f),    (state.right_trigger / 255.f));
                printf("\n");

                xbox_set(i, state.left_trigger, state.right_trigger);
            }
        }

        // just to slow down printing
        Sleep(33);
    }
}
