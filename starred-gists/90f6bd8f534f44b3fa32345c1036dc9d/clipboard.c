/**
 * Write 4 bytes to clipboard device. Used for headers
 */
void clipboard_write_long(long* data)
{
  clip_ior->io_Data=(STRPTR)data;
  clip_ior->io_Length=4;
  clip_ior->io_Command=CMD_WRITE;
  DoIO((struct IORequest *)clip_ior);
}

/**
 * Write screen to clipboard
 */
void clipboard_write_screen(void)
{
  long length=96096;
  long bmhdlength=20;
  long cmaplength=24;
  long camglength=4;
  long dpiLength=4;
  long dpiData=0;
  long bodylength=96000;
  unsigned short i,j;
  typedef UBYTE Masking;     /* Choice of masking technique. */

#define mskNone                0
#define mskHasMask             1
#define mskHasTransparentColor 2
#define mskLasso               3

  typedef UBYTE Compression;    /* Choice of compression algorithm
                                   applied to the rows of all source and mask planes.  "cmpByteRun1"
                                   is the byte run encoding described in Appendix C.  Do not compress
                                   across rows! */
#define cmpNone        0
#define cmpByteRun1    1

  typedef struct _bmhdData {
    UWORD       w, h;             /* raster width & height in pixels      */
    WORD        x, y;             /* pixel position for this image        */
    UBYTE       nPlanes;          /* # source bitplanes                   */
    Masking     masking;
    Compression compression;
    UBYTE       pad1;             /* unused; ignore on read, write as 0   */
    UWORD       transparentColor; /* transparent "color number" (sort of) */
    UBYTE       xAspect, yAspect; /* pixel aspect, a ratio width : height */
    WORD        pageWidth, pageHeight; /* source "page" size in pixels    */
  } BMHDData;

  BMHDData bmhdData;

  typedef struct {
    UBYTE red, green, blue;           /* color intensities 0..255 */
  } ColorRegister;                  /* size = 3 bytes           */

  typedef ColorRegister ColorMap[8];    /* size = 3n bytes          */

  ColorMap cmap;
  ULONG modeflags=0x8004;

  bmhdData.w=640;
  bmhdData.h=400;
  bmhdData.x=0;
  bmhdData.y=0;
  bmhdData.nPlanes=myWindow->RPort->BitMap->Depth;
  bmhdData.masking=0;
  bmhdData.compression=0;
  bmhdData.pad1=0;
  bmhdData.transparentColor=0;
  bmhdData.xAspect=10;
  bmhdData.yAspect=11;
  bmhdData.pageWidth=640;
  bmhdData.pageHeight=400;

  // Write header
  clip_ior->io_Offset=0;
  clip_ior->io_Error=0;
  clip_ior->io_ClipID=0;
  clipboard_write_long((long *)"FORM");
  clipboard_write_long(&length);
  clipboard_write_long((long *)"ILBM");


  // Write BMHD
  clipboard_write_long((long *)"BMHD");
  clipboard_write_long(&bmhdlength);
  clip_ior->io_Data=(STRPTR)&bmhdData;
  clip_ior->io_Length=sizeof(bmhdData);
  clip_ior->io_Command=CMD_WRITE;
  DoIO((struct IORequest *)clip_ior);

  // Write CMAP
  clipboard_write_long((long *)"CMAP");
  clipboard_write_long(&cmaplength);
  for (i=0;i<8;i++)
    {
      ULONG tmpColor;
      UBYTE r,g,b;
      tmpColor=GetRGB4(myScreen->ViewPort.ColorMap,i);
      cmap[i].red = (tmpColor >> 8) & 0x0F;
      cmap[i].red|= (cmap[i].red << 4);
      cmap[i].green = (tmpColor >> 4) & 0x0F;
      cmap[i].green|= (cmap[i].green<<4);
      cmap[i].blue = (tmpColor >> 0) & 0x0F;
      cmap[i].blue|=(cmap[i].blue<<4);
    }
  clip_ior->io_Data=(STRPTR)&cmap;
  clip_ior->io_Length=sizeof(ColorMap);
  clip_ior->io_Command=CMD_WRITE;
  DoIO((struct IORequest *)clip_ior);

  // Write CAMG
  clipboard_write_long((long *)"CAMG");
  clipboard_write_long(&camglength);
  clipboard_write_long(&modeflags);

  clipboard_write_long((long *)"DPI ");
  clipboard_write_long(&dpiLength);
  clipboard_write_long(&dpiData);

  // Write BODY
  clipboard_write_long((long *)"BODY");
  clipboard_write_long(&bodylength);
  for (i=0;i<myWindow->RPort->BitMap->Rows;i++)
    {
      for (j=0;j<myWindow->RPort->BitMap->Depth;j++)
        {
          clip_ior->io_Data=(PLANEPTR)&myWindow->RPort->BitMap->Planes[j][&myWindow->RPort->BitMap->BytesPerRow*i];
          clip_ior->io_Length=&myWindow->RPort->BitMap->BytesPerRow;
          clip_ior->io_Command=CMD_WRITE;
          DoIO((struct IORequest *)clip_ior);
        }
    }

  // Inform clipboard we're done.
  clip_ior->io_Command=CMD_UPDATE;
  DoIO((struct IORequest *)clip_ior);
}