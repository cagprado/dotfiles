# zshenv: Environment
#
# This file is parsed first for every zsh shell. Keep it at minimum because
# ArchLinux parses a whole bunch of profile scripts at login that could
# overwrite what is set here.

# Let's define fpath as scripts will need those in order to use functions
export ZSH_FUNCTIONS="$HOME/bin/zsh"
fpath=($ZSH_FUNCTIONS.zwc $fpath)

# Login shell reads global /etc/zprofile, otherwise we avoid global configs
if [[ ! -o login ]]; then
    unsetopt GLOBAL_RCS
fi
