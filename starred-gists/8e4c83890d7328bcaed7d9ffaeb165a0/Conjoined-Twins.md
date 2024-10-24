# Conjoined Twins
IFTTT-style application actions using auditing and scheduled tasks under Windows

[![Conjoined Twins IFTTT-style application actions PowerShell script demo](https://i.imgur.com/xksCV3w.gif)](https://i.imgur.com/xksCV3w.gifv)

## How it works
The script audits a _trigger_ application to make it raise an event when it's executed, then schedules a task to run an _action_ command on that event. For example an automation script, or a batch file, or another app.

### Advantages

- Action is always conjoined with the trigger app, even when it starts from opening a file or from another script

- No additional thing running in the background, polling every few seconds to see if your trigger app has started

- Easily disable/enable in Task Scheduler

### Limitations

- You may not have permissions to audit some Windows executables

- Slight lag after the trigger before the action runs

- False positive when clicking properties on your trigger app the action is executed. 

## Usage

Run from gist:

```powershell
PS:>[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
PS:>iex ((new-object net.webclient).DownloadString('https://gist.github.com/akaleeroy/01ddea07dc51bb2b0509/raw/conjoinedtwins.ps1'))
```
The script first asks you for the trigger application - this is the one you want to bind the action to.
You can type in a path or hit Enter and browse for it with a GUI dialog.

Then it asks you for the action - what you want to start together with the trigger application.

Finally you must enter a task name - so you can find it in Task Scheduler.
