// ==UserScript==
// @name         Amazon Review Search
// @namespace    https://gist.github.com/AJolly
// @version      0.4
// @description  Add a search box for customer reviews on Amazon product pages
// @include      https://www.amazon.com/*
// @grant        none
// @author       AJolly
// @license      MIT
// @downloadURL  https://gist.github.com/AJolly/7791ebddb4bafcd78105a446f440d900/raw/?cache-bust=111
// @updateURL    https://gist.github.com/AJolly/7791ebddb4bafcd78105a446f440d900/raw/?cache-bust=111
// ==/UserScript==

(function() {
    'use strict';

    // Function to extract ASIN from the current URL
    function getASIN() {
        const match = window.location.pathname.match(/\/(?:dp|product|gp\/product)\/([A-Z0-9]{10})/);
        return match ? match[1] : null;
    }

    // Function to check if we're on a product page
    function isProductPage() {
        return !!getASIN();
    }

    // Function to create and insert the search box
    function addReviewSearchBox() {
        if (!isProductPage()) return;

        const askQuestionBox = document.querySelector('#askQuestionTextInput, #askATFLink');
        if (!askQuestionBox) return;

        const existingSearchBox = document.getElementById('ajolly-review-search');
        if (existingSearchBox) return;

        const searchBox = document.createElement('input');
        searchBox.type = 'text';
        searchBox.id = 'ajolly-review-search';
        searchBox.placeholder = 'Search customer reviews';
        searchBox.style.marginTop = '10px';
        searchBox.style.width = '100%';
        searchBox.style.padding = '5px';

        const searchButton = document.createElement('button');
        searchButton.textContent = 'Search Reviews';
        searchButton.style.marginTop = '5px';
        searchButton.style.width = '100%';
        searchButton.style.padding = '5px';

        searchButton.addEventListener('click', function() {
            const asin = getASIN();
            if (!asin) {
                alert('Unable to find product ASIN. Please make sure you\'re on a product page.');
                return;
            }

            const keyword = encodeURIComponent(searchBox.value.trim());
            const url = `https://www.amazon.com/product-reviews/${asin}/ref=cm_cr_arp_d_viewopt_sr?ie=UTF8&filterByStar=all_stars&reviewerType=all_reviews&pageNumber=1&filterByKeyword=${keyword}#reviews-filter-bar`;
            window.open(url, '_blank');
        });

        const container = document.createElement('div');
        container.style.marginTop = '10px';
        container.appendChild(searchBox);
        container.appendChild(searchButton);

        askQuestionBox.parentNode.insertBefore(container, askQuestionBox.nextSibling);
    }

    // Run the script when the page is fully loaded
    window.addEventListener('load', addReviewSearchBox);

    // Also run the script on URL changes (for single-page application behavior)
    let lastUrl = location.href;
    new MutationObserver(() => {
        const url = location.href;
        if (url !== lastUrl) {
            lastUrl = url;
            addReviewSearchBox();
        }
    }).observe(document, {subtree: true, childList: true});
})();