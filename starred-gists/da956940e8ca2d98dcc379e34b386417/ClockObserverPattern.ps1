class Subject {

    hidden [System.Collections.ArrayList]$observers

    Subject() {
        $this.observers = New-Object System.Collections.ArrayList

    }

    Attach([Observer]$o) { $this.observers.Add($o)    }

    Detach([Observer]$o) { $this.observers.Remove($o) }

    Notify() {
        foreach($observer in $this.observers) {
            $observer.Update($this)
        }
        '' | out-host
    }
}


class Observer {
    Update([Subject]$subject) {}
}

class ClockTimer : Subject {
    hidden [datetime]$currentTime

    [int] GetHour()      { return $this.currentTime.Hour   }
    [int] GetMinute()    { return $this.currentTime.Minute }
    [int] GetSecond()    { return $this.currentTime.Second }
    [datetime] GetFull() { return $this.currentTime}

    Tick() {
        $this.currentTime = Get-Date
        $this.Notify()
    }

    StartTimer() {
        while($true) {
            $this.Tick()
            Start-Sleep 1
        }
    }
}

class DigitalClock : Observer {
    Update([Subject]$subject) {
        $hour = $subject.GetHour()
        $minute = $subject.GetMinute()
        $second = $subject.GetSecond()

        "[Digital Clock] {0}:{1}:{2}" -f $hour, $minute, $second | Out-Host
    }
}

class AnalogClock : Observer {
    Update([Subject]$subject) {
        "[Analog Clock] {0}" -f $subject.GetFull() | Out-Host
    }
}

$timer = [ClockTimer]::new()

$digitalClock = [DigitalClock]::new()
$analogClock = [AnalogClock]::new()

$timer.Attach($digitalClock)
$timer.Attach($analogClock)

$timer.StartTimer()