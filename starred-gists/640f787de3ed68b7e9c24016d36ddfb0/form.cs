using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace tosproxy
{
    /// <summary>
    /// Interaction logic for ProcessChooser.xaml
    /// </summary>
    public partial class ProcessChooser : Window
    {
        public List<Process> ProcessList {get; private set;}

        public ProcessChooser()
        {
            GetProcessList();
            this.DataContext = this;
            InitializeComponent();
        }

        private void GetProcessList()
        {
            ProcessList = Process.GetProcesses().ToList();

            Trace.WriteLine("PROCESS LIST:\n");
            Trace.WriteLine(ProcessList.First().Id);
        }
    }
}
