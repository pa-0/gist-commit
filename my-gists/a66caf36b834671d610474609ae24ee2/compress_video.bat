for %%i in (*.mp4) do ffmpeg -i "%%i" -vcodec libx265 -crf 28 "%%i-compressed.mp4" && move /y "%%i-compressed.mp4" "%%i"
