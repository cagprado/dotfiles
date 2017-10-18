# Interactive shell (not run by scripts)

# Options ###################################################################
unsetopt bgnice
setopt notify longlistjobs extendedglob globdots autocd correct autonamedirs
setopt histignoredups appendhistory histverify histignorespace autolist
setopt autopushd pushdsilent pushdtohome pushdminus pushdignoredups

# Autoload functions from zsh scripts! Only +x files are selected
# Old way, keep in case the new one doesn't work: (){ setopt localoptions histsubstpattern; for func in $ZSH_FUNCTIONS/*(N-.x:t); autoload -U $func }
for func in $ZSH_FUNCTIONS/*(.x:t); do autoload -Uz $func; done

# Aliases ###################################################################

# jobs and interface
alias d='dirs -v'
alias h='history'
alias j='jobs -l'

# system
alias cfg="$CFG_COMMAND"
alias df='df -h'
alias dmesg='dmesg -e'
alias du='du -h'
alias free='free -h'
alias grep='egrep --color=auto'
alias ls='ls --quoting-style=literal --color=auto -Fh --group-directories-first'
alias lsa='ls -A'
alias lsl='ls -l'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'

# compiler
alias asy='asy -nosafe'
alias asyinline='asy -inlinetex'
alias ccorp-config='echo -I$HOME/usr/local/ccorp/include -L$HOME/usr/local/ccorp/lib -lccorp -Wl,-rpath,$HOME/usr/local/ccorp/lib'
alias GCC='gcc -Wall -ansi -O2'
alias G++='g++ -Wall -O4 --std=c++11 $=LDFLAGS'
alias root-config='root-config --cflags --libs'

# ssh and certificates
alias certutil='certutil -d sql:$HOME/.pki/nssdb'
alias pk12util='pk12util -d sql:$HOME/.pki/nssdb'

# ssh
alias ifusp='fusessh -p $HOME/ifusp -s ifusp'
alias lp='lp -d $(printer) -o collate=true'
[[ "$AT_SAMPA_VALUE" = "true" ]] && alias qstat='qstat -u cagprado -t' || alias qstat='ssh cagprado@$SAMPA qstat -u cagprado -t'
alias sampa='fusessh -p $HOME/sampa -s sampa'

# utils
alias dropbox='dropbox-cli'
alias o='xdg-open'
alias zshfunctions='zcompile -Uz $ZSH_FUNCTIONS $ZSH_FUNCTIONS/*(.x)'

# buggy programs (application mode)
function app() { echoti smkx && $@ && echoti rmkx }
alias alot='app alot'
alias ncmpcpp='app ncmpcpp'

# lists all aliases and scripts
scripts()
{
  local -x LIST_WIDTH=25
  local FILE

  print -P "%BALIASES%b"
  eval "$(alias | sed -e "s|^\([^=]*\)='\?\([^']*\)'\?.*$|print -P -f '%${LIST_WIDTH}s  %s\\\\n' '%B\1%b' '\2';|")"

  print -P "\n%BZSH FUNCTIONS%b"
  for FILE in $ZSH_FUNCTIONS/*(.x:t); do $FILE -H; done

  print -P "\n%BSCRIPTS%b"
  #for FILE in $BIN/*(.x); do echo $FILE; done
}

# Colors and fonts ##########################################################
if [[ "$TERM" =~ linux && -z "$SSH_CONNECTION" ]]; then
  colors
  setfont $HOME/.local/share/fonts/bitmap/tamsyn-patched/Tamsyn8x16r.psf.gz
fi
[[ -r $HOME/etc/dircolors ]] && eval $(dircolors "$HOME/etc/dircolors")
export LESS_TERMCAP_so=$(tput setaf 3; tput smso)     # begin standout
export LESS_TERMCAP_se=$(tput sgr0; tput rmso)        # end standout
export LESS_TERMCAP_us=$(tput sitm; tput setaf 6)     # begin underline (italic)
export LESS_TERMCAP_ue=$(tput ritm; tput sgr0)        # end underline
export LESS_TERMCAP_md=$(tput bold;)                  # begin bold
export LESS_TERMCAP_mb=$(tput blink)                  # starts blink
export LESS_TERMCAP_me=$(tput sgr0)                   # end blink/bold/standout/underline

# Completion ################################################################
zmodload zsh/complist
autoload -U compinit && compinit
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle ':completion:*' format '%B---- %d%b'
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}completing %B%d%b{\e[0m%}'
zstyle ':completion:*:messages' format '%B%U---- %d%u%b'
zstyle ':completion:*:warnings' format "%B$fg[red]%}---- no match for: $fg[white]%d%b"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' hosts $(awk '/^Host [^*]/ { print $2 }' $HOME/.ssh/config | sort -u)
[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source /usr/share/doc/pkgfile/command-not-found.zsh || :

# ZLE and Keybindings #######################################################

bindkey -v                         # use vim mode
bindkey '^?' backward-delete-char  # backspace past insert point
export KEYTIMEOUT=1                # set waiting time for escapes

# define cursor styles (Ss must be defined to a macro, not flag)
local cursor_normal="$(echoti Ss 2 2>/dev/null)"
if [[ $? -ne 0 || "$cursor_normal" = "yes" ]]; then
  local cursor_normal=""
  local cursor_replace=""
  local cursor_insert=""
else
  local cursor_replace="$(echoti Ss 4 2>/dev/null)"
  local cursor_insert="$(echoti Ss 6 2>/dev/null)"
fi

function select-cursor() {
  # select cursor when init and change keymap
  if [[ "$KEYMAP" == "vicmd" ]]; then
    echo -n $cursor_normal
  elif [[ $ZLE_STATE == *overwrite* ]]; then
    echo -n $cursor_replace
  else
    echo -n $cursor_insert
  fi
}

# set zle mode functions
function zle-line-init() { echoti smkx 2>/dev/null; select-cursor }
function zle-keymap-select() { select-cursor }
function zle-line-finish() { echoti rmkx 2>/dev/null }
function vi-replace-chars() { echo -n $cursor_replace; zle .vi-replace-chars -- "$@"; echo -n $cursor_normal }

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-finish
zle -N vi-replace-chars

# bind special keys (insert and command modes)
bindkey    "${terminfo[kdch1]}"    vi-delete-char
bindkey -a "${terminfo[kdch1]}"    vi-delete-char
bindkey    "${terminfo[khome]}"    beginning-of-line
bindkey -a "${terminfo[khome]}"    beginning-of-line
bindkey    "${terminfo[kend]}"     end-of-line
bindkey -a "${terminfo[kend]}"     end-of-line
bindkey    "${terminfo[kpp]}"      history-beginning-search-backward
bindkey -a "${terminfo[kpp]}"      history-beginning-search-backward
bindkey    "${terminfo[knp]}"      history-beginning-search-forward
bindkey -a "${terminfo[knp]}"      history-beginning-search-forward
bindkey    "^[q"                   push-line-or-edit  # Alt+q
bindkey -a "^[q"                   push-line-or-edit  # Alt+q

# Extra Interface ###########################################################

# History
HISTFILE="$HOME/.zshhist"
HISTSIZE=1000
SAVEHIST=1000

# Directories
cdpath=(~)      # cd <TAB> will always suggest content from paths listed here

# Named Directories
BIN=~/bin
ETC=~/etc
USR=~/usr
SRC=~/src
USP=~/usr/usp/pg/doutorado
OWNCLOUD=~/usr/owncloud

# Dirstack: cd -<TAB> for last visited directories
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
DIRSTACKSIZE=20

if [[ -f $DIRSTACKFILE && $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
cdUndoKey() {
  popd >/dev/null
  zle reset-prompt
  echo
  ls
  echo
}
cdParentKey() {
  pushd .. > /dev/null
  zle reset-prompt
  echo
  ls
  echo
}
zle -N                 cdParentKey
zle -N                 cdUndoKey
bindkey '^[[1;3A'      cdParentKey  # alt-up
bindkey '^[[1;3D'      cdUndoKey    # alt-left

# Prompt ####################################################################
zle_highlight=(bg_start_code:'\e[48;5;' bg_default_code:7 default:bg=254)

function precmd() { echo -ne '\a' }
function cfg_flag()
{
  if [[ "$TERM" =~ "linux" ]]; then
    $=CFG_COMMAND update-index --refresh >/dev/null || echo "%F{red}*%F{default}"
  else
    $=CFG_COMMAND update-index --refresh >/dev/null || echo "%F{red} %F{default}"
  fi
}
function batterystatus()
{
  # Set location of battery status files
  local CHARGE=/sys/class/power_supply/BAT0/charge_now
  local FULL=/sys/class/power_supply/BAT0/charge_full
  local STATUS=/sys/class/power_supply/BAT0/status

  # If file exists then we have battery
  if [[ -r $CHARGE ]]; then
    # Check if it's charging
    [[ "$(<$STATUS)" = "Charging" ]] && STATUS="%F{blue}" || STATUS=""

    # Eval current charge in battery
    local FRACTION="$((100 * $(<$CHARGE) / $(<$FULL)))"
    if [[ "$TERM" =~ "linux" ]]; then
      if [[ $FRACTION -le 5 ]]; then
        local ICON="%F{red}%F{blink}${STATUS}····"
      elif [[ $FRACTION -le 15 ]]; then
        local ICON="%F{yellow}${STATUS}█···"
      elif [[ $FRACTION -le 25 ]]; then
        local ICON="%F{green}${STATUS}█···"
      elif [[ $FRACTION -le 50 ]]; then
        local ICON="%F{green}${STATUS}██··"
      elif [[ $FRACTION -le 75 ]]; then
        local ICON="%F{green}${STATUS}███·"
      else
        local ICON="%F{green}${STATUS}████"
      fi
    else
      if [[ $FRACTION -le 5 ]]; then
        local ICON="%F{red}${STATUS}  "
      elif [[ $FRACTION -le 15 ]]; then
        local ICON="%F{yellow}${STATUS}  "
      elif [[ $FRACTION -le 25 ]]; then
        local ICON="%F{green}${STATUS}  "
      elif [[ $FRACTION -le 50 ]]; then
        local ICON="%F{green}${STATUS}  "
      elif [[ $FRACTION -le 75 ]]; then
        local ICON="%F{green}${STATUS}  "
      else
        local ICON="%F{green}${STATUS}  "
      fi
    fi

    # Print value
    echo $ICON
  fi
}

function setprompt()
{
  setopt prompt_subst
  local BLK="%{$(echoti setaf 0)%}"
  local RED="%{$(echoti setaf 1)%}"
  local GRE="%{$(echoti setaf 2)%}"
  local YEL="%{$(echoti setaf 3)%}"
  local BLU="%{$(echoti setaf 4)%}"
  local MAG="%{$(echoti setaf 5)%}"
  local CYA="%{$(echoti setaf 6)%}"
  local WHI="%{$(echoti setaf 7)%}"
  local BOL="%{$(echoti bold)%}"
  local BGR="%{$(echoti Tc >/dev/null 2>&1 && echo '\e[48;5;254m')%}"  # e4e4e4
  local DEF="%{$(echoti sgr0)%}"
  local NOR="%{$DEF$BGR%}"

  PROMPT="${NOR}[\$(batterystatus)$GRE%T$NOR%(1j./$RED%j$NOR.)] %(0?.$BLU.$RED)%n$NOR@$MAG$BOL%m$NOR\$(cfg_flag)%#$NOR "
  RPROMPT="$NOR @ $MAG%~$DEF"
}
setprompt

# Source syntax highlighting plugin
if ! atsampa && [[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Show a nice cowsay message
(which cowsay >/dev/null 2>&1) && (which fortune >/dev/null 2>&1) && cowsay $(fortune) || :
