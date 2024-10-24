// ==UserScript==
// @name         Case Insensitive Label-based Radio Button Autofill ("Xabc Yhjk")
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://*.qualtrics.com/*
// @match        https://*.surveymonkey.com/*
// @match        https://*.surveygizmo.com/*
// @require      http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js
// @require      https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant        GM_addStyle
// ==/UserScript==

const findAndClickParent = text => {
  const lowerText = text.toLowerCase();
  [...document.querySelectorAll('label > span')]
    .forEach((e) => {
      if (e.textContent.toLowerCase() === lowerText) {
        e.parentElement.click();
      }
    });
}

waitForKeyElements(
  "label",
  () => {
    findAndClickParent("Xabc Yhjk");
  }
);