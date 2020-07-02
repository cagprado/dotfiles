#!/bin/zsh

# Setup fontconfig fonts
fc-cache -f

# Setup console fonts: need root
print -P -n " - Do you want to setup console fonts (need root)? "
read ANS
if [[ "$ANS" = (yes|YES|Yes|y|Y) ]]; then
  # copy font to default location
  sudo cp $HOME/etc/system/usr/share/kbd/consolefonts/* /usr/share/kbd/consolefonts

  # setup vconsole.conf to load consolefont
  if [[ -r /etc/vconsole.conf ]]; then
    VCONSOLE=$(grep -v '^FONT=' /etc/vconsole.conf)
  else
    VCONSOLE=''
  fi
  VCONSOLE+='\nFONT=ter-v28b'
  echo $VCONSOLE | sudo tee /etc/vconsole.conf >/dev/null

  # remind to setup mkinitcpio.conf
  print "   add 'systemd' and 'sd-vconsole' to HOOKS in /etc/mkinitcpio.conf and"
  print "   run 'mkinitcpio -p linux' if you want the font to be loaded earlier."
else
  print "   skipping..."
fi
