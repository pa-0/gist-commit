// ==UserScript==
// @name        AHK-Forums: Expand Code Blocks
// @description Expands all code blocks automatically on the AHK forums
// @version     0.5
// @namespace   https://www.autohotkey.com/boards
// @author      rjf89
// @updateURL   https://gist.github.com/pa-0/fa93ed2c859e2dd5bd558faeffba30ad/raw/e84bd4399dbc653797c12f8b3bea07ed88a22832/AHKForums_ExpandAllCode.user.js
// @downloadURL https://gist.github.com/pa-0/fa93ed2c859e2dd5bd558faeffba30ad/raw/e84bd4399dbc653797c12f8b3bea07ed88a22832/AHKForums_ExpandAllCode.user.js
// @match       https://www.autohotkey.com/boards/*
// @grant       none
// ==/UserScript==
(function () {
  'use strict';
  console.debug('>>> AHKEC: Script is running');
  const dbgArgs = args => args.map(arg => typeof arg === 'function' ? dbg(arg) : arg);
  const dbg = fn => {
    return function (...args) {
      // Find any arguments which are functions, and wrap them in dbg
      args = dbgArgs(args)
      console.debug(`>>> AHKEC: Calling function ${fn.name} with arguments:`, args);
      const result = fn(...args);
      console.debug(`>>> AHKEC: Function ${fn.name} returned:`, result);
      return result;
    };
  };
  const isLink = e => e.nodeName.toLowerCase() === 'a';
  const isExpandable = e => e.getAttribute('onclick')?.startsWith('expandCode');
  const isExpandCodeLink = e => isLink(e) && isExpandable(e);

  const links = [...document.querySelectorAll('a')];
  console.debug('>>> AHKEC: Found links:', links);
  links.filter(isExpandCodeLink).forEach(e => e.click());

  const observer = new MutationObserver(mutations => {
    mutations.flatMap(mutation => [...mutation.addedNodes])
      .filter(isExpandCodeLink)
      .forEach(e => e.click());
  });
  observer.observe(document.body, { childList: true, subtree: true });
})();