Observable.FromEvent<SensorReadingEventArgs<CompassReading>>(compass, "CurrentValueChanged")
          .BufferWithTime(TimeSpan.FromSeconds(2))
          .SelectMany(events => events.Select(e => e.EventArgs.SensorReading.TrueHeading))