for i in $(ls *rst)
do
  filename="${i%.*}"
  echo "Converting $i to $filename.md"
  # https://pandoc.org/MANUAL.html#pandocs-markdown
  pandoc "$i" -f rst -t gfm -o "$filename.md"
done