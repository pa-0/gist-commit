@echo off
set _FN=%1
set _FN=%_FN:.txt=%
set _FN=%_FN:.md=%
set _AUTHOR=未知
if not "%2"=="" (
  set _AUTHOR=%2
)
pandoc %1 -f markdown --toc --metadata title="%_FN%" --metadata author="%_AUTHOR%" --metadata lang="zh-Hant" --css style.css  -o %_FN%.epub
