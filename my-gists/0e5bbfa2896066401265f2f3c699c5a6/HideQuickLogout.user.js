// ==UserScript==
// @name         AHK-Forum: Hide quick logout
// @namespace    https://github.com/G33kDude
// @version      0.1
// @description  Hides the quick access logout button in the toolbar next to the notifications
// @author       GeekDude
// @match        *://autohotkey.com/boards/*
// @icon         https://www.autohotkey.com/favicon.ico
// @grant        none
// @updateURL    https://gist.github.com/pa-0/0e5bbfa2896066401265f2f3c699c5a6/raw/ada15f24524f2dbd6b8d1ac2295e0ce2bf7c7319/HideQuickLogout.user.js
// ==/UserScript==

(function() {
    'use strict';

    $('.tab.logout').hide();
})();