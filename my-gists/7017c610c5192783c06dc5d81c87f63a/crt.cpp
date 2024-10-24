#include <windows.h>

extern "C"
{
    #pragma section(".CRT$XIA",long,read)
    #pragma section(".CRT$XIZ",long,read)
    #pragma section(".CRT$XCA",long,read)
    #pragma section(".CRT$XCZ",long,read)
    #pragma section(".CRT$XPA",long,read)
    #pragma section(".CRT$XPZ",long,read)
    #pragma section(".CRT$XTA",long,read)
    #pragma section(".CRT$XTZ",long,read)
    #pragma comment(linker, "/merge:.CRT=.rdata")

    typedef void (*_PVFV)(void);
    typedef int (*_PIFV)(void);

    // C initializers
    __declspec(allocate(".CRT$XIA")) _PIFV __xi_a[] = { 0 };
    __declspec(allocate(".CRT$XIZ")) _PIFV __xi_z[] = { 0 };

    // C++ initializers
    __declspec(allocate(".CRT$XCA")) _PVFV __xc_a[] = { 0 };
    __declspec(allocate(".CRT$XCZ")) _PVFV __xc_z[] = { 0 };

    // C pre-terminators
    __declspec(allocate(".CRT$XPA")) _PVFV __xp_a[] = { 0 };
    __declspec(allocate(".CRT$XPZ")) _PVFV __xp_z[] = { 0 };
    
     // C terminators
    __declspec(allocate(".CRT$XTA")) _PVFV __xt_a[] = { 0 };
    __declspec(allocate(".CRT$XTZ")) _PVFV __xt_z[] = { 0 };
}

static void win32_crt_call(_PIFV* a, _PIFV* b)
{
    while (a != b)
    {
        if (*a)
        {
            if ((**a)())
            {
                if (IsDebuggerPresent()) __debugbreak();
                ExitProcess(0);
            }
        }
        ++a;
    }

}

static void win32_crt_call(_PVFV* a, _PVFV* b)
{
    while (a != b)
    {
        if (*a)
        {
            (**a)();
        }
        ++a;
    }
}

static void win32_crt_init()
{
    win32_crt_call(__xi_a, __xi_z);
    win32_crt_call(__xc_a, __xc_z);
}

static void win32_crt_done()
{
   win32_crt_call(__xp_a, __xp_z);
   win32_crt_call(__xt_a, __xt_z);
}
