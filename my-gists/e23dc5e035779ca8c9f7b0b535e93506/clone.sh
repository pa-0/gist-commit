while read p; do
  git clone $p
done < gittiprepos.txt
