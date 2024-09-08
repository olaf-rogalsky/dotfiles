# -*- mode: sh -*-

# .bashrc is for interactive shells, only.
[[ $- != *i* ]] && return

# If not already sourced, source .profile
[ -z "$PROFILEREAD" -a -r "$HOME/.profile" ] && source "$HOME/.profile"

# Interactive bash sources /etc/profile, which itself sources
# /etc/bash.bashrc which then sets PROMPT_COMMAND.  Undo the
# system-wide PROMPT_COMMAND initialization which sets the terminal
# title, causing flicker because my own PS1 overwrites this title.
PROMPT_COMMAND=

# history settings
HISTCONTROL=ignoredups
HISTSIZE=10000
HISTFILESIZE=20000

# localization: sort "ls" listing with dot-files first
export LC_COLLATE=C.UTF-8

# disable "!"-style history substitution
set +o histexpand

# append to the history file, don't overwrite it
shopt -s histappend

# enable extended globbing and recursive **-globbing
shopt -s extglob
shopt -s globstar

# use ascii collating order in bracketed character ranges, so that the range [A-Z] does not match the character 'b' 
shopt -s globasciiranges

# let internal echo command expand backslashed escape sequences
shopt -s xpg_echo

# Enable checkwinsize so that bash will check the terminal size when it regains control.
shopt -s checkwinsize

# Tab-expand shell variables if part of a path
shopt -s direxpand

# MSYS2 / wsl related initializations
export IS_MSYS=$(test "$OSTYPE" = "msys" && echo true || echo false)
export IS_WSL=$([ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ] && echo true || echo false)
if $IS_MSYS || $IS_WSL; then
    [ -r "$MSYSTEM_PREFIX/etc/bash.bashrc" ] && source "$MSYSTEM_PREFIX/etc/bash.bashrc"
    [ -r "$HOME/.ssh-agent-env" ] && source "$HOME/.ssh-agent-env" # make sure, that SSH_AUTH_SOCK is set for ssh-add 
    ssh-add -l >&- 2>&-
    if [ "$?" = 2 ]; then
        ( umask 077
          ssh-agent | sed -e '/^ *echo/ d' > "$HOME/.ssh-agent-env"
        ) # also make sure, that .ssh/config has "AddsKeysToAgent yes"
        source "$HOME/.ssh-agent-env"
    fi
    unset MATHEMATICA_HOME MATHEMATICA_BASE BROWSER GTK2_RC_FILES QT_QPA_PLATFORMTHEME
fi

# Initialize bash completion.
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# use git completion for my own dotcfg command
source /usr/share/bash-completion/completions/git
___git_complete dotcfg __git_main

# enable colors
colortty=true

if $colortty; then
    sgr0="$(tput sgr0)"
    fgred="$(tput setaf 1)"
    fggreen="$(tput setaf 2)"
    fgyellow="$(tput setaf 3)"
    fgblue="$(tput setaf 4)"
    fgmagenta="$(tput setaf 5)"
    fgcyan="$(tput setaf 6)"
    fgwhite="$(tput setaf 7)"
    fgbgdefault="$(tput op)"
    bold="$(tput bold)"
fi

if [ "$USER" = root ]; then
    PS1="\w#"
else
    PS1="\w>"
fi

if [ "$XTERM_VERSION" != "" ]; then
    stty -echo                  # work around a bug in bash or xterm: inhibit echoing of input characters
    echo -ne '\e[?1;3;256S'     # enable 256 SIXEL colors
    read -t 0.2 -rsd S          # read back answer string up to 'S' character, but wait at most 0.2 seconds
    echo -ne '\e[1070h'         # use private colors for each SIXEL and ReGIS graphics
    echo -ne '\e[?80h'          # enable SIXEL scrolling
    stty echo                   # reenable echoing of input characters
fi

# make a color prompt
PS1="\[${sgr0}${fgcyan}\]${PS1}\[${fgbgdefault}\]"

# enable xterm readline-support
case "$TERM" in
    xterm-*color|xterm-*direct)
        PS1="\[\e[?2001;2002;2003h\]${PS1}"
esac

# update terminal title
case "$TERM" in
    xterm*|rxvt*|kitty*|wezterm*)
        test "$USER" != y1rog -a "$HOSTNAME" != blaubaer && title="\u@\h: \w"
        test "$USER"  = y1rog -a "$HOSTNAME" != blaubaer && title="@\h: \w"
        test "$USER" != y1rog -a "$HOSTNAME"  = blaubaer && title="\u: \w"
        test "$USER"  = y1rog -a "$HOSTNAME"  = blaubaer && title="\w"
        PS1="\[\e]0;$title\a\]$PS1"
        unset title;;
esac

# tmux indication
case "$TERM" in
    tmux*) PS1="\[${fgred}${bold}\]T\[${sgr}\] $PS1"
esac

# bwrap indication
if [ -n "$BWRAP" ]; then
    PS1="\[$fgred\][bwrap]\[$sgr0\] $PS1"
fi

# MSYS indication
$IS_MSYS && PS1="\[$fgmagenta\][$MSYSTEM]\[$sgr0\] $PS1"

# WSL indication
$IS_WSL && PS1="\[$fgmagenta\][WSL]\[$sgr0\] $PS1"

# enable color support of ls and also add handy aliases
if [ "$colortty" == true -a -x /usr/bin/dircolors ]; then
    # test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    # use "snazzy" color theme of https://github.com/sharkdp/vivid
    export LS_COLORS='mi=0;38;2;0;0;0;48;2;255;92;87:ex=1;38;2;255;92;87:no=0:do=0;38;2;0;0;0;48;2;255;106;193:ca=0:st=0:di=0;38;2;87;199;255:ln=0;38;2;255;106;193:sg=0:ow=0:*~=0;38;2;102;102;102:mh=0:so=0;38;2;0;0;0;48;2;255;106;193:pi=0;38;2;0;0;0;48;2;87;199;255:bd=0;38;2;154;237;254;48;2;51;51;51:or=0;38;2;0;0;0;48;2;255;92;87:fi=0:tw=0:su=0:cd=0;38;2;255;106;193;48;2;51;51;51:rs=0:*.h=0;38;2;90;247;142:*.c=0;38;2;90;247;142:*.a=1;38;2;255;92;87:*.m=0;38;2;90;247;142:*.o=0;38;2;102;102;102:*.t=0;38;2;90;247;142:*.z=4;38;2;154;237;254:*.d=0;38;2;90;247;142:*.p=0;38;2;90;247;142:*.r=0;38;2;90;247;142:*.jl=0;38;2;90;247;142:*.nb=0;38;2;90;247;142:*.pm=0;38;2;90;247;142:*.ko=1;38;2;255;92;87:*.td=0;38;2;90;247;142:*.vb=0;38;2;90;247;142:*.bz=4;38;2;154;237;254:*.js=0;38;2;90;247;142:*.el=0;38;2;90;247;142:*.ps=0;38;2;255;92;87:*.gv=0;38;2;90;247;142:*.wv=0;38;2;255;180;223:*.kt=0;38;2;90;247;142:*.cr=0;38;2;90;247;142:*.ui=0;38;2;243;249;157:*.go=0;38;2;90;247;142:*.cp=0;38;2;90;247;142:*.bc=0;38;2;102;102;102:*.hh=0;38;2;90;247;142:*.ml=0;38;2;90;247;142:*.ex=0;38;2;90;247;142:*.mn=0;38;2;90;247;142:*.hi=0;38;2;102;102;102:*.hs=0;38;2;90;247;142:*.cc=0;38;2;90;247;142:*.as=0;38;2;90;247;142:*.pp=0;38;2;90;247;142:*.md=0;38;2;243;249;157:*.7z=4;38;2;154;237;254:*.ll=0;38;2;90;247;142:*.so=1;38;2;255;92;87:*.rm=0;38;2;255;180;223:*.py=0;38;2;90;247;142:*.rs=0;38;2;90;247;142:*.xz=4;38;2;154;237;254:*.la=0;38;2;102;102;102:*.rb=0;38;2;90;247;142:*.fs=0;38;2;90;247;142:*.ts=0;38;2;90;247;142:*.di=0;38;2;90;247;142:*.cs=0;38;2;90;247;142:*css=0;38;2;90;247;142:*.lo=0;38;2;102;102;102:*.pl=0;38;2;90;247;142:*.gz=4;38;2;154;237;254:*.sh=0;38;2;90;247;142:*.vcd=4;38;2;154;237;254:*hgrc=0;38;2;165;255;195:*.rst=0;38;2;243;249;157:*.psd=0;38;2;255;180;223:*.mpg=0;38;2;255;180;223:*.deb=4;38;2;154;237;254:*.pyo=0;38;2;102;102;102:*.ltx=0;38;2;90;247;142:*.sxw=0;38;2;255;92;87:*.bz2=4;38;2;154;237;254:*.tex=0;38;2;90;247;142:*.odt=0;38;2;255;92;87:*.def=0;38;2;90;247;142:*.wmv=0;38;2;255;180;223:*.flv=0;38;2;255;180;223:*.cfg=0;38;2;243;249;157:*.pyc=0;38;2;102;102;102:*.tsx=0;38;2;90;247;142:*.tgz=4;38;2;154;237;254:*.exs=0;38;2;90;247;142:*.xml=0;38;2;243;249;157:*.ics=0;38;2;255;92;87:*.xmp=0;38;2;243;249;157:*.tar=4;38;2;154;237;254:*.arj=4;38;2;154;237;254:*.rpm=4;38;2;154;237;254:*.jar=4;38;2;154;237;254:*.sxi=0;38;2;255;92;87:*.ico=0;38;2;255;180;223:*.img=4;38;2;154;237;254:*.aif=0;38;2;255;180;223:*.php=0;38;2;90;247;142:*.sty=0;38;2;102;102;102:*.mp4=0;38;2;255;180;223:*.gif=0;38;2;255;180;223:*.bib=0;38;2;243;249;157:*.pid=0;38;2;102;102;102:*.mir=0;38;2;90;247;142:*.odp=0;38;2;255;92;87:*.bin=4;38;2;154;237;254:*.bak=0;38;2;102;102;102:*.bst=0;38;2;243;249;157:*.nix=0;38;2;243;249;157:*.txt=0;38;2;243;249;157:*.wav=0;38;2;255;180;223:*.kts=0;38;2;90;247;142:*.ppm=0;38;2;255;180;223:*.lua=0;38;2;90;247;142:*.h++=0;38;2;90;247;142:*.swp=0;38;2;102;102;102:*.cxx=0;38;2;90;247;142:*.cpp=0;38;2;90;247;142:*.pas=0;38;2;90;247;142:*.log=0;38;2;102;102;102:*.sbt=0;38;2;90;247;142:*.inl=0;38;2;90;247;142:*.dot=0;38;2;90;247;142:*.blg=0;38;2;102;102;102:*.ods=0;38;2;255;92;87:*.bcf=0;38;2;102;102;102:*.erl=0;38;2;90;247;142:*.bmp=0;38;2;255;180;223:*.elm=0;38;2;90;247;142:*.csx=0;38;2;90;247;142:*.rar=4;38;2;154;237;254:*.c++=0;38;2;90;247;142:*.xlr=0;38;2;255;92;87:*.sql=0;38;2;90;247;142:*.fon=0;38;2;255;180;223:*.dll=1;38;2;255;92;87:*.clj=0;38;2;90;247;142:*.fsi=0;38;2;90;247;142:*.pps=0;38;2;255;92;87:*.asa=0;38;2;90;247;142:*.tcl=0;38;2;90;247;142:*.exe=1;38;2;255;92;87:*.mid=0;38;2;255;180;223:*.csv=0;38;2;243;249;157:*.ipp=0;38;2;90;247;142:*.epp=0;38;2;90;247;142:*.zsh=0;38;2;90;247;142:*.gvy=0;38;2;90;247;142:*.pgm=0;38;2;255;180;223:*.ps1=0;38;2;90;247;142:*.ttf=0;38;2;255;180;223:*.bsh=0;38;2;90;247;142:*.fsx=0;38;2;90;247;142:*.vim=0;38;2;90;247;142:*.zst=4;38;2;154;237;254:*.png=0;38;2;255;180;223:*.dpr=0;38;2;90;247;142:*.rtf=0;38;2;255;92;87:*.ilg=0;38;2;102;102;102:*.apk=4;38;2;154;237;254:*TODO=1:*.htm=0;38;2;243;249;157:*.wma=0;38;2;255;180;223:*.xcf=0;38;2;255;180;223:*.cgi=0;38;2;90;247;142:*.fnt=0;38;2;255;180;223:*.xls=0;38;2;255;92;87:*.aux=0;38;2;102;102;102:*.pdf=0;38;2;255;92;87:*.ini=0;38;2;243;249;157:*.pbm=0;38;2;255;180;223:*.tml=0;38;2;243;249;157:*.tif=0;38;2;255;180;223:*.inc=0;38;2;90;247;142:*.eps=0;38;2;255;180;223:*.fls=0;38;2;102;102;102:*.mkv=0;38;2;255;180;223:*.out=0;38;2;102;102;102:*.mov=0;38;2;255;180;223:*.ogg=0;38;2;255;180;223:*.ind=0;38;2;102;102;102:*.bat=1;38;2;255;92;87:*.bag=4;38;2;154;237;254:*.dox=0;38;2;165;255;195:*.tbz=4;38;2;154;237;254:*.m4a=0;38;2;255;180;223:*.com=1;38;2;255;92;87:*.dmg=4;38;2;154;237;254:*.mli=0;38;2;90;247;142:*.htc=0;38;2;90;247;142:*.yml=0;38;2;243;249;157:*.swf=0;38;2;255;180;223:*.pro=0;38;2;165;255;195:*.hxx=0;38;2;90;247;142:*.mp3=0;38;2;255;180;223:*.jpg=0;38;2;255;180;223:*.bbl=0;38;2;102;102;102:*.tmp=0;38;2;102;102;102:*.iso=4;38;2;154;237;254:*.ppt=0;38;2;255;92;87:*.pyd=0;38;2;102;102;102:*.idx=0;38;2;102;102;102:*.toc=0;38;2;102;102;102:*.pod=0;38;2;90;247;142:*.zip=4;38;2;154;237;254:*.m4v=0;38;2;255;180;223:*.awk=0;38;2;90;247;142:*.doc=0;38;2;255;92;87:*.kex=0;38;2;255;92;87:*.otf=0;38;2;255;180;223:*.pkg=4;38;2;154;237;254:*.git=0;38;2;102;102;102:*.avi=0;38;2;255;180;223:*.hpp=0;38;2;90;247;142:*.vob=0;38;2;255;180;223:*.svg=0;38;2;255;180;223:*.lock=0;38;2;102;102;102:*.flac=0;38;2;255;180;223:*.webm=0;38;2;255;180;223:*.conf=0;38;2;243;249;157:*.opus=0;38;2;255;180;223:*.docx=0;38;2;255;92;87:*.diff=0;38;2;90;247;142:*.pptx=0;38;2;255;92;87:*.dart=0;38;2;90;247;142:*.java=0;38;2;90;247;142:*.toml=0;38;2;243;249;157:*.json=0;38;2;243;249;157:*.yaml=0;38;2;243;249;157:*.tiff=0;38;2;255;180;223:*.make=0;38;2;165;255;195:*.mpeg=0;38;2;255;180;223:*.html=0;38;2;243;249;157:*.h264=0;38;2;255;180;223:*.jpeg=0;38;2;255;180;223:*.psd1=0;38;2;90;247;142:*.epub=0;38;2;255;92;87:*.psm1=0;38;2;90;247;142:*.fish=0;38;2;90;247;142:*.xlsx=0;38;2;255;92;87:*.rlib=0;38;2;102;102;102:*.bash=0;38;2;90;247;142:*.lisp=0;38;2;90;247;142:*.purs=0;38;2;90;247;142:*.hgrc=0;38;2;165;255;195:*.less=0;38;2;90;247;142:*.orig=0;38;2;102;102;102:*.tbz2=4;38;2;154;237;254:*.mdown=0;38;2;243;249;157:*.cache=0;38;2;102;102;102:*.swift=0;38;2;90;247;142:*.cabal=0;38;2;90;247;142:*.dyn_o=0;38;2;102;102;102:*README=0;38;2;40;42;54;48;2;243;249;157:*.cmake=0;38;2;165;255;195:*shadow=0;38;2;243;249;157:*.ipynb=0;38;2;90;247;142:*passwd=0;38;2;243;249;157:*.scala=0;38;2;90;247;142:*.class=0;38;2;102;102;102:*.xhtml=0;38;2;243;249;157:*.toast=4;38;2;154;237;254:*.patch=0;38;2;90;247;142:*.shtml=0;38;2;243;249;157:*.matlab=0;38;2;90;247;142:*.dyn_hi=0;38;2;102;102;102:*COPYING=0;38;2;153;153;153:*.config=0;38;2;243;249;157:*INSTALL=0;38;2;40;42;54;48;2;243;249;157:*.ignore=0;38;2;165;255;195:*.groovy=0;38;2;90;247;142:*TODO.md=1:*LICENSE=0;38;2;153;153;153:*.flake8=0;38;2;165;255;195:*.gradle=0;38;2;90;247;142:*TODO.txt=1:*Makefile=0;38;2;165;255;195:*.desktop=0;38;2;243;249;157:*.gemspec=0;38;2;165;255;195:*setup.py=0;38;2;165;255;195:*Doxyfile=0;38;2;165;255;195:*README.md=0;38;2;40;42;54;48;2;243;249;157:*.rgignore=0;38;2;165;255;195:*.DS_Store=0;38;2;102;102;102:*configure=0;38;2;165;255;195:*.fdignore=0;38;2;165;255;195:*COPYRIGHT=0;38;2;153;153;153:*.cmake.in=0;38;2;165;255;195:*.kdevelop=0;38;2;165;255;195:*.markdown=0;38;2;243;249;157:*SConstruct=0;38;2;165;255;195:*.localized=0;38;2;102;102;102:*.gitignore=0;38;2;165;255;195:*SConscript=0;38;2;165;255;195:*.gitconfig=0;38;2;165;255;195:*INSTALL.md=0;38;2;40;42;54;48;2;243;249;157:*README.txt=0;38;2;40;42;54;48;2;243;249;157:*Dockerfile=0;38;2;243;249;157:*.scons_opt=0;38;2;102;102;102:*CODEOWNERS=0;38;2;165;255;195:*INSTALL.txt=0;38;2;40;42;54;48;2;243;249;157:*.travis.yml=0;38;2;90;247;142:*Makefile.am=0;38;2;165;255;195:*Makefile.in=0;38;2;102;102;102:*MANIFEST.in=0;38;2;165;255;195:*.gitmodules=0;38;2;165;255;195:*.synctex.gz=0;38;2;102;102;102:*LICENSE-MIT=0;38;2;153;153;153:*.applescript=0;38;2;90;247;142:*.fdb_latexmk=0;38;2;102;102;102:*appveyor.yml=0;38;2;90;247;142:*configure.ac=0;38;2;165;255;195:*CONTRIBUTORS=0;38;2;40;42;54;48;2;243;249;157:*.clang-format=0;38;2;165;255;195:*.gitattributes=0;38;2;165;255;195:*LICENSE-APACHE=0;38;2;153;153;153:*CMakeLists.txt=0;38;2;165;255;195:*CMakeCache.txt=0;38;2;102;102;102:*CONTRIBUTORS.md=0;38;2;40;42;54;48;2;243;249;157:*CONTRIBUTORS.txt=0;38;2;40;42;54;48;2;243;249;157:*requirements.txt=0;38;2;165;255;195:*.sconsign.dblite=0;38;2;102;102;102:*package-lock.json=0;38;2;102;102;102:*.CFUserTextEncoding=0;38;2;102;102;102'
    export EXA_COLORS="$LS_COLORS:sn=0;38;2;150;150;150:sb=0;38;2;150;150;150:df=0:ds=0:uu=0;38;2;150;150;150:un=0;38;2;243;249;157:lc=31:da=0;38;2;150;150;150"
    export EZA_COLORS="$EXA_COLORS"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

test -s /etc/profile.d/autojump.sh && source /etc/profile.d/autojump.sh

# wezterm integration
if [ "$TERM_PROGRAM" = "WezTerm" ]; then
    # tell wezterm the current PWD
    PS1="\[\e]7;file://\h\$PWD\e\\\\\\]$PS1"
    # semantic zone
    PS0="\e]133;C\a"
    PS1="\[\e]133;P;k=i\a\]$PS1\[\e]133;B\a\]"
    PS2="\[\e]133;P;k=s\a\]$PS2\[\e]133;B\a\]"
fi

# allow root access to X11
xhost +local:root > /dev/null 2>&1

# Do "file name" and "command" completion for sudo command lines
complete -cf sudo

# removes one ore more paths from $PATH
function rmpath() {
    local path qpath
    for path in "$@"; do
        path="${path%/}"
        PATH="${PATH#$path?(\/):}"
        PATH="${PATH%:$path?(\/)}"
        PATH="${PATH//:$path?(\/):/:}"
    done
}

# adds one or more paths to the front of $PATH
function addpath() {
    local args path
    rmpath "$@"
    for ((i = $#; i > 0; i--)); do
        path="${!i%/}"
        PATH="$path:$PATH"
    done
}

addpath . /home/y1rog/bin /home/y1rog/.local/bin /usr/local/sbin /math/optik /opt/gerbil/bin

# Variables
export PRINTER="kyocera"
export LESS='-eFRS --use-backslash --use-color -DRr-$ --shift=3 --rscroll=\$$ --mouse --wheel-lines=1'
export EDITOR=jed
export VISUAL=jed
export JULIA_NUM_THREADS=2

#export LD_LIBRARY_PATH=$HOME/local/lib:$HOME/local/lib/oase:/math/optik/lib/mkl-2017.U1/lib:/math/optik/lib/gui/cz_qt-5.10.0/lib
#export PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig
#export QT_PLUGIN_PATH=/math/optik/lib/gui/cz_qt-5.10.0/plugins:/math/optik/lib/gui/cz_qt-5.10.0/plugins/platforminputcontexts:/math/optik/lib/gui/cz_qt-5.10.0/plugins/platforms
#export MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330 # allow GL programs - like alacritty - to run, which test for GL v3.3, but actually don't need it


# unset temporary variables
unset colortty sgr0 bgwhite bgblack fgwhite fggreen fgcyan fgred bold

# aliases
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
# alias ll='ls -lh'
# alias la='ls -lhA'
# alias l='ls'
# alias lrt='ls -lhrt'
# alias lart='ls -lArt'
function l {
    if test -t 1; then
        if type -P exa >/dev/null; then
            exa --git --icons "$@"
        elif type -P eza >/dev/null; then
            eza --git --icons "$@"
        else
            ls "$@"
        fi
    else
        ls "$@"
    fi
}
alias ll='l -l'
alias la='l -la'
alias lrt='l -ls changed'
alias lart='l -las changed'
alias unrar='unrar -y -kb'
alias jed="emacs -nw"
alias gcal="LANG=de_DE.utf8 gcal"
alias feh="feh -Tdefault"
alias icat="kitty +kitten icat"

function .. {
    cd ..
}

function - {
    cd -
}

function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

function sendrecv {
    local a
    local quiet
    if [ "$1" == "-q" ]; then
        shift
        quiet=true
    else
        quiet=false
    fi
    #trap "stty echo; trap - SIGINT RETURN" SIGINT RETURN
    stty -echo
    echo -en "$1"
    stty echo
    sleep 0.02
    read -srd"${2-${1: -1:1}}" a
    $quiet && printf "%q\n" "$a${2-${1: -1:1}}"
    __="$a"
}

function sane {
    stty sane
    echo -ne "\ec"
}

function hc {
    herbstclient "$@"
}
if [ -r /usr/share/bash-completion/completions/herbstclient ]; then
  source /usr/share/bash-completion/completions/herbstclient
  complete -F _herbstclient_complete -o nospace hc
fi

# emacs eat-shell integration
test -n "$EAT_SHELL_INTEGRATION_DIR" && source "$EAT_SHELL_INTEGRATION_DIR/bash"

# portable clipboard handling
function getclip {
    if $IS_WSL || $IS_MSYS; then
        powershell.exe -command Get-Clipboard
    else
        [ "$DISPLAY" != "" ] && xsel -b -o
    fi
}

function setclip {
    # echo -n $"\e]52;s;$(echo "$*" | base64)\e\\"; return 0
    if $IS_WSL || $IS_MSYS; then
        powershell.exe -command Set-Clipboard "$*"
    else
        [ "$DISPLAY" != "" ] && xsel -b -i
    fi &
}


# using the xclipboard in the readline
function _kill {
    echo "${READLINE_LINE:READLINE_POINT}" | setclip
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}"
}
bind -x '"\C-k": _kill'   

function _kill_region {
    local _start _end _len
    if [[ READLINE_POINT < READLINE_MARK ]]; then
        ((_start = READLINE_POINT))
        ((_end = READLINE_MARK))
        ((_len = _end - _start))
    else
        ((_start = READLINE_MARK))
        ((_end = READLINE_POINT))
        ((_len = _end - _start))
    fi
    echo "${READLINE_LINE:_start:_len}" | setclip
    READLINE_LINE="${READLINE_LINE:0:_start}${READLINE_LINE:_end}"
    READLINE_POINT=$_start
}
bind -x '"\C-w": _kill_region'   

function _kill_ring_save {
    local _start _end _len
    if [[ READLINE_POINT < READLINE_MARK ]]; then
        ((_start = READLINE_POINT))
        ((_end = READLINE_MARK))
        ((_len = _end - _start))
    else
        ((_start = READLINE_MARK))
        ((_end = READLINE_POINT))
        ((_len = _end - _start))
    fi
    echo "${READLINE_LINE:_start:_len}" | xsel -i
}
bind -x '"\ew": _kill_ring_save'   

function _kill_word {
    local _start _end _len _rest _tail _non_word _word
    _tail="${READLINE_LINE:READLINE_POINT}"
    _non_word="${_tail##*([^a-zA-Z0-9_])*([a-zA-Z0-9_])}"
    _word="${_tail:0:${#_tail} - ${#_non_word}}"
    _len="${#_word}"
    ((_start = READLINE_POINT))
    ((_end = _start + _len))
    echo "$_word" | setclip
    READLINE_LINE="${READLINE_LINE:0:_start}${READLINE_LINE:_end}"
    READLINE_POINT=$_start
}
bind -x '"\ed": _kill_word'   

function _yank {
    _clipboard="$(getclip)"
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}$_clipboard${READLINE_LINE:READLINE_POINT}"
    ((READLINE_POINT+=${#_clipboard}))
}
bind -x '"\C-y": _yank'   

    
# node package manager
if [ -d "$HOME/.config/nvm" ]; then
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
