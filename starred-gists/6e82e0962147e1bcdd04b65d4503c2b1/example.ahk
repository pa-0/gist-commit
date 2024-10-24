
;
; REQUIRED
;

ytdl.Path := "D:\CLI\youtube"
; Path of yt-dlp.exe


;
; OPTIONAL
; The values below represent the defaults
;

; FFmpeg directory
ytdl.FFmpeg := "..\FFmpeg"

; Simple bypass
ytdl.GeoBypass := true

; Via country code
; ytdl.GeoBypass := "US"

; From an IP block (CDIR)
; ytdl.GeoBypass := "35.190.247.0/24"

; Embed metadata?
ytdl.Metadata := true

; Time between downloads
ytdl.SleepInterval := 0

; Audio options

; 'm4a'/'opus' natively
ytdl.Audio.Format := "m4a"
; Others need recoding (like mp3)

; Thumbnail?
ytdl.Audio.Thumbnail := false

; Video options

;                        mkv
;                        mp4
;                        ogg
;                       webm
ytdl.Video.Container := "mp4"

;              144p =  144
;              240p =  240
;              360p =  360
;              480p =  480
;                HD =  720
;               FHD = 1080
;               QHD = 1440
;                4k = 2160
;                8k = 4320
ytdl.Video.Quality := 1080

; Thumbnail?
ytdl.Video.Thumbnail := true


#NoEnv
EnvGet UserProfile, USERPROFILE
MusicDir := UserProfile "\Music"
VideoDir := UserProfile "\Videos"

GroupAdd Browsers, ahk_exe chrome.exe
GroupAdd Browsers, ahk_exe firefox.exe
GroupAdd Browsers, ahk_exe msedge.exe
GroupAdd Browsers, ahk_exe opera.exe


return ; End of auto-execute


#If WinActive("ahk_group Browsers")
	!y::ytdl(MusicDir, 1)
	^y::ytdl(VideoDir, 2)
#If
