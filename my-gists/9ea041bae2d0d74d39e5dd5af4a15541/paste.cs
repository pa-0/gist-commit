using System;
using System.Windows.Forms;

namespace jpf {
    class paste {
        [STAThread]
        public static int Main(string[] args) {
            Console.Write(Clipboard.GetText());
            return 0;
        }
    }
}