#include <windows.h>
#include <intrin.h>

#define Assert(x) do { if (!(x)) __debugbreak(); } while (0)

static struct
{
    DWORD process_id;
    char  data[4096 - sizeof(DWORD)];
}* ods_buffer;

static HANDLE ods_data_ready;
static HANDLE ods_buffer_ready;

static DWORD WINAPI ods_proc(LPVOID arg)
{
    DWORD ret = 0;

    HANDLE stderr = GetStdHandle(STD_ERROR_HANDLE);
    Assert(stderr);

    for (;;)
    {
        SetEvent(ods_buffer_ready);

        DWORD wait = WaitForSingleObject(ods_data_ready, INFINITE);
        Assert(wait == WAIT_OBJECT_0);

        DWORD length = 0;
        while (length < sizeof(ods_buffer->data) && ods_buffer->data[length] != 0)
        {
            length++;
        }

        if (length != 0)
        {
            DWORD written;
            WriteFile(stderr, ods_buffer->data, length, &written, NULL);
        }
    }
}

void ods_capture()
{
    if (IsDebuggerPresent())
    {
        return;
    }

    HANDLE file = CreateFileMappingA(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(*ods_buffer), "DBWIN_BUFFER");
    Assert(file != INVALID_HANDLE_VALUE);

    ods_buffer = MapViewOfFile(file, SECTION_MAP_READ, 0, 0, 0);
    Assert(ods_buffer);

    ods_buffer_ready = CreateEventA(NULL, FALSE, FALSE, "DBWIN_BUFFER_READY");
    Assert(ods_buffer_ready);

    ods_data_ready = CreateEventA(NULL, FALSE, FALSE, "DBWIN_DATA_READY");
    Assert(ods_data_ready);

    HANDLE thread = CreateThread(NULL, 0, ods_proc, NULL, 0, NULL);
    Assert(thread);
}

int main()
{
    ods_capture();

    OutputDebugStringA("hello\n");
    OutputDebugStringW(L"unicode?\n");
    OutputDebugStringA("...\n");
}
