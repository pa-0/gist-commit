using System;
using System.Diagnostics;
using System.Linq;
using Microsoft.Devices.Sensors;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Reactive;

namespace Rx_Compass_Smoothing
{
    public partial class MainPage : PhoneApplicationPage
    {
        Compass compass = new Compass();

        public MainPage()
        {
            InitializeComponent();

            Observable.FromEvent<SensorReadingEventArgs<CompassReading>>(compass, "CurrentValueChanged")
                .BufferWithTime(TimeSpan.FromSeconds(2))
                .SelectMany(events => events.Select(e => e.EventArgs.SensorReading.TrueHeading))
                .Subscribe(headings => Debug.WriteLine(string.Format("Buffered: {0}", headings)));
                
            compass.Start();
        }
    }
}
