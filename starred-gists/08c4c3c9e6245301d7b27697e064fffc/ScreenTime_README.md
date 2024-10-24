## `ScreenTime.ahk`

<sub>AKA <code>TB-Timer</code></sub>

### Overview

- This script is a modified AutoHotKey v2 port of RustingSword's v1 script. 
- Everything is rewritten to run using AutoHotKey v2 without issues.
- The GUI is in English and displayed by pressing the right <kbd>CTRL</kbd> key.
- The Total Time no longer includes Idle Time. It is supposed to represent the screen time you have spent actively using your device.
- Total Time is displayed in a bolder, larger font.
  
### Screenshot

<div align=center>
  
![image](https://gist.github.com/user-attachments/assets/02594ebd-8ba6-4c49-b8d9-cd9915f3a1ed)

</div>

### Changes to "timelog.txt" 
- Still saved in the user's Documents folder, this file now has new keys to keep a record and quickly read the time spent in 'hh-mm' format for all previous dates.
- The old v1 script updated the timer every minute. 
  - The script, by design, added 1 minute to a category if a corresponding app was active during the timer update. 
  - The major flaw is that if you spent 59 seconds using an app and then switched to another app, then after one more second, the timer will consider you spent 1 minute using the 2nd app and none using the 1st app.
- A simple solution is to update the timer more often. Ideally, we would want a timer update every second. To prevent excessive and frequent function calls, this new v2 script updates the timer every 20 seconds. The error in tracking is reduced but, of course, not zero.
- Usage category names have been changed to better suit personal needs.