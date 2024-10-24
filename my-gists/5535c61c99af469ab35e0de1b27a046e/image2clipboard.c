#define STB_IMAGE_STATIC
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h" // get from https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

#include <windows.h>

int main(int argc, char* argv[])
{
   int w, h;
   stbi_uc* data = stbi_load(argv[1], &w, &h, NULL, 4);

   BITMAPV5HEADER header = {
     .bV5Size = sizeof(header),
     .bV5Width = w,
     .bV5Height = h, // could be negative to vflip, but some applications do not like it
     .bV5Planes = 1,
     .bV5BitCount = 32,
     .bV5Compression = BI_BITFIELDS,
     .bV5RedMask   = 0x000000ff, // update masks for whatever RGBA byte order you have
     .bV5GreenMask = 0x0000ff00,
     .bV5BlueMask  = 0x00ff0000,
     .bV5AlphaMask = 0xff000000,
     .bV5CSType = LCS_WINDOWS_COLOR_SPACE, // required for alpha support
   };

   HGLOBAL global = GlobalAlloc(GMEM_MOVEABLE, sizeof(header) + w*h*4);
   if (global) {
     BYTE* buffer = GlobalLock(global);
     if (buffer) {
       CopyMemory(buffer, &header, sizeof(header));
       // vflip the bitmap manually, for better compatibility
       for (int i=0; i<h; i++) {
         CopyMemory(buffer + sizeof(header) + i*w*4, data + (h-1-i)*w*4, w*4);
       }
       GlobalUnlock(global);
     }
     if (OpenClipboard(NULL)) {
       EmptyClipboard();
       SetClipboardData(CF_DIBV5, global);
       CloseClipboard();
     }
   }
}
