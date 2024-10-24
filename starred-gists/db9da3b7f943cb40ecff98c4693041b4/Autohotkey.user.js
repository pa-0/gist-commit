// ==UserScript==
// @name        AHK-Forum 'Copy' + 'Select All' Buttons
// @namespace   MySpace
// @description Adds 'Copy' and 'Select All' buttons to code blocks in the autohotkey.com Forum.
// @include     https://autohotkey.com/boards/*
// @icon        https://www.autohotkey.com/favicon.ico
// @uploadURL   https://gist.github.com/pa-0/db9da3b7f943cb40ecff98c4693041b4/raw/Autohotkey.user.js
// @version     1
// @grant       none
// @run-at      document-start
// @require     https://code.jquery.com/jquery-3.2.1.min.js
// ==/UserScript==

var myCSS = '         \
  body {              \
    margin: auto;     \
    width: 70%;       \
    min-width: 960px; \
  }';

var styles = document.createElement('style');
styles.setAttribute('type', 'text/css');
styles.appendChild( document.createTextNode(myCSS) );

(document.getElementsByTagName('head')[0] || document.documentElement).appendChild(styles);

waitForElement('body', 100);
window.addEventListener('load', OnLoad);

function waitForElement(selector, time) {
  if (document.querySelector(selector)!== null) {
    document.body.style.margin = 'auto';
    var links = document.links, link;
    for (var i = 0; i < links.length; i++) {
      link = links[i];
      if (link.innerText == '[Select all]')  {
        link.innerText = '[Copy]';
      }
    }
  }
  else {
    setTimeout(function() {
      waitForElement(selector, time);
    }, time);
  }
  var grayLink = $('div.nav-tabs > ul.rightside > li:first > a');
  grayLink.attr('href', 'http://forum.script-coding.com/');
  grayLink.children().text('Серый форум');
  var askLink = $('div.nav-tabs > ul.rightside > li:eq(1) > a');
  askLink.attr('href', 'https://autohotkey.com/boards/viewforum.php?f=5');
  askLink.children().text('Ask For Help');
}

function OnLoad() {
  var links = document.links, link, b;
  for (var i = 0; i < links.length; i++)  {
    link = links[i], b = false;
    if ( link.innerText == '[Copy]' || (b = (link.innerText == '[Select all]')) )  {
      if (b) link.innerText = '[Copy]';
      link.addEventListener('click', function()  {
        document.execCommand('copy');
        setTimeout(function() { clearSelection(); }, 50);
      });
    }
  }
}

function clearSelection() {
  if ( document.selection ) {
    document.selection.empty();
  } else if ( window.getSelection ) {
    window.getSelection().removeAllRanges();
  }
}