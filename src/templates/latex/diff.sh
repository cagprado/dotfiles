#!/bin/zsh
revision=

for file in "$@"; do
  dir=$(dirname "$file")
  basename="${${file#*main_}%.*}"
  echo -e "\e[1mGenerating diff for file '$basename'...\e[0m"

  # latexdiff generates a diff .tex file
  latexdiff-vc --math-markup=1 --allow-spaces --flatten --git --force -r $revision $dir/main_$basename.tex
  mv "${dir}/main_${basename}-diff${revision}.tex" "${dir}/main_${basename}-diff.tex"

  # make pdf for diff file
  make ${basename}-diff.pdf

  # remove used files
  rm -rf ${dir}/main_${basename}-diff.{out,tex,bbl}
done
