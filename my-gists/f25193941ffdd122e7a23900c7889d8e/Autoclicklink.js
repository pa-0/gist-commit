// ==UserScript==
// @name     Autoclick Link with Specified Text
// @include  https://www.example.com/*
// @require  http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js
// @grant    GM_addStyle
// ==/UserScript==
/*- The @grant directive is needed to work around a design change
    introduced in GM 1.0.   It restores the sandbox.
*/

//--- the contains() text is case-sensitive
var TargetLink = $("a:contains('Contact')")

if (TargetLink.length)
    window.location.href = TargetLink[0].href