This solution works fine on both Linux and Windows, but failed on macOS. @Ionizing modified it to make it run on macOS (x86). (Link to @Ionizing's fork below)

- [x] Support macOS (x86)
- [x] Add optional prefix for variable name

```c
#include <stdio.h>

#define STR2(x) #x
#define STR(x) STR2(x)

#ifdef __APPLE__
#define USTR(x) "_" STR(x)
#else
#define USTR(x) STR(x)
#endif

#ifdef _WIN32
#define INCBIN_SECTION ".rdata, \"dr\""
#elif defined __APPLE__
#define INCBIN_SECTION "__TEXT,__const"
#else
#define INCBIN_SECTION ".rodata"
#endif

// this aligns start address to 16 and terminates byte array with explict 0
// which is not really needed, feel free to change it to whatever you want/need
#define INCBIN(prefix, name, file) \
    __asm__(".section " INCBIN_SECTION "\n" \
            ".global " USTR(prefix) "_" STR(name) "_start\n" \
            ".balign 16\n" \
            USTR(prefix) "_" STR(name) "_start:\n" \
            ".incbin \"" file "\"\n" \
            \
            ".global " STR(prefix) "_" STR(name) "_end\n" \
            ".balign 1\n" \
            USTR(prefix) "_" STR(name) "_end:\n" \
            ".byte 0\n" \
    ); \
    extern __attribute__((aligned(16))) const char prefix ## _ ## name ## _start[]; \
    extern                              const char prefix ## _ ## name ## _end[];

INCBIN(incbin, foobar, "binary.bin");

int main()
{
    printf("start = %p\n", &incbin_foobar_start);
    printf("end = %p\n", &incbin_foobar_end);
    printf("size = %zu\n", (char*)&incbin_foobar_end - (char*)&incbin_foobar_start);
    printf("first byte = 0x%02hhx\n", incbin_foobar_start[0]);
}
```

The code above can also be found in this [fork](https://gist.githubusercontent.com/Ionizing/e28ba8c068d69e965e07a9f6b185dc4a/raw/d8579e13d453f5ed95b27b09136d8dcc36278e90/incbin.c).