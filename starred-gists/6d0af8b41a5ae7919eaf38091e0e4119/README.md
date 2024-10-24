# Copy Button

This gist contains the recipe to make a copy button.

It is activated by adding `data-js="copy"` to an element and including the CSS and JS files.

```html
<link rel="stylesheet" href="https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb/copy-button.css">
      <script async src="https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb/copy-button.js"></script>
<pre data-js="copy">Your Text Goes Here</pre>
```

The button itself is an SVG that is added to an HTML element using [an `::after` pseudo-element][1].

The JS is an [EventListener][2] on a [Click event][3], and uses [`navigator.clipboard`][4] to copy the text.

Once the text is copied, the button is given a CSS class that changes the SVG to a checkmark.

Both SVG icons are taken from [Material Line Icons][5].

It can be seen in action at https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb

If the _HTML_ of the target should be copied (rather than the text) use:`data-js="copy copy-html"`.
This will also copy any [HTML tags][6] present in the content.

To have a button that copies something else, add `data-js-copy="selector"`, where `selector` can be any valid [CSS selector.][7]

For example:

```html
<link rel="stylesheet" href="https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb/copy-button.css">
<script async src="https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb/copy-button.js"></script>
<a data-js="copy" data-js-copy="pre[data-js-copy-this='target']" title="Copy the text below"></a>
<pre data-js-copy-this="target">Your Text Goes Here</pre>
```

[![screenshot of the page][screenshot]](https://gist.pother.ca/33b4d10024f56ba0610f8e70477687cb)

[1]: https://developer.mozilla.org/docs/Web/CSS/::after
[2]: https://developer.mozilla.org/docs/Web/API/EventTarget/addEventListener
[3]: https://developer.mozilla.org/docs/Web/API/Element/click_event
[4]: https://developer.mozilla.org/docs/Web/API/Navigator/clipboard
[5]: https://github.com/cyberalien/line-md
[6]: https://developer.mozilla.org/docs/Web/HTML
[7]: https://developer.mozilla.org/docs/Learn/CSS/Building_blocks/Selectors
[screenshot]: https://user-images.githubusercontent.com/195757/236698925-4969f801-61fb-4e16-81ae-0d8c8893a9d2.png
