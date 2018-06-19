# ZSH Configuration
# Profile - loaded in login shell

[[ "$(id -un)" == "$(id -gn)" ]] && umask 002 || umask 022

# GENERIC VARIABLES #########################################################
export CFG_COMMAND="/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME"
export EDITOR=vim
export DE="generic"
export TEXMFHOME="$HOME/.texmf"
export TMPHOME="/tmp/cagprado"
export LESS="-cx3MRFX"
export LESSOPEN="| /usr/bin/lesspipe.sh %s"
export LESSCOLORIZER="pygmentize"
export GNUPGHOME="$HOME/.gnupg"
export HOMEPRINTER=""
export WORKPRINTER="hpiopp"
export PRINTER=$WORKPRINTER
export QT_QPA_PLATFORMTHEME=qt5ct
export FREETYPE_PROPERTIES="truetype:interpreter-version=38"
export FT2_SUBPIXEL_HINTING=2
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=gasp -Dswing.aatext=true"
export MAKEFLAGS='-j'

# KEYRING ###################################################################
if [[ -n "$DESKTOP_SESSION" ]]; then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# SESSION CONFIGURATION #####################################################
export HOSTNAME=$(hostname)

if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || "$(ps -o comm= -p $PPID)" =~ "^.*/sshd$|^sshd$" ]]; then
    export SESSION="remote"
else
    export SESSION="local"
fi

if [[ "$HOSTNAME" != "mredson" ]]; then
    # first get rid of LD_LIBRARY_PATH poison =P
    unsetopt GLOBAL_RCS
    unset LD_LIBRARY_PATH

    if [[ "$HOSTNAME" =~ "sampa" ]]; then
        export ALIVERSIONS="VO_ALICE@ROOT::v5-34-30,VO_ALICE@pythia::v8186"
        source /cvmfs/alice.cern.ch/etc/login.sh
    fi

    # GCC
    if [[ -d "$HOME/usr/local/gcc" ]]; then
        export CC="$(readlink -f "$HOME/usr/local/gcc/bin/gcc")"
        export CXX="$(readlink -f "$HOME/usr/local/gcc/bin/g++")"
        export CPP="$(readlink -f "$HOME/usr/local/gcc/bin/cpp")"
        export F77="$(readlink -f "$HOME/usr/local/gcc/bin/gfortran")"
        export FC="$(readlink -f "$HOME/usr/local/gcc/bin/gfortran")"
        export LDFLAGS="-fPIC -Wl,-rpath,$(readlink -f "$HOME/usr/local/gcc/lib64")"
        export MANPATH="$(readlink -f "$HOME/usr/local/gcc/share/man"):$(manpath 2>/dev/null)"
        PATH="$(readlink -f "$HOME/usr/local/gcc/bin"):$PATH"
    fi

    # LOCAL BUILDS
    [[ -d "$HOME/usr/local/neovim" ]] && PATH="$(readlink -f "$HOME/usr/local/neovim/bin"):$PATH"
    [[ -d "$HOME/usr/local/root" ]] && PATH="$(readlink -f "$HOME/usr/local/root/bin"):$PATH"
    [[ -d "$HOME/usr/local/cmake" ]] && PATH="$(readlink -f "$HOME/usr/local/cmake/bin"):$PATH"
    [[ -d "$HOME/usr/local/hepmc" ]] && PATH="$(readlink -f "$HOME/usr/local/hepmc/bin"):$PATH"
    [[ -d "$HOME/usr/local/python" ]] && PATH="$(readlink -f "$HOME/usr/local/python/bin"):$PATH"
    [[ -d "$HOME/usr/local/pythia" ]] && PATH="$(readlink -f "$HOME/usr/local/pythia/bin"):$PATH"
fi

# SET PATH AND COMPILE ZSH FILES ############################################
zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)
zcompile $HOME/.zshenv
zcompile $HOME/.zprofile
zcompile $HOME/.zshrc
zcompile $HOME/.zlogout
export PATH="$HOME/bin:$PATH"
