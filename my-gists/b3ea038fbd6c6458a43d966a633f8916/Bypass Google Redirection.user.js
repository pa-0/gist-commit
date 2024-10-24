// ==UserScript==
// @name Google Bypass Redirection | Harsh
// @description Bypass Google Redirection -By Harsh
// @version 1.7
// @author Harsh Kumar 
// @icon http://s25.postimg.org/mf2enu25n/leo_icon.png
// @homepage https://harsh.one
// @updateURL https://gist.github.com/Harsh223/3c2a5258870db6adb6bb#file-bypass-google-redirection-user-js
// @downloadURL https://gist.github.com/Harsh223/3c2a5258870db6adb6bb#file-bypass-google-redirection-user-js
// @include    /https?:\/\/www.google\.[^\/]+\/search.+/
// ==/UserScript==

(function() {
    var i;
    var links = document.getElementsByTagName("a");
    for (i = 0; i < links.length; i++) {
        var link = links[i];
        if (link.hasAttribute("onmousedown")) {
            link.removeAttribute("onmousedown");
            if (link.removeEventListener) {
                link.removeEventListener("mousedown", link.onmousedown, false);
            } else if(link.detachEvent) {
                link.detachEvent("onmousedown", link.onmousedown);
            }
        }
    }
})();
