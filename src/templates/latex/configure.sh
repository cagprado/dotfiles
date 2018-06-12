#!/bin/zsh
autoload +X msg war err
print -P -f '%25s%s%25s\n\n' '' '%B%UTEMPLATE CONFIGURATION - LATEX%u%b' ''

# Check available styles
STYLE=()
for DIR in style_*(/); do
  STYLE+=(${DIR##*_})
done
print -P "Available styles:"
for i in {1..$#STYLE}; do
  print -P "  %B$i -%b $STYLE[$i]"
done

# Select one style
ANS=''
while [[ "$ANS" != <-> || "$ANS" -lt 0 || "$ANS" -gt "$#STYLE" ]]; do
  print -P -n "Please select one of the styles listed above: "
  read ANS
done
STYLE=$STYLE[$ANS]
print -P "Selected style %B$STYLE%b."
if [[ "$STYLE" == "presentation" ]]; then
  THEME=()
  for DIR in style_$STYLE/*(/); do
    THEME+=(${DIR##*_})
  done
  print -P "Available themes:"
  for i in {1..$#THEME}; do
    print -P "  %B$i -%b $THEME[$i]"
  done

  ANS=''
  while [[ "$ANS" != <-> || "$ANS" -lt 0 || "$ANS" -gt "$#THEME" ]]; do
    print -P -n "Please select one of the themes listed above: "
    read ANS
  done
  THEME=$THEME[$ANS]
  print -P "Selected theme %B$THEME%b."
  cp style_$STYLE/theme_$THEME/*(D) tex/
  sed -i -e "s/TEMPLATE_OPTION_THEME/$THEME/" style_$STYLE/main.tex
fi
cp style_$STYLE/*(.D) tex/
rm -rf style_*

# Select latex engine
ENGINE=("latex" "pdflatex" "lualatex")
print -P "Available engines:"
for i in {1..$#ENGINE}; do
  print -P "  %B$i -%b $ENGINE[$i]"
done

ANS=''
while [[ "$ANS" != <-> || "$ANS" -lt 0 || "$ANS" -gt "$#ENGINE" ]]; do
  print -P -n "Please select one of the engines listed above: "
  read ANS
done
ENGINE=$ENGINE[$ANS]
print -P "Selected engine %B$ENGINE%b."
sed -i -e "s/TEMPLATE_OPTION_TEXENGINE/$ENGINE/" Makefile

# Choose a document name
DOCNAME=''
print -P -n "Please, choose a name for your document ['document']: "
read DOCNAME
DOCNAME=${DOCNAME%% *}
[[ -z "$DOCNAME" ]] && DOCNAME="document"
print -P "Creating main laTeX file %Btex/main_$DOCNAME.tex%b."
mv tex/main.tex tex/main_$DOCNAME.tex

# Remove this configuration script
rm configure.sh
