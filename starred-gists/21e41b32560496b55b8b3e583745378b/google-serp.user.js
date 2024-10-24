//DOESN'T WORK
// ==UserScript==
// @name          Google Search: Direct Links in Results
// @icon          https://www.google.com/favicon.ico
// @namespace     google
// @description   rewrite URLs in google search result pages
// @version       0.0.2
// @downloadURL   https://gist.github.com/pa-0/21e41b32560496b55b8b3e583745378b/raw/002dec0164cfe35e43a83a23cdb431b794c38deb/google-serp.user.js
// @updateURL     https://gist.github.com/pa-0/21e41b32560496b55b8b3e583745378b/raw/002dec0164cfe35e43a83a23cdb431b794c38deb/google-serp.user.js
// @include       http://*.google.*/*
// @include       https://*.google.*/*
// @include       http://*.google.*.*/*
// @include       https://*.google.*.*/*
// ==/UserScript==
var search_results = document.evaluate("//div[@id='search']//h3/a", document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
if(search_results.snapshotLength > 1) {
  for(var i=0; i<search_results.snapshotLength; i++) {
    var c = search_results.snapshotItem(i);
    c.removeAttribute('onmousedown');
    // c.setAttribute('href', rewrite_url(c.href));
  }
}

function rewrite_url(old_url) {
  var params = get_params(old_url);
  console.info(params);
  if('url' in params) {
    var new_url = params['url'];
    console.info('new url:', new_url);
    return new_url;
  }
};

function get_params(dest_url) {
  dest_url = dest_url.replace(/&amp;/g, '&');
  var params = dest_url.substr(dest_url.indexOf("?") + 1).split('&'),
  r = {};
  if (typeof params !== 'object' || params.length < 1) return false;
  for (var x = 0; x <= params.length; x++) {
    if (typeof params[x] == "string" && params[x].indexOf('=')) {
      var t = params[x].split('=');
      if (t instanceof Array) {
        var k = t[0];
        if (t.length > 1) {
          var z = t[1];
          r[k] = decodeURIComponent(z);
        } else {
          r[k] = '';
        }
      }
    }
  }
  return r;
};