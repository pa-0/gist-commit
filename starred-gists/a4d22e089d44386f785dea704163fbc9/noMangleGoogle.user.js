// ==UserScript==
// @name        Prevent link mangling on Google
// @namespace   LordBusiness.LMG
// @match       https://www.google.com/search
// @grant       none
// @version     1.1
// @author      radiantly
// @description Prevent google from mangling the link when copying or clicking the link on Firefox
// ==/UserScript==

/*
 * If you're on Firefox, you might have noticed that when you try to click (or copy) a link from
 * a google search result, it redirects to an intermediate page instead of taking you immediately
 * to the search result. This is specifically annoying when trying to copy a google search result
 * to send to someone else, because it gives you the mangled google-ified link instead.
 * 
 * The same does not happen on Google Chrome or other chromium browsers. Maybe someone can test
 * this on Safari?
 * 
 * To install this script, you'll need a user script manager like ViolentMonkey, after which you
 * can click the Raw button (gist.github.com) to install.
 */

(function() {
  
  /*
   * The following 3 lines simply prevent the mousedown event from propagating to the respective
   * event listeners attached to the various link elements.
   * 
   * On testing, this does not seem to break any actual functionality on the site.
   */
  window.addEventListener("mousedown", (event) => {
    event.stopImmediatePropagation();
  }, true);
  
})();
