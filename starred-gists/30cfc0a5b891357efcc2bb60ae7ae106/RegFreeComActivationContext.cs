// I worked on a C# WPF application that used C++/CLI application that, in turn,
//    used regfree COM component.
// I'm a huge fan of automated tests, so I wanted to find a way how to run integration tests given
//    the conditions above. I managed to find a way to do it. In short:
//    1. Disable shadow copying, because the modules need to be near each other
//    2. Disable parallelization
//       (use provided xunit.runner.json to achieve that, place it in the root of your test project)
//    3. Make tests run in Single Thread Apartment instead of default MTA by using the Xunit.StaFact
//          (see TestSample.cs)
//    4. Use a magical utility (from this file) to prepare activation context to use COM components.
//       To do that, carefully read comments and linked articles and prepare your project and 
//       regfreecom.manifest

using System;
using System.ComponentModel;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security;

namespace Utility
{
   // A quick guide to Registration-Free COM in .Net–and how to Unit Test it
   // http://blog.functionalfun.net/2012/09/a-quick-guide-to-registration-free-com.html
   // I used one manifest (regfreecom.manifest) for all the assembies 
   //   (included it in the test project as a link to the production one and set
   //   CopyToOutputDirectory), did not do anything with copying dll,
   //   because they're copied automatically during the build
   
   // more about ActivationContext:
   // Programming the Activation Context API
   // http://www.mazecomputer.com/sxs/help/sxsapi3.htm

   // I also tried to embed the manifest into dll, but it didn't work
   // https://stackoverflow.com/questions/9162817/registration-free-com-from-asp-net?rq=1
   // https://stackoverflow.com/a/5917710/847363

   internal class RegFreeComActivationContext : IDisposable
   {
      private IntPtr _cookie;
      private IntPtr _hActCtx;

      /// Mentioned in regfreecom.manifest assemblies MUST be near the manifest
      public RegFreeComActivationContext()
      {
         string testsAssemblyPath = Assembly.GetExecutingAssembly().Location;
         activateRegFreeComContext(Path.Combine(Path.GetDirectoryName(testsAssemblyPath), "regfreecom.manifest"));
      }

      public void Dispose()
      {
         UnsafeNativeMethods.DeactivateActCtx(0, _cookie);
         UnsafeNativeMethods.ReleaseActCtx(_hActCtx);
      }

      private void activateRegFreeComContext(string manifestPath)
      {
         var context = new UnsafeNativeMethods.ACTCTX
         {
            cbSize = Marshal.SizeOf(typeof(UnsafeNativeMethods.ACTCTX))
         };

         // Check size for x64 and x86 respectively
         if (context.cbSize != 0x34 && context.cbSize != 0x20)
            throw new Exception("ACTCTX.cbSize is wrong");
         
         context.lpSource = manifestPath;
      
         _hActCtx = UnsafeNativeMethods.CreateActCtx(ref context);
         if (_hActCtx == (IntPtr)(-1))
         {
            throw new Win32Exception(Marshal.GetLastWin32Error());
         }
      
         if (!UnsafeNativeMethods.ActivateActCtx(_hActCtx, out _cookie))
         {
            throw new Win32Exception(Marshal.GetLastWin32Error());
         }
      }
   }

   [SuppressUnmanagedCodeSecurity]
   internal static class UnsafeNativeMethods
   {
      // Activation Context API Functions
      [DllImport("Kernel32.dll", SetLastError = true, EntryPoint = "CreateActCtxW")]
      internal extern static IntPtr CreateActCtx(ref ACTCTX actctx);

      [DllImport("Kernel32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      internal static extern bool ActivateActCtx(IntPtr hActCtx, out IntPtr lpCookie);

      [DllImport("kernel32.dll", SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      internal static extern bool DeactivateActCtx(int dwFlags, IntPtr lpCookie);

      [DllImport("Kernel32.dll", SetLastError = true)]
      internal static extern void ReleaseActCtx(IntPtr hActCtx);

      // Activation context structure
      [StructLayout(LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Unicode)]
      internal struct ACTCTX
      {
         public Int32 cbSize;
         public UInt32 dwFlags;
         public string lpSource;
         public UInt16 wProcessorArchitecture;
         public UInt16 wLangId;
         public string lpAssemblyDirectory;
         public string lpResourceName;
         public string lpApplicationName;
         public IntPtr hModule;
      }
   }
}
