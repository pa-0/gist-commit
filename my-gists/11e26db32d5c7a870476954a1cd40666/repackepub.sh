zip -rX "../$(basename "$(realpath .)").epub" mimetype $(ls|xargs echo|sed 's/mimetype//g')