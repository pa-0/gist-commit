// ==UserScript==
// @name         GitHub HTML Preview
// @namespace    https://gist.github.com/ccjmne
// @version      2.0.0
// @description  Viualise any HTML content on GitHub
// @author       ccjmne <ccjmne@gmail.com> (https://github.com/ccjmne)
// @include      *://gist.github.com/*
// @include      *://github.com/*
// @downloadURL  https://gist.githubusercontent.com/ccjmne/82abdd715ca9cf96d86d9eaa4e6bb87e/raw/htmlpreview.github.user.js
// @grant        none
// ==/UserScript==

const BUTTON_TITLE = 'Preview';

/**
 * @param { HTMLDivElement? } buttons
 * @return { boolean }
 */
function addPreview(buttons) {
    if (!!buttons && ![...buttons.children].some(({ textContent }) => textContent === BUTTON_TITLE)) {
        buttons.appendChild((a => {
            a.textContent = BUTTON_TITLE;
            a.classList.add(...buttons.lastElementChild.classList);
            a.setAttribute('rel', 'nofollow');
            a.addEventListener('click', () => window.open(`http://htmlpreview.github.io/?${window.location.href}`));
            return a;
        })(document.createElement('a')));
    }

    return !!buttons;
}

function attemptAddPreview() {
    if (/\/blob\/.*\.x?html$/.test(document.location.href)) {
        const ival = window.setInterval(() => addPreview(document.querySelector('.Box-header.js-blob-header .BtnGroup')) && window.clearInterval(ival), 50);
        window.setTimeout(() => window.clearInterval(ival), 1000);
    }
}

let oldHref;
window.addEventListener('load', () => attemptAddPreview() + new MutationObserver(
    mutations => mutations.some(() => oldHref !== document.location.href)
      && (oldHref = document.location.href)
      && attemptAddPreview()
).observe(document.querySelector('body'), { childList: true, subtree: true }));
