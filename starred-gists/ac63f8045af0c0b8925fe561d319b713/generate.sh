#!/bin/bash
git clone git@github.com:koalaman/shellcheck.wiki.git
cd shellcheck.wiki
head -1 SC*.md \
| perl -p -e 's/\n//g;s/==>/\n/g;' \
| perl -p -e 's!^\s*(SC\d+)\s*[.]md\s*<==(##)?(\s|#)*![$1](https://github.com/koalaman/shellcheck/wiki/$1) !'
