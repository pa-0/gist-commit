// ==UserScript==
// @name        Copy Direct URL Buttons for every Google Search Result
// @namespace   https://wpdevdesign.com/
// @icon        https://google.com/favicon.ico
// @match       *://*.google.*/search?*
// @grant       none
// @version     1.0.1
// @author      Abdelouahed Errouaguy & Sridhar Katakam
// @description Makes copying links from google search results faster by adding 1-click copy buttons next to the results
// @downloadURL https://gist.github.com/pa-0/003ae105855ea1be4b5233041cf6819c/raw/27434a16275ae7e58abe4569b5ab0c3f73120618/Google_CopyDirectLinks.user.js
// @updateURL   https://gist.github.com/pa-0/003ae105855ea1be4b5233041cf6819c/raw/27434a16275ae7e58abe4569b5ab0c3f73120618/Google_CopyDirectLinks.user.js
// ==/UserScript==

/* jshint esversion: 6 */

(function () {
  'use strict';
  
  // Function to copy the passed string to clipboard.
  function copyToClipboard(event) {
    let helper = document.createElement('input');

    document.body.appendChild(helper);
    helper.value = this.value;
    helper.select();
    document.execCommand('copy');
    this.textContent = "Copied ✓";
    helper.remove();
  
    event.preventDefault();
    event.stopPropagation();
  }

  document.querySelectorAll('.wsn-google-focused-link > a, .yuRUbf > div a').forEach(el => {
    let href = el.href;
    let button = document.createElement("button");
    button.textContent = "Copy URL";
    button.value = href;
    button.style.cssText = "cursor: pointer; margin-left: 10px; border-radius: 12px; padding: 4px 12px; border: 1px solid #ccc; font-size: 12px; position: absolute;";
    button.addEventListener("click", copyToClipboard);
    
    el.querySelector("h3").appendChild(button);
  });
})();