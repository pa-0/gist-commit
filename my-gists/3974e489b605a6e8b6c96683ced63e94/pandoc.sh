# Pandoc is awesome!
# http://johnmacfarlane.net/pandoc/

## Download shell documentation as epub book:
pandoc -s -r html https://www.gnu.org/software/bash/manual/bashref.html -o bash.epub

## Download article as markdown:
pandoc -s -r html http://www.farnamstreetblog.com/2014/04/how-complex-systems-fail/ -o ./_drafts/how-complex-systems-fail.md

## Convert markdown sources to many other formats
pandoc sources.md -o largescale-js.epub --toc-depth=2 --epub-cover-image=cover.jpg --epub-chapter-level=2 # .epub
pandoc sources.md -o largescale-js.fb2 --toc-depth=2 --epub-cover-image=cover.jpg --epub-chapter-level=2 # .fb2
