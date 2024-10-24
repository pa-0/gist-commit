@(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & timeout /t 7 & exit /b

# CLEAR THOSE ANNOYING MEDIA PLAYING STEAM OVERLAY BROWSER WINDOWS YOU FORGOT ABOUT - BY AVEYO

$found = $false; $utf8 = new-object Text.UTF8Encoding $false
$userdata = join-path (gp HKCU:\SOFTWARE\Valve\Steam SteamPath -ea 0).SteamPath 'userdata'; pushd $userdata;
dir -rec -file localconfig.vdf |% {
  $cfg = $_; $data = [io.file]::ReadAllLines($cfg, $utf8); $ok = $true
  if (($data |% {$_ -like '*OverlaySavedData*'}) -notcontains $true) { echo "$cfg : no steam overlay saved data"; $ok = $false }
  if ($ok) { if (get-process -name Steam -ea 0) { start -wait "$(split-path $userdata)\Steam.exe" -args '-shutdown' } }
  if ($ok) { while (get-process -name Steam -ea 0) { sleep 1; echo "." } }
  if ($ok) { del -force $cfg -ea 0; if (test-path $cfg) { echo "$cfg : cannot write to file"; $ok = $false } } 
  if ($ok) { $data |where {$_ -notlike '*OverlaySavedData*'} |% { [io.file]::AppendAllLines($cfg, [string[]]$_, $utf8) } }
  if ($ok) { write-host "$cfg : steam overlay saved data cleared" }
}

# can enter directly in powershell 