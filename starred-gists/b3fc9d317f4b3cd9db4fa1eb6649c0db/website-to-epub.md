# Converting websites to EPUB / MOBI eBooks

## Step 1 - Install dependencies
Install go and pandoc with whatever package manager you use, and install papeer through go.
```bash
brew install go pandoc # Example for homebrew on mac
go install github.com/lapwat/papeer@latest
# If the `papeer` command is unavailable, add this to .bashrc or .zshrc
export PATH="$PATH:~/go/bin"
```


## Step 2 - Fetch content
It should be done with `--format=html`, because the default `format=md` does not keep all the neeeded code.
```bash
# Single page
papeer get --format=html <URL>
# Full page recursively
papeer get --format=html --selector='<CSS selector of table-of-contents URLs>' <URL-to-table-of-contents-page>
```
It is also possible to download individual files, then combine them with this command:
```bash
pandoc file1.html file2.html file3.html -o output.html
```
[Full papeer docs](https://github.com/lapwat/papeer)

## Step 3 - Convert to EPUB
This step can take a LONG time. (more than 10 minutes with a lot of TeX and/or images)
```bash
pandoc <downloaded-file>.html --to=epub -o <output-file>.epub
```
If the site contains TeX math, one of the following options for rendering should be used. In most cases, `--mathml` should be used instead of generating raster images.
```bash
pandoc <downloaded-file>.html --mathml --to=epub -o <output-file>.epub
pandoc <downloaded-file>.html --webtex --to=epub -o <output-file>.epub
pandoc <downloaded-file>.html --mathjax --to=epub -o <output-file>.epub
# Note: when using --KaTeX, the images are rendered, but not referenced in the output
pandoc <downloaded-file>.html --katex --to=epub -o <output-file>.epub
```
MathML might give some warnings like this:
```
Could not convert TeX math ...... rendering as TeX:
```
If you get this warning, it will likely still render correctly.

### Higher quality images with webtex
You can specify an url to `--webtex` to get better output images.
```bash
pandoc <downloaded-file>.html --to=epub --webtex='https://latex.codecogs.com/png.latex?%5Cdpi{300}' -o <output-file>.epub
```

## Step 4 - Final tweaks
Import the EPUB file to [calibre](https://calibre-ebook.com/) and change the metadata, and add or generate a cover image, and do some final changes in the EPUB editor. 
If the file contains MathML, it has to be converted to `AZW3` instead of `MOBI`, and if it takes too long to open, it should be a `PDF` instead.