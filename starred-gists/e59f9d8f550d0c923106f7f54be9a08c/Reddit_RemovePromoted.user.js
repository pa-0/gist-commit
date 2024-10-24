// ==UserScript==
// @name         Reddit.com: Remove Promoted Posts
// @namespace    http://reddit.com/
// @version      2.0
// @description  Userscript that hides the Promoted section on Reddit.com
// @author       You
// @match        https://www.reddit.com/*
// @icon         https://www.reddit.com/favicon.ico
// @downloadURL  https://old.reddit.com/r/javascript/comments/8vmz0k/hide_promoted_posts_on_reddit/
// @updateURL    https://gist.github.com/pa-0/e59f9d8f550d0c923106f7f54be9a08c/raw/fd6e63ddb9444233aa9310340414ef63eab367d3/Reddit_RemovePromoted.user.js
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    const promotedPosts = document.getElementsByClassName('promotedlink');
    let totalPosts = 0;

    const hidePromotedPosts = () => {
        if (promotedPosts.length === totalPosts) return;
        totalPosts = promotedPosts.length;
        Array.from(promotedPosts).forEach((post) => {
            post.style.display = 'none';
        });
    };

    hidePromotedPosts();
    document.body.addEventListener('DOMNodeInserted', hidePromotedPosts);
})();