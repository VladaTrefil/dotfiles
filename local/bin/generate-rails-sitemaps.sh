#!/bin/bash

dir="sitemaps"
base="$PWD"

if [ ! -d "./$dir" ]; then
  mkdir $dir
fi

rm -rf "./$dir/*"

bin/rake sitemap:refresh:no_ping

find public/sitemaps/**/*.xml.gz | while read -r file; do
  parent_dir=$(dirname "$file")
  parent_dir_name=$(basename "$parent_dir")

  gunzip -ck "$base/$file" > "./$dir/$parent_dir_name.xml"
done

nvim
