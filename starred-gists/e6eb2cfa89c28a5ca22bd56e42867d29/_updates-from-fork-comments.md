## Updated Bookmarklet Code! 

>[!Note]
>Many times, a dated gist will have more valuable info in the comments than the body of the gist itself...
>Hence, the copy/paste job below

### Original Gist
[_Bookmarklet to append a string to the end of a URL_]([url](https://gist.github.com/cazepeda-zz/3967172.js))

```javascript
window.location.href
====================

Bookmarklet to append a string to the end of the URL.

1. Create bookmark.
2. Edit bookmark URL(Chrome) / Location(Firefox) to include this code: javascript:window.location.href=window.location.href+'REPLACETHIS';
3. Now make use of that bookmarklet.
4. Code:
    
    javascript:window.location.href=window.location.href+'REPLACETHIS';
```
### Updates from Comments
_Credit: @smichel17 (circa. December 18th 2019)_

Here's a slightly more robust version:
```
javascript:const params = new URLSearchParams(window.location.search); params.set("KEY", "VALUE"); window.location.href=window.location.origin+window.location.pathname+"?"+params.toString();
```
Follow the same steps from above, replacing KEY and VALUE with the ones you'd like.

>[!Note]
>Using set will overwrite any existing parameters rather than append. (ex. if you're already on example.com/hello?foo=1, your example would change it to example.com/hello?KEY=VALUE rather than appending as suggested.

There is probably a way to shorten this even more, but it can be even further simplified to:
```
javascript:let tempUrl = new URL(window.location);tempUrl.searchParams.append("KEY","VALUE");window.location = tempUrl;
```
(which will correctly change example.com/hello?foo=1 to example.com/hello?foo=1&KEY=VALUE and will also change example.com/hello to example.com/hello?KEY=VALUE

Also the solution in the original post can be simplified to the following in modern browsers (I believe there were a couple quirks with this in really old browsers):
```javascript 
javascript:window.location.href+='REPLACETHIS';
```
