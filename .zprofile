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

if [[ "$HOSTNAME" = "mredson" ]]; then
    export MAKEFLAGS='-j4'
elif [[ "$HOSTNAME" =~ "sampa" ]]; then
    export MAKEFLAGS='-j10'

    # ALICE
    export ALIVERSIONS="VO_ALICE@ROOT::v5-34-30,VO_ALICE@pythia::v8186"
    source /cvmfs/alice.cern.ch/etc/login.sh

    # GCC
    export CC="$HOME/usr/local/gcc/bin/gcc"
    export CXX="$HOME/usr/local/gcc/bin/g++"
    export CPP="$HOME/usr/local/gcc/bin/cpp"
    export F77="$HOME/usr/local/gcc/bin/gfortran"
    export FC="$HOME/usr/local/gcc/bin/gfortran"
    export LDFLAGS="-fPIC -Wl,-rpath,$HOME/usr/local/gcc/lib64"
    export MANPATH=$HOME/usr/local/gcc/share/man:$(manpath)
    PATH="$HOME/usr/local/gcc/bin:$PATH"

    # LOCAL BUILDS
    PATH="$HOME/usr/local/cmake/bin:$PATH"  # CMAKE
    PATH="$HOME/usr/local/Python/bin:$PATH" # PYTHON
    PATH="$HOME/usr/local/pythia/bin:$PATH" # PYTHIA
    PATH="$HOME/usr/local/root/bin:$PATH"   # ROOT
elif [[ "$HOSTNAME" =~ "gpu" ]]; then
    # first get rid of LD_LIBRARY_PATH poison =P
    unset LD_LIBRARY_PATH

    if [[ "$HOSTNAME" = "gpu0" ]]; then
        MAKEFLAGS='-j30'
    else
        MAKEFLAGS='-j70'
    fi

    # GCC
    export CC="$HOME/usr/local/gcc/bin/gcc"
    export CXX="$HOME/usr/local/gcc/bin/g++"
    export CPP="$HOME/usr/local/gcc/bin/cpp"
    export F77="$HOME/usr/local/gcc/bin/gfortran"
    export FC="$HOME/usr/local/gcc/bin/gfortran"
    export LDFLAGS="-fPIC -Wl,-rpath,$HOME/usr/local/gcc/lib64"
    export MANPATH="$HOME/usr/local/gcc/share/man:"
    PATH="$HOME/usr/local/gcc/bin:$PATH"

    # LOCAL BUILDS
    PATH="$HOME/usr/local/cmake/usr/bin:$PATH"    # CMAKE
    PATH="$HOME/usr/local/python/usr/bin:$PATH"   # PYTHON
    PATH="$HOME/usr/local/pythia/usr/bin:$PATH"   # PYTHIA
    PATH="$HOME/usr/local/root/usr/bin:$PATH"     # ROOT
fi

# SET PATH AND COMPILE ZSH FILES ############################################
zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)
zcompile $HOME/.zshenv
zcompile $HOME/.zprofile
zcompile $HOME/.zshrc
zcompile $HOME/.zlogout
export PATH="$HOME/bin:$PATH"
