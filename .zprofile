# ZSH Configuration
# Profile - loaded in login shell

#unsetopt GLOBAL_RCS    # prevent shell from reading global configuration

[[ "$(id -un)" == "$(id -gn)" ]] && umask 002 || umask 022

# GENERIC VARIABLES #########################################################
export CFG_COMMAND="/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME"
export EDITOR=vim
export DE="generic"                    # generic desktop environment for xdg
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

# HOSTNAMES #################################################################
export HOSTNAME=$(hostname)
export HOME_ADDR="mredson.home.kg"
[[ "$HOSTNAME" =~ "sampa" ]] && export AT_SAMPA_VALUE=true && export AT_HOME_VALUE=false || export AT_SAMPA_VALUE=false

# HOST SPECIFIC VARIABLES ###################################################
if [[ "$AT_SAMPA_VALUE" = "true" ]]; then
  export MAKEFLAGS='-j12'

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
  PATH="$HOME/usr/local/cmake/bin:$PATH"  # CMAKE-3.4
  PATH="$HOME/usr/local/Python/bin:$PATH" # PYTHON-2.7.11
  PATH="$HOME/usr/local/pythia/bin:$PATH" # PYTHIA-8212
  PATH="$HOME/usr/local/root/bin:$PATH"   # ROOT-6.05.02
  #PATH="$HOME/usr/local/root5/bin:$PATH"  # ROOT-5.34.34

  ## CUDA
  #export CUDA_PATH="/usr/local/cuda-6.0"
  #path=($CUDA_PATH/bin $path)
  #export GLPATH=/usr/lib64

  ## OpenCL
  #export AMDAPPSDKROOT="/sampa/cagprado/opt/amd_app_sdk/AMDAPPSDK-2.9.1"
  #path=($AMDAPPSDKROOT/bin/x86_64 $path)

  #export LD_LIBRARY_PATH=.:$AMDAPPSDKROOT/lib/x86_64:$CUDA_PATH/lib64:$LD_LIBRARY_PATH
fi

# SET HOME AT HEAD OF PATH
export PATH="$HOME/bin:$PATH"

# COMPILE ZSH FILES #########################################################
zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)
zcompile $HOME/.zshenv
zcompile $HOME/.zprofile
zcompile $HOME/.zshrc
zcompile $HOME/.zlogout
