// example of IDropTarget implementation in C
// allows dropping of files and INETURL from clipboard
// can be expanded for more use cases
// https://learn.microsoft.com/en-us/windows/win32/api/oleidl/nn-oleidl-idroptarget

#include <stdint.h>

#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>
#include <shlobj_core.h>

#pragma comment(lib, "User32.lib")
#pragma comment(lib, "Ole32.lib")
#pragma comment(lib, "Shell32.lib")

/*
  General Notes:

  This is the very basics to set up a window as a drop target for dragging/dropping capabilities
   
  ** Docs say that programs must pump messages (with GetMessage / PeekMessage) **
  otherwise the application will hang when objects are dragged over drop target (until application closes)

  Also, you typically do not want to do any expensive code in the implementations of
  IDropTarget, it will hang your software (and possibly the shell).
  Some people push it as a windows message then handle / forward to actual application from there
*/

//////////////////////////////////
// Globals 

int32_t  g_running = 1;
uint64_t g_drag_ref_count = 0;


//////////////////////////////////
// IDropTarget Implementation

// Inherited from IUnknown
ULONG
IDropTarget_AddRef__impl(IDropTarget* _this)
{
  return InterlockedIncrement64(&g_drag_ref_count);
}

// Inherited from IUnknown
ULONG
IDropTarget_Release__impl(IDropTarget* _this)
{
  /*
   NOTE(agw): Docs say "interface pointer must release itself" when ref_count == 0
  */

  uint64_t result = InterlockedDecrement64(&g_drag_ref_count);

  if (g_drag_ref_count == 0)
  {
    // agw: Release associated data
  }

  return result;
}

/*
 NOTE(agw): STDMETHODIMP expands to => "HRESULT __export __stdcall" in <winnt.h>
*/

// Inherited from IUnknown
STDMETHODIMP
IDropTarget_QueryInterface__impl(IDropTarget* _this, REFIID riid, void **ppv)
{
  HRESULT result = E_NOINTERFACE;
  *ppv = NULL;

  if (riid == &IID_IUnknown || riid == &IID_IDropTarget) 
  {
    *ppv = (IUnknown *)_this;
    _this->lpVtbl->AddRef(_this);
    result = S_OK;
  }

  return result;
}

STDMETHODIMP
IDropTarget_DragEnter__impl(IDropTarget* _this, IDataObject *pDataObj, DWORD grfKeyState, POINTL pt, DWORD *in_out_effect)
{
  /*
    pdw_effect will pass in 0x7, you AND your desired use (copy/move data)
  */
  *in_out_effect &= DROPEFFECT_COPY;
  return S_OK;
}

STDMETHODIMP
IDropTarget_DragOver__impl(IDropTarget* _this, DWORD key_state, POINTL pt, DWORD  *in_out_effect)
{
  /*
    pdw_effect will pass in 0x7, you AND your desired use (copy/move data)
  */
  *in_out_effect &= DROPEFFECT_COPY;
  return S_OK;
}

STDMETHODIMP
IDropTarget_DragLeave__impl(IDropTarget* _this)
{
  return S_OK;
}

/*
  NOTE(agw): Actual dropping code (on mouse release)
  Here I just show a couple of examples:
  - INETURL (ex. drag and drop image from web browser)
    - HDROP   (ex. drag and drop       from file explorer)
*/

STDMETHODIMP
DragDrop__impl(IDropTarget* _this, IDataObject *data_object, DWORD key_state, POINTL ptl, DWORD *in_out_effect)
{
  int32_t taken = 0;

  // agw: Try INET

  if (taken == 0)
  {
    CLIPFORMAT inet_clip_format = (CLIPFORMAT)RegisterClipboardFormat(CFSTR_INETURL);
    FORMATETC istream_format =
    {
      inet_clip_format,
      NULL,
      DVASPECT_CONTENT,
      -1,
      TYMED_HGLOBAL
    };

    STGMEDIUM storage_medium = {};

    HRESULT res = data_object->lpVtbl->GetData(data_object, &istream_format, &storage_medium);

    if (res >= 0) 
    {
      taken = 1;
      char* url = GlobalLock(storage_medium.hGlobal);

      if (url)
      {
        /*
          agw:
         Just for an example.
          Really, you don't want to block here (copy for later use, push to command queue, etc.)
        */
        MessageBox(0, url, 0, MB_OK);

        GlobalUnlock(storage_medium.hGlobal);
      }

      ReleaseStgMedium(&storage_medium);
    }
  }

  // agw: Try file drop

  if (taken == 0)
  {

    FORMATETC hdrop_format =
    {
      CF_HDROP,
      NULL,
      DVASPECT_CONTENT,
      -1,
      TYMED_HGLOBAL
    };

    STGMEDIUM storage_medium = {};
    HRESULT res = data_object->lpVtbl->GetData(data_object, &hdrop_format, &storage_medium);

    if (res >= 0)
    {
      taken = 1;

      /*
        NOTE(agw): Do what you wish here. Here I am just grabbing all the paths of the dropped files
      */

      HDROP drop_handle = (HDROP)storage_medium.hGlobal;
      UINT files_count  = DragQueryFile(drop_handle, 0xFFFFFFFF, NULL, 0);

      for (UINT i = 0; i < files_count; i++) 
      {
        TCHAR file_path[MAX_PATH];

        UINT character_count = DragQueryFile(drop_handle, i, file_path, MAX_PATH);

        if (character_count > 0 && character_count < MAX_PATH) 
        {
          /*
            agw: 
           Just for an example.
           Really, you don't want to block here (copy for later use, push to command queue, etc.)
          */

          MessageBox(0, file_path, 0, MB_OK);
        }
      }

      ReleaseStgMedium(&storage_medium);
    }
  }


  *in_out_effect &= DROPEFFECT_COPY;
  return S_OK;
}

//////////////////////////////////
// ~ Basic Window Setup 

LRESULT CALLBACK 
WindowProc(HWND wnd, UINT msg, WPARAM w_param, LPARAM l_param)
{

  switch (msg)
  {
    case WM_CLOSE:
    {
      g_running = 0;
    } break;
    case WM_DESTROY:
    {
      // Perform cleanup tasks, if that is your thing
      PostQuitMessage(0);
    } break;
  }

  return DefWindowProc(wnd, msg, w_param, l_param);
}

int WINAPI 
WinMain(HINSTANCE h_instance, HINSTANCE prev_instance, LPSTR cmd_line, int cmd_show) 
{
  HRESULT res = 0;

  //////////////////////////////////
  // ~ Open window 

  char CLASS_NAME[]  = "Drop Target Example";

  WNDCLASS wc = { };
  {
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = h_instance;
    wc.lpszClassName = CLASS_NAME;
  }

  RegisterClass(&wc);

  HWND hwnd = CreateWindowA(
  CLASS_NAME,
  "Drop Target Example",
  WS_OVERLAPPEDWINDOW,
  CW_USEDEFAULT, CW_USEDEFAULT,
  CW_USEDEFAULT, CW_USEDEFAULT,
  0,
  0,
  h_instance,
    0
  );

  ShowWindow(hwnd, cmd_show);
  UpdateWindow(hwnd);


  //////////////////////////////////
  // ~ Implement / Register Drop Target 

  /*
   NOTE(agw): Must use OleInitialize, _not_ CoInitialize
  */
  res = OleInitialize(0);

  IDropTarget drop_target = {};
  {
    /*
     NOTE(agw): you may want to save this and release when ref_count == 0
    */
    IDropTargetVtbl* vtbl = (IDropTargetVtbl*)malloc(sizeof(IDropTargetVtbl));
    drop_target.lpVtbl = vtbl;

    drop_target.lpVtbl->AddRef         = IDropTarget_AddRef__impl;
    drop_target.lpVtbl->Release        = IDropTarget_Release__impl;
    drop_target.lpVtbl->QueryInterface = IDropTarget_QueryInterface__impl;
    drop_target.lpVtbl->DragEnter      = IDropTarget_DragEnter__impl;
    drop_target.lpVtbl->DragOver       = IDropTarget_DragOver__impl;
    drop_target.lpVtbl->DragLeave      = IDropTarget_DragLeave__impl;
    drop_target.lpVtbl->Drop           = DragDrop__impl;
  }

  res = RegisterDragDrop(hwnd, &drop_target);

  //////////////////////////////////
  // ~ Main Loop 

  while (g_running)
  {
    MSG msg = {};
    while(GetMessage(&msg, NULL, 0, 0) != 0)
    { 
      TranslateMessage(&msg); 
      DispatchMessage(&msg); 
    } 
  }

  //////////////////////////////////
  // ~ Freeing (if you care about this kind of thing) 

  OleUninitialize();

  return 0;
}