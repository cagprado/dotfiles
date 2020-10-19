# ZSH Configuration
# Profile - loaded in login shell

[[ "$(id -un)" == "$(id -gn)" ]] && umask 002 || umask 022

# GENERIC VARIABLES #########################################################
export HOSTNAME=$(hostname)

export EDITOR="vim"
export TERMINAL="termite"
export BROWSER="qutebrowser"

export CFG_COMMAND="/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME"
export GNUPGHOME="$HOME/.gnupg"
export TEXMFHOME="$HOME/.texmf"
export TMPHOME="/tmp/cagprado"
export LIBVA_DRIVER_NAME="iHD"
export MOZ_USE_XINPUT2=1
export MOZ_X11_EGL=1

# xdg
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CACHE_HOME="$HOME/.cache"

# printers
export HOMEPRINTER=""
export WORKPRINTER="kmc368"
export PRINTER=$WORKPRINTER

# build
export LOCALBUILDS="$HOME/usr/local"
export MAKEFLAGS='-j -Otarget'

# interface
export LESS="-cx3MRFX"
export LESSCOLORIZER="pygmentize"
export LESSOPEN="| lesspipe %s"

# KEYRING ###################################################################
if [[ -n "$DESKTOP_SESSION" ]]; then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# REMOTE SESSION CONFIGURATION ##############################################

if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || "$(ps -o comm= -p $PPID)" =~ "^.*/sshd$|^sshd$" ]]; then
    export REMOTE_SESSION=true

    # first get rid of LD_LIBRARY_PATH poison =P
    unsetopt GLOBAL_RCS
    unset LD_LIBRARY_PATH

    # then fix some common version problems
    [[ "${$(make -v)[3]}" -lt 4 ]] && export MAKEFLAGS='-j'

    # now load some environment specific configuration
    if [[ -f "/cvmfs/alice.cern.ch/etc/login.sh" ]]; then
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
    [[ -d "$LOCALBUILDS/root5" ]] && PATH="$LOCALBUILDS/root5/bin:$PATH"
    [[ -d "$LOCALBUILDS/root" ]] && PATH="$LOCALBUILDS/root/bin:$PATH"
    [[ -d "$LOCALBUILDS/neovim" ]] && PATH="$LOCALBUILDS/neovim/bin:$PATH"
fi

# SET PATH AND COMPILE ZSH FILES ############################################
zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)
zcompile $HOME/.zshenv
zcompile $HOME/.zprofile
zcompile $HOME/.zshrc
zcompile $HOME/.zlogout
export PATH="$HOME/bin:$PATH"

# CONSOLE ###################################################################
if [[ "$TERM" =~ linux && -z "$SSH_CONNECTION" ]]; then
    tput setab 7
    tput setaf 0
    echo -ne "\e]P04d4d4c\e]P8000000"
    echo -ne "\e]P1c82829\e]P9ff3334"
    echo -ne "\e]P2718c00\e]PA9ec400"
    echo -ne "\e]P3f5871f\e]PBeab700"
    echo -ne "\e]P44271ae\e]PC5795e6"
    echo -ne "\e]P58959a8\e]PDb777e0"
    echo -ne "\e]P63e999f\e]PE54ced6"
    echo -ne "\e]P7fafafa\e]PF8e908c"
    echo -ne "\e[8]\e[1;15]"
    clear
fi
