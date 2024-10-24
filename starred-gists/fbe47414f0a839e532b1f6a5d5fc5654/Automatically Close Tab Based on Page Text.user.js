// ==UserScript==
// @name      Autoclose Tab
// @namespace Autoclose Tab
// @include   *
// ==/UserScript==

// separate words or phrases with a comma
var blacklist = ["cactus", "finances", "put other text here"],
    re = new RegExp(blacklist.join('|'), "i");
if (re.test(document.body.textContent)) {
  var win = window.open("","_self");
  win.close();
}