using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

/// <summary>
/// Hidden form that can provide notification when clipboard is updated.
/// </summary>
public class ClipboardMonitor : Form
{
    #region Externs

    private const int WM_CLIPBOARDUPDATE = 0x031D;
    private static readonly IntPtr HWND_MESSAGE = new IntPtr(-3);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool AddClipboardFormatListener(IntPtr hwnd);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

    #endregion

    #region Public

    public ClipboardMonitor()
    {
        SetParent(Handle, HWND_MESSAGE);
        AddClipboardFormatListener(Handle);
    }

    /// <summary>
    /// Event occurs when there is a change in clipboard.
    /// Use <seealso cref="Clipboard"/> to access the clipboard contents.
    /// </summary>
    public event EventHandler ClipboardUpdated;

    #endregion

    #region Overrides

    protected override void WndProc(ref Message message)
    {
        if (message.Msg == WM_CLIPBOARDUPDATE)
        {
            EventHandler handler = ClipboardUpdated;
            if (handler != null) handler(this, EventArgs.Empty);
        }
        base.WndProc(ref message);
    }

    #endregion
}