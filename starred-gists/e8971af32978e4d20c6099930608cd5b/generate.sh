#!/bin/bash

# clone wiki repo
git clone --depth 1 git@github.com:koalaman/shellcheck.wiki.git \
&& cd "$(basename "$_" .git)" \
|| exit 1

# make _shellcheck.md
grep -m1 '^##* .*$' SC*.md \
| sed -r 's_^(.*)...:##*  *_- [\1](https://github.com/koalaman/shellcheck/wiki/\1) _g' \
> _shellcheck.md

# make _shellcheck.csv
ruby -r csv << 'EOF'
CSV.open("_shellcheck.csv", ?w, force_quotes: true){|c|
    c<<%W{name link description}
    `cat _shellcheck.md`.split(?\n).map{
        c<<_1.sub(/^- \[/,"").split(/]\(|(?<=\d{4})\) /)
    }
}
EOF
