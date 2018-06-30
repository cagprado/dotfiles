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
export LOCALBUILDS="$HOME/usr/local"

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
    if [[ -d "$LOCALBUILDS/gcc" ]]; then
        export CC="$LOCALBUILDS/gcc/bin/gcc"
        export CXX="$LOCALBUILDS/gcc/bin/g++"
        export CPP="$LOCALBUILDS/gcc/bin/cpp"
        export F77="$LOCALBUILDS/gcc/bin/gfortran"
        export FC="$LOCALBUILDS/gcc/bin/gfortran"
        export LDFLAGS="-fPIC -Wl,-rpath,$LOCALBUILDS/gcc/lib64"
        export MANPATH="$LOCALBUILDS/gcc/share/man:$(manpath 2>/dev/null)"
        PATH="$LOCALBUILDS/gcc/bin:$PATH"
    fi

    # LOCAL BUILDS
    [[ -d "$LOCALBUILDS/cmake" ]] && PATH="$LOCALBUILDS/cmake/bin:$PATH"
    [[ -d "$LOCALBUILDS/python" ]] && PATH="$LOCALBUILDS/python/bin:$PATH"
    [[ -d "$LOCALBUILDS/hepmc" ]] && PATH="$LOCALBUILDS/hepmc/bin:$PATH"
    [[ -d "$LOCALBUILDS/pythia" ]] && PATH="$LOCALBUILDS/pythia/bin:$PATH"
    [[ -d "$LOCALBUILDS/root" ]] && PATH="$LOCALBUILDS/root/bin:$PATH"
    [[ -d "$LOCALBUILDS/root5" ]] && PATH="$LOCALBUILDS/root5/bin:$PATH"
    [[ -d "$LOCALBUILDS/neovim" ]] && PATH="$LOCALBUILDS/neovim/bin:$PATH"
fi

# SET PATH AND COMPILE ZSH FILES ############################################
zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)
zcompile $HOME/.zshenv
zcompile $HOME/.zprofile
zcompile $HOME/.zshrc
zcompile $HOME/.zlogout
export PATH="$HOME/bin:$PATH"
