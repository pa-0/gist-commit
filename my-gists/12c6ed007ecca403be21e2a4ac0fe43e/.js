// ==UserScript==
// @name     Auto-Refresh
// @include  https://www.example.com
// ==/UserScript==

// https://stackoverflow.com/questions/25484978/i-want-a-simple-greasemonkey-script-to-reload-the-page-every-minute/
// Reloads after 20s (the last parameter in setTimeout is in milliseconds)... 20*1000ms) / (60000ms/min) = 0,3333min

setTimeout(function(){ location.reload(); }, 20*1000);