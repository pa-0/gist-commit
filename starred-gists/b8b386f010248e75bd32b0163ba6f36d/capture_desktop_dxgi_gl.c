//
// First download glcorearb.h, wglext.h and platform.h files
// Then compile: cl.exe capture_desktop_dxgi_gl.c /I. d3d11.lib dxgi.lib dxguid.lib gdi32.lib opengl32.lib user32.lib dwmapi.lib
//

#define COBJMACROS
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <d3d11.h>
#include <dxgi1_2.h>

#include <GL/gl.h>
#include <GL/glcorearb.h> // get from https://www.khronos.org/registry/OpenGL/api/GL/glcorearb.h
#include <GL/wglext.h>    // get from https://www.khronos.org/registry/OpenGL/api/GL/wglext.h
// also put platform.h in KHR folder from https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h

#include <string.h>
#include <stdint.h>
#include <intrin.h>

#define Assert(cond) do { if (!(cond)) __debugbreak(); } while (0)
#define AssertHR(hr) Assert(SUCCEEDED(hr))

static PFNWGLDXOPENDEVICENVPROC wglDXOpenDeviceNV;
static PFNWGLDXREGISTEROBJECTNVPROC wglDXRegisterObjectNV;
static PFNWGLDXLOCKOBJECTSNVPROC wglDXLockObjectsNV;
static PFNWGLDXUNLOCKOBJECTSNVPROC wglDXUnlockObjectsNV;

static IDXGIOutputDuplication* dxgiDuplication;
static ID3D11DeviceContext* d3d11Context;
static ID3D11Texture2D* d3d11Texture;

static HANDLE dxDevice;
static HANDLE dxTexture;

static GLuint openglTexture;

static uint32_t captureWidth;
static uint32_t captureHeight;

static void APIENTRY OpenGLDebugCallback(GLenum source, GLenum type, GLuint id,
    GLenum severity, GLsizei length, const GLchar* message, const void* user)
{
    OutputDebugStringA(message);
    OutputDebugStringA("\n");

    if (severity == GL_DEBUG_SEVERITY_LOW_ARB ||
        severity == GL_DEBUG_SEVERITY_MEDIUM_ARB ||
        severity == GL_DEBUG_SEVERITY_HIGH_ARB)
    {
        Assert(0);
    }
}

static int StringsAreEqual(const char* src, const char* dst, size_t dstlen)
{
    while (*src && dstlen-- && *dst)
    {
        if (*src++ != *dst++)
        {
            return 0;
        }
    }

    return (dstlen && *src == *dst) || (!dstlen && *src == 0);
}

static HGLRC CreateOpenGLContext(HDC dc)
{
    PFNWGLCHOOSEPIXELFORMATARBPROC wglChoosePixelFormatARB = NULL;
    PFNWGLCREATECONTEXTATTRIBSARBPROC wglCreateContextAttribsARB = NULL;

    HWND dummyWnd = CreateWindowExW(0, L"STATIC", L"DummyWindow", WS_OVERLAPPED,
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        NULL, NULL, NULL, NULL);
    Assert(dummyWnd);

    HDC dummyDc = GetDC(dummyWnd);
    Assert(dummyDc);

    PIXELFORMATDESCRIPTOR pfd =
    {
        .nSize = sizeof(pfd),
        .nVersion = 1,
        .dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE,
        .iPixelType = PFD_TYPE_RGBA,
        .cColorBits = 24,
    };

    int format = ChoosePixelFormat(dummyDc, &pfd);
    Assert(format);

    BOOL ok = DescribePixelFormat(dummyDc, format, sizeof(pfd), &pfd);
    Assert(ok);

    ok = SetPixelFormat(dummyDc, format, &pfd);
    Assert(ok);

    HGLRC dummyRc = wglCreateContext(dummyDc);
    Assert(dummyRc);

    ok = wglMakeCurrent(dummyDc, dummyRc);
    Assert(ok);

    PFNWGLGETEXTENSIONSSTRINGARBPROC wglGetExtensionsStringARB = (void*)wglGetProcAddress("wglGetExtensionsStringARB");
    Assert(wglGetExtensionsStringARB);

    const char* ext = wglGetExtensionsStringARB(dummyDc);

    if (ext)
    {
        const char* start = ext;
        for (;;)
        {
            while (*ext != 0 && *ext != ' ')
            {
                ext++;
            }

            size_t length = ext - start;
            if (StringsAreEqual("WGL_ARB_pixel_format", start, length))
            {
                wglChoosePixelFormatARB = (void*)wglGetProcAddress("wglChoosePixelFormatARB");
            }
            else if (StringsAreEqual("WGL_ARB_create_context", start, length))
            {
                wglCreateContextAttribsARB = (void*)wglGetProcAddress("wglCreateContextAttribsARB");
            }
            else if (StringsAreEqual("WGL_NV_DX_interop2", start, length))
            {
                wglDXOpenDeviceNV = (void*)wglGetProcAddress("wglDXOpenDeviceNV");
                wglDXRegisterObjectNV = (void*)wglGetProcAddress("wglDXRegisterObjectNV");
                wglDXLockObjectsNV = (void*)wglGetProcAddress("wglDXLockObjectsNV");
                wglDXUnlockObjectsNV = (void*)wglGetProcAddress("wglDXUnlockObjectsNV");
            }

            if (*ext == 0)
            {
                break;
            }

            ext++;
            start = ext;
        }
    }

    wglMakeCurrent(NULL, NULL);
    wglDeleteContext(dummyRc);
    ReleaseDC(dummyWnd, dummyDc);
    DestroyWindow(dummyWnd);

    Assert(wglChoosePixelFormatARB);
    Assert(wglCreateContextAttribsARB);
    Assert(wglDXOpenDeviceNV);
    Assert(wglDXRegisterObjectNV);
    Assert(wglDXLockObjectsNV);
    Assert(wglDXUnlockObjectsNV);

    static const int pixelFormatAttrib[] =
    {
        WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
        WGL_ACCELERATION_ARB,   WGL_FULL_ACCELERATION_ARB,
        WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
        WGL_DOUBLE_BUFFER_ARB,  GL_TRUE,
        WGL_PIXEL_TYPE_ARB,     WGL_TYPE_RGBA_ARB,
        WGL_COLOR_BITS_ARB,     24,
        0,
    };

    UINT formats;
    ok = wglChoosePixelFormatARB(dc, pixelFormatAttrib, NULL, 1, &format, &formats);
    Assert(ok && formats > 0);

    ok = DescribePixelFormat(dc, format, sizeof(pfd), &pfd);
    Assert(ok);

    ok = SetPixelFormat(dc, format, &pfd);
    Assert(ok);

    static const int contextAttrib[] =
    {
        WGL_CONTEXT_MAJOR_VERSION_ARB, 3,
        WGL_CONTEXT_MINOR_VERSION_ARB, 3,
        WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
        WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
    };

    HGLRC rc = wglCreateContextAttribsARB(dc, NULL, contextAttrib);
    Assert(rc);

    ok = wglMakeCurrent(dc, rc);
    Assert(ok);

    PFNGLGETSTRINGIPROC glGetStringi = (void*)wglGetProcAddress("glGetStringi");
    Assert(glGetStringi);

    GLint extCount;
    glGetIntegerv(GL_NUM_EXTENSIONS, &extCount);
    for (GLint i = 0; i < extCount; i++)
    {
        if (strcmp("GL_ARB_debug_output", glGetStringi(GL_EXTENSIONS, i)) == 0)
        {
            PFNGLDEBUGMESSAGECALLBACKARBPROC glDebugMessageCallbackARB = (void*)wglGetProcAddress("glDebugMessageCallbackARB");
            Assert(glDebugMessageCallbackARB);

            glDebugMessageCallbackARB(OpenGLDebugCallback, NULL);
            glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);
            break;
        }
    }

    return rc;
}

// this will use primary monitor of main GPU in system
static void CreateDesktopCapture()
{
    HRESULT hr;

    ID3D11Device* device;
    hr = D3D11CreateDevice(NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, 0, NULL, 0, D3D11_SDK_VERSION, &device, NULL, &d3d11Context);
    AssertHR(hr);

    IDXGIDevice* dxgiDevice;
    hr = ID3D11Device_QueryInterface(device, &IID_IDXGIDevice, &dxgiDevice);
    AssertHR(hr);

    IDXGIAdapter* adapter;
    hr = IDXGIDevice_GetAdapter(dxgiDevice, &adapter);
    AssertHR(hr);

    IDXGIOutput* output;
    hr = IDXGIAdapter_EnumOutputs(adapter, 0, &output);
    AssertHR(hr);

    IDXGIOutput1* output1 = NULL;
    hr = IDXGIOutput_QueryInterface(output, &IID_IDXGIOutput1, &output1);
    AssertHR(hr);

    hr = IDXGIOutput1_DuplicateOutput(output1, (IUnknown*)device, &dxgiDuplication);
    AssertHR(hr);

    DXGI_OUTDUPL_DESC desc;
    IDXGIOutputDuplication_GetDesc(dxgiDuplication, &desc);

    captureWidth = desc.ModeDesc.Width;
    captureHeight = desc.ModeDesc.Height;

    D3D11_TEXTURE2D_DESC texDesc =
    {
        .Width = captureWidth,
        .Height = captureHeight,
        .MipLevels = 1,
        .ArraySize = 1,
        .Format = DXGI_FORMAT_B8G8R8A8_UNORM,
        .SampleDesc = { 1, 0 },
        .Usage = D3D11_USAGE_DEFAULT,
    };

    hr = ID3D11Device_CreateTexture2D(device, &texDesc, NULL, &d3d11Texture);
    AssertHR(hr);

    dxDevice = wglDXOpenDeviceNV(device);
    Assert(dxDevice);

    glGenTextures(1, &openglTexture);

    dxTexture = wglDXRegisterObjectNV(dxDevice, d3d11Texture, openglTexture, GL_TEXTURE_2D, WGL_ACCESS_READ_ONLY_NV);
    Assert(dxTexture);

    BOOL ok = wglDXLockObjectsNV(dxDevice, 1, &dxTexture);
    Assert(ok);

    IDXGIOutput1_Release(output1);
    IDXGIOutput_Release(output);
    IDXGIAdapter_Release(adapter);
    IDXGIDevice_Release(dxgiDevice);
    ID3D11Device_Release(device);
}

static void CaptureDesktopFrame()
{
    DXGI_OUTDUPL_FRAME_INFO info;
    IDXGIResource* resource;
    HRESULT hr = IDXGIOutputDuplication_AcquireNextFrame(dxgiDuplication, 0, &info, &resource);
    if (SUCCEEDED(hr))
    {
        ID3D11Texture2D* resourceTexture;
        hr = IDXGIResource_QueryInterface(resource, &IID_ID3D11Texture2D, &resourceTexture);
        AssertHR(hr);

        BOOL ok = wglDXUnlockObjectsNV(dxDevice, 1, &dxTexture);
        Assert(ok);

        ID3D11DeviceContext_CopyResource(d3d11Context, (ID3D11Resource*)d3d11Texture, (ID3D11Resource*)resourceTexture);

        ok = wglDXLockObjectsNV(dxDevice, 1, &dxTexture);
        Assert(ok);

        ID3D11Texture2D_Release(resourceTexture);
        IDXGIResource_Release(resource);
        IDXGIOutputDuplication_ReleaseFrame(dxgiDuplication);
    }
}

static LRESULT CALLBACK WindowProc(HWND wnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
    switch (msg)
    {
    case WM_SIZE:
        glViewport(0, 0, LOWORD(lparam), HIWORD(lparam));
        return 0;

    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(wnd, msg, wparam, lparam);
}

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev, LPSTR cmdline, int cmdshow)
{
    WNDCLASSEXW wc =
    {
        .cbSize = sizeof(wc),
        .lpfnWndProc = WindowProc,
        .hInstance = instance,
        .hIcon = LoadIconA(NULL, IDI_APPLICATION),
        .hCursor = LoadCursorA(NULL, IDC_ARROW),
        .lpszClassName = L"CaptureDesktop",
    };

    BOOL ok = RegisterClassExW(&wc);
    Assert(ok);

    HWND wnd = CreateWindowExW(WS_EX_APPWINDOW, wc.lpszClassName, L"Capture Desktop",
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
        NULL, NULL, wc.hInstance, NULL);
    Assert(wnd);

    HDC dc = GetDC(wnd);
    Assert(dc);

    CreateOpenGLContext(dc);
    CreateDesktopCapture();

    PFNGLCREATESHADERPROC glCreateShader = (void*)wglGetProcAddress("glCreateShader");
    PFNGLCREATEPROGRAMPROC glCreateProgram = (void*)wglGetProcAddress("glCreateProgram");
    PFNGLATTACHSHADERPROC glAttachShader = (void*)wglGetProcAddress("glAttachShader");
    PFNGLLINKPROGRAMPROC glLinkProgram = (void*)wglGetProcAddress("glLinkProgram");
    PFNGLUSEPROGRAMPROC glUseProgram = (void*)wglGetProcAddress("glUseProgram");
    PFNGLSHADERSOURCEPROC glShaderSource = (void*)wglGetProcAddress("glShaderSource");
    PFNGLCOMPILESHADERPROC glCompileShader = (void*)wglGetProcAddress("glCompileShader");
    PFNGLGETSHADERINFOLOGPROC glGetShaderInfoLog = (void*)wglGetProcAddress("glGetShaderInfoLog");
    PFNGLGENVERTEXARRAYSPROC  glGenVertexArrays = (void*)wglGetProcAddress("glGenVertexArrays");
    PFNGLBINDVERTEXARRAYPROC glBindVertexArray = (void*)wglGetProcAddress("glBindVertexArray");

    const char* vertexShader =
        "#version 330 core                                   \n"
        "out vec2 vTexCoord;                                 \n"
        "void main()                                         \n"
        "{                                                   \n"
        "    float x = -1.0 + float((gl_VertexID & 1) << 2); \n"
        "    float y = -1.0 + float((gl_VertexID & 2) << 1); \n"
        "    vTexCoord = vec2(x + 1.0, 1.0 - y) * 0.5;       \n"
        "    gl_Position = vec4(x, y, 0, 1);                 \n"
        "}                                                   \n"
        ;

    const char* fragmentShader =
        "#version 330 core                         \n"
        "in vec2 vTexCoord;                        \n"
        "uniform sampler2D uTexture;               \n"
        "layout (location = 0) out vec4 oColor;    \n"
        "void main()                               \n"
        "{                                         \n"
        "   oColor = texture(uTexture, vTexCoord); \n"
        "}                                         \n"
        ;

    GLuint vs = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vs, 1, &vertexShader, NULL);
    glCompileShader(vs);

    GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fs, 1, &fragmentShader, NULL);
    glCompileShader(fs);

    GLuint program = glCreateProgram();
    glAttachShader(program, vs);
    glAttachShader(program, fs);
    glLinkProgram(program);

    glUseProgram(program);

    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    ShowWindow(wnd, SW_SHOWDEFAULT);

    for (;;)
    {
        MSG msg;
        if (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE))
        {
            if (msg.message == WM_QUIT)
            {
                break;
            }
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
            continue;
        }

        // capture next frame if available, output is GL texture in openglTexture handle
        CaptureDesktopFrame();

        // render it to screen, by triangle covering full screen
        // assume texture sample  is set up with correct slot in fragment shader (0 by default)
        glBindTexture(GL_TEXTURE_2D, openglTexture);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        // display & vsync
        SwapBuffers(dc);
        DwmFlush();
    }
}
