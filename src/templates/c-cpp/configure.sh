#!/bin/zsh
print -P -f '%25s%s%25s\n\n' '' '%B%UTEMPLATE CONFIGURATION - C/C++%u%b' ''

mkdir -p src include

# Select program type
FORMAT=("C" "C++")
print -P "Available program formats:"
for i in {1..$#FORMAT}; do
  print -P "  %B$i -%b $FORMAT[$i]"
done

ANS=''
while [[ "$ANS" != <-> || "$ANS" -lt 0 || "$ANS" -gt "$#FORMAT" ]]; do
  print -P -n "Please select one of the formats above: "
  read ANS
done
FORMAT=$FORMAT[$ANS]

if [[ "$FORMAT" == "C" ]]; then
  EXT="c"
else
  EXT="cpp"
fi

# Choose a program name
PRGNAME=''
print -P -n "Please choose a name for your program ['program']: "
read PRGNAME
PRGNAME=${PRGNAME%% *}
[[ -z "$PRGNAME" ]] && PRGNAME="program"
print -P "Creating source file %Bsrc/main_$PRGNAME.$EXT%b."
touch src/main_$PRGNAME.$EXT

# Remove this configuration script
rm configure.sh
