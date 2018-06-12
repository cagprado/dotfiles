#!/bin/zsh

# Set repository local option
print -P "%BConfiguring local home-git repository...%b"
git --git-dir=$HOME/.cfg --work-tree=$HOME config --local status.showUntrackedFiles no

# Create some dirs used by configuration
print -P "%BSetting up directories...%b"
install -dm0 $HOME/.dropbox-dist
mkdir -p $HOME/.cache/zsh
mkdir -p $HOME/var/backup
mkdir -p $HOME/.msmtp.queue

# VIM
print -P "%BInstalling Vundle...%b"
mkdir -p $HOME/.vundle
git clone http://github.com/VundleVim/Vundle.vim $HOME/.vundle/Vundle.vim

# tmux
print -P "%BInstalling tmux plugins...%b"
mkdir -p $HOME/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux new -d -s __noop >/dev/null 2>&1 || true 
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

# Setting up permissions
print -P "%BSetting up correct permissions for sensitive configurations...%b"
$HOME/etc/setup/setpermissions.sh
print -P -n " - Do you want to setup permission for SDDM faces? "
read ANS
if [[ "$ANS" = (yes|YES|Yes|y|Y) ]]; then
  setfacl -m "u:sddm:x" /home/cagprado
else
  print "   skipping..."
fi

# Install the certificates
if command -v certutil >/dev/null 2>&1; then
  print -P "%BInstalling certificates...%b"
  DATABASEDIR=$HOME/.pki/nssdb
  if [[ ! -d $DATABASEDIR ]]; then
    mkdir -p $DATABASEDIR
    certutil -d $DATABASEDIR -N
  fi

  certutil -d sql:$HOME/.pki/nssdb -A -n "CCIFUSP CA" -t CT,C,C -i "$HOME/etc/certificates/CCIFUSP-CA.crt"
  certutil -d sql:$HOME/.pki/nssdb -A -n "CERN Root CA" -t ,, -i "$HOME/etc/certificates/CERN Root Certification Authority 2.crt"
  certutil -d sql:$HOME/.pki/nssdb -A -n "CERN Grid CA" -t CT,C,C -i "$HOME/etc/certificates/CERN Grid Certification Authority.crt"
  certutil -d sql:$HOME/.pki/nssdb -A -n "CERN CA" -t CT,C,C -i "$HOME/etc/certificates/CERN Certification Authority.crt"
fi

# Setup fonts
print -P "%BSetting up fonts...%b"
$HOME/etc/setup/setfonts.sh

# Setup hooks
print -P "%BSetting up git hooks...%b"
$HOME/etc/setup/sethooks.sh

# Finished
print -P "%BBasic configuration done!%b"
