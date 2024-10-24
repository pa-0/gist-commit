Download a McGraw Hill Education eTextbook
---
If you purchase a textbook from McGraw Hill, the website to view it is clunky and only works on some devices.
You can't go to specific page numbers, the search is super slow, etc.
That's why I wrote this script to download the textbook as an ePub file for your own viewing.

Using this script is 100% legal. McGraw Hill publicly hosts their ebooks online in order for their web client to
download it. Moreover, to use it, you must already have purchased the book you would like to download, so it is
legally yours to use as you please. **However, it IS illegal to use this for piracy purposes. DO NOT DISTRIBUTE
ANY TEXTBOOKS YOU DOWNLOAD USING THIS SCRIPT.**

## Instructions
1. Open your textbook in the McGraw-Hill Connect website (how you normally open it) in a private/incognito window.
Use Chrome if possible; this won't work at all in Firefox.
2. Type `javascript:` into the address bar (note that **you CANNOT copy-paste it in**).
2. Copy-paste the following into the address bar AFTER the `javascript:` part:
```js
var x=new XMLHttpRequest();x.onload=function(){eval(x.responseText)};x.open('GET','https://gist.githubusercontent.com/101arrowz/88156556326106a6ccd58ecb4526498c/raw/script.js');x.send();
```
3. Press ENTER.
4. Follow the instructions that appear on screen. Be patient! The download takes between 10 and 40 minutes depending on internet speed.
5. Your textbook will download on its own.

If you found this tutorial useful, please give it a star. Thanks!

~101arrowz