# `Binary 2 LFS`

Find binary files and include to `.gitatributes`.

> Note: enable GitHub LFS for required repository.

```bash
#!/usr/bin/env bash

find . -type f -not -path "./.git/*" | perl -lne 'print if -B' | sed 's|.*\.||' | sort -u | while read in; do echo *.$in filter=lfs diff=lfs merge=lfs -text >> .gitattributes_new; done

cat .gitattributes >> .gitattributes_new
cat .gitattributes_new | sort -u > .gitattributes_new2
cat .gitattributes_new2 | sort -f > .gitattributes
rm .gitattributes_new
rm .gitattributes_new2
```
