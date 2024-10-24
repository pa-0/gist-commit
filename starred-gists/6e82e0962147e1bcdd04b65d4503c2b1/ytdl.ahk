
; Version: 2023.10.13.1

/*

# Examples

See the file above.

# Dependencies

## yt-dlp

https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe

## FFmpeg

https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z

FFmpeg binaries must be accessible to `yt-dlp` for format conversions.

You can drop them in the folder where yt-dlp.exe resides:

- ffmpeg.exe
- ffplay.exe
- ffprobe.exe

Else, function expects them to be in the same level as yt-dlp binary. Example:

- D:\CLI\FFmpeg
- D:\CLI\yt-dlp

Alternatively, to use an explicit path, set the option:

ytdl.FFmpeg := "D:\Path\to\FFmpeg\bin"

## GetUrl()

https://gist.github.com/anonymous1184/7cce378c9dfdaf733cb3ca6df345b140/raw/GetUrl1.ahk

*/

/**
 * Downloads a video from YouTube.
 *
 * @param {string}  Directory Path to save the downloaded file
 * @param {integer} Mode      1 = Audio, 2 = Video
 */
ytdl(Directory, Mode) {
    if !(FileExist(ytdl.Path) ~= "D") {
        throw Exception("Not a directory", -1, ytdl.Path)
    }
    if (!FileExist(ytdl.Path "\yt-dlp.exe")) {
        throw Exception("yt-dlp.exe was not found.", -1, ytdl.Path)
    }
    if (!FileExist(ytdl.Path "\cache")) {
        FileCreateDir % ytdl.Path "\cache"
    }
    cmd := "yt-dlp.exe"
    Directory := RTrim(Directory, "\")
    loop files, % Directory, D
        Directory := A_LoopFileLongPath "\"
    if !(Directory ~= "\\$") {
        throw Exception("Invalid directory.", -1, Directory)
    }
    if !(Mode ~= "^[12]$") {
        msg := "'Mode' must be either '1' or '2'" "`n"
            . "`n" "1 = Audio"
            . "`n" "2 = Video"
        throw Exception(msg "`n", -1, Mode)
    }
    ytdl.Video.Container := Format("{:L}", ytdl.Video.Container)
    if !(ytdl.Video.Container ~= "^(mkv|mp4|ogg|webm)$") {
        ytdl.Video.Container := "mp4"
    }
    ytdl.Video.Quality := ytdl.Video.Quality
    if !(ytdl.Video.Quality ~= "^(144|240|360|480|720|1080|1440|2160|4320)$") {
        ytdl.Video.Quality := 1080
    }
    if !(url := GetUrl()) {
        MsgBox 0x40010, Error, Couldn't retrieve the URL.
        return
    }
    if (!InStr(url, "youtube.com")) {
        return
    }
    regex := "i)(?=.*v=(?<videoId>[^&]+))?(?=.*list=(?<listId>[^&]+))?"
    RegExMatch(url, regex, _)
    if (!_videoId && !_listId) {
        MsgBox 0x40010, Error, No video or playlist found on the URL.
        return
    }
    isPlaylist := false
    if (_listId && !_videoId) {
        isPlaylist := true
    } else if (_listId && _videoId) {
        MsgBox 0x40024, Playlist, Download the full playlist?
        IfMsgBox Yes
            isPlaylist := true
    }
    if (isPlaylist) {
        Directory .= "%(playlist)s\%(playlist_index)s - "
    }
    Directory .= "%(title)s.%(ext)s"
    ; Options:
    ;; yt-dlp.exe --help
    ; General Options
    cmd .= " --ignore-errors"
    cmd .= " --ignore-config"
    ; Network Options
    cmd .= " --force-ipv4" ; Avoid leaking for split tunnels
    ; Geo restriction
    if (ytdl.GeoBypass = true) {
        cmd .= " --geo-bypass"
    } else if (ytdl.GeoBypass ~= "^\w{2}$") {
        cmd .= " --geo-bypass-country """ ytdl.GeoBypass """"
    } else if (ytdl.GeoBypass ~= "^[\d\.\/]+$") {
        cmd .= " --geo-bypass-ip-block """ ytdl.GeoBypass """"
    }
    ; Video Selection
    cmd .= " --yes-playlist"
    ; Download Options
    cmd .= " --hls-prefer-ffmpeg"
    ; Filesystem Options
    cmd .= " --output """ Directory """"
    cmd .= " --no-overwrites"
    cmd .= " --continue"
    cmd .= " --no-part"
    cmd .= " --cookies """ ytdl.Path "\cache\cookies.txt"""
    cmd .= " --cache-dir """ ytdl.Path "\cache"""
    ; Verbosity
    cmd .= " --no-warnings"
    cmd .= " --console-title"
    cmd .= " --no-call-home"
    ; Workarounds
    cmd .= " --no-check-certificate"
    cmd .= " --prefer-insecure"
    ; User agent:
    ;; Firefox (2023/10) like when reloading page without cache
    cmd .= " --user-agent ""Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/118.0"""
    cmd .= " --referer """ url """"
    cmd .= " --add-header ""Accept-Encoding: gzip, deflate, br"""
    cmd .= " --add-header ""Accept-Language: en-US,en;q=0.5"""
    cmd .= " --add-header ""Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"""
    cmd .= " --add-header ""Cache-Control: no-cache"""
    cmd .= " --add-header ""Connection: keep-alive"""
    cmd .= " --add-header ""DNT: 1"""
    cmd .= " --add-header ""Pragma: no-cache"""
    cmd .= " --add-header ""SEC-FETCH-DEST: document"""
    cmd .= " --add-header ""SEC-FETCH-MODE: navigate"""
    cmd .= " --add-header ""SEC-FETCH-SITE: same-origin"""
    cmd .= " --add-header ""SEC-FETCH-USER: ?1"""
    cmd .= " --add-header ""TE: trailers"""
    cmd .= " --add-header ""UPGRADE-INSECURE-REQUESTS: 1"""
    ; Sleep Interval
    cmd .= " --sleep-interval """ Format("{:d}", ytdl.SleepInterval) """"
    ; Video Format Options
    cmd .= " --youtube-skip-dash-manifest"
    cmd .= " --merge-output-format """ ytdl.Video.Container """"
    ; Subtitle Options
    ; -none-
    ; Authentication Options
    ; -none-
    ; Adobe Pass Options
    ; -none-
    ; Post-processing Options
    ;; Format
    if (Mode = 1) {
        cmd .= " --format "
        ext := Format("{:L}", ytdl.Audio.Format)
        if (ext ~= "^(m4a|opus)$") {
            cmd .= """bestaudio[ext=" ext "]"""
        } else {
            cmd .= " --extract-audio"
            cmd .= " --audio-format """ ext """"
            cmd .= " --audio-quality 0"
        }
    } else {
        cmd .= " --format ""bestvideo[height<=" ytdl.Video.Quality "]+bestaudio"""
    }
    ;; Thumbnails
    if (Mode = 1 && ytdl.Audio.Thumbnail)
    || (Mode = 2 && ytdl.Video.Thumbnail) {
        cmd .= " --embed-thumbnail"
    }
    ;; Metadata
    if (ytdl.Metadata) {
        cmd .= " --add-metadata"
    }
    ;; FFmpeg
    if (!FileExist(ytdl.Path "\ffmpeg.exe")) {
        ffmpegPath := ""
        if (FileExist(ytdl.FFmpeg "\ffmpeg.exe")) {
            loop files, % ytdl.Path, D
                ffmpegPath := A_LoopFileLongPath
        }
        if (FileExist(ytdl.Path "\" ytdl.FFmpeg "\ffmpeg.exe")) {
            loop files, % ytdl.Path "\" ytdl.FFmpeg, D
                ffmpegPath := A_LoopFileLongPath
        }
        if (ffmpegPath) {
            cmd .= " --ffmpeg-location """ ffmpegPath """"
        }
    }
    ; Execute
    cmd .= " """ (isPlaylist ? _listId : _videoId) """"
    try {
        Run % cmd, % ytdl.Path
    } catch {
        MsgBox 0x40010, Error, There was an error running yt-dlp.
    }
}

class ytdl {

    static Path := "" ; Path to the binary

        ; FFmpeg directory
        , FFmpeg := "..\FFmpeg"

        ; Uncensor
        , GeoBypass := true

        ; Embed metadata?
        , Metadata := true

        ; Time between downloads
        , SleepInterval := 0

        ; Audio options
        , Audio := {}

        ; 'm4a'/'opus' natively
        , Audio.Format := "m4a"
        ; Others need recoding (like mp3)

        ; Thumbnail?
        , Audio.Thumbnail := false

        ; Video options
        , Video := {}

        ;                     mkv
        ;                     mp4
        ;                     ogg
        ;                    webm
        , Video.Container := "mp4"

        ;           144p =  144
        ;           240p =  240
        ;           360p =  360
        ;           480p =  480
        ;             HD =  720
        ;            FHD = 1080
        ;            QHD = 1440
        ;             4k = 2160
        ;             8k = 4320
        , Video.Quality := 1080

        ; Thumbnail?
        , Video.Thumbnail := true

}
