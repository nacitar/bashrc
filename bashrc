#!/bin/env bash

###########################################################
#
# IF YOU SEE THIS, YOU SHOULDN'T BE CHANGING IT!!!!
#
# The file you should edit if you use this bashrc is
# located here: "$HOME/.bash/local/bashrc"
#
# Either make .bashrc a symlink to this:
# $ ln -s "$HOME/.bashrc" "$HOME/.bash/bashrc"
#
# OR, source it with
# $ source "$HOME/.bash/bashrc"
#
# OR, make your own from scratch using the framework by
# by copying the command below this comment into your bashrc.
#
###########################################################

# Allow system override of the path
if ! [ -d "$NX_LIBRARY_PATH" ]; then
    export NX_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
fi
# Extra care to make sure non-interactive doesn't fail with missing scripts
if [ -d "$NX_LIBRARY_PATH/environment" ]; then
    source "$NX_LIBRARY_PATH/environment"
fi
if [[ $- != *i* ]]; then
    return  # shell is non-interactive; bail
fi

if ! [ -d "$NX_LIBRARY_PATH" ]; then
    echo "[ERROR] NX_LIBRARY_PATH is invalid: $NX_LIBRARY_PATH" >&2
    return  # bail, library can't be found
fi

# Load the framework, or bail
source "$NX_LIBRARY_PATH/framework" || return


############
# LIBARIES #
############
nx_library termops tmux cdiff util


###############
# ENVIRONMENT #
###############

# Disable terminal blanking
setterm -blank 0 &>/dev/null
setterm -powersave off &>/dev/null
setterm -powerdown 0 &>/dev/null
# force ignoredups and ignorespace
export HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# disable history expansion so we can use ! in strings and filenames
set +H

# Get the number of CPU cores, if possible
export NX_CPU_CORES=$(grep "^processor" /proc/cpuinfo 2>/dev/null | wc -l)
if ! nx_isnum "$NX_CPU_CORES"; then
    export NX_CPU_CORES=2  # default
fi
export NX_BUILD_CORES=$(($NX_CPU_CORES + 1))  # one extra

# set the editors
if nx_path_search nvim &>/dev/null; then
	export SVN_EDITOR='nvim'
	export EDITOR='nvim'
	export VISUAL='nvim'
else
	export SVN_EDITOR='vim'
	export EDITOR='vim'
	export VISUAL='vim'
fi
export PAGER='less -R'

# Make aliases for directory listing
export NX_LS_DEF_FLAGS=''
# Check for alphabetical extension sorting support
if ls -X /dev/null &>/dev/null; then
  export NX_LS_DEF_FLAGS="$NX_LS_DEF_FLAGS -X"
fi
# Check for directory grouping support
if ls --group-directories-first /dev/null &>/dev/null; then
  export NX_LS_DEF_FLAGS="$NX_LS_DEF_FLAGS --group-directories-first"
fi

# If color is supported, we want to always use color where this flag is used.
if nx_tput_terminfo_colors &>/dev/null; then
    export NX_COLOR_FLAG='--color=always'
else
    export NX_COLOR_FLAG='--color=auto'
fi


##############
# TERM FIXES #
##############

# takes care of setting/adjusting the term, as well as caching low colors.
nx_check_term

# checks if our user is the same as our tmux session; caches to global variable too.
nx_check_tmux_user

# enable colorized ls output
nx_dircolors

# enable bash completion
nx_bash_completion


##########
# PROMPT #
##########

# use the default nx prompt
nx_bash_prompt

# set window titles too, and tmux titles
unset PROMPT_COMMAND
case "$TERM" in
  # If this is an xterm set the title to user@host:dir
  xterm*|rxvt*)
    PS1="\[\e]0;${NX_CHROOT:+($NX_CHROOT)}\u@\h: \w\a\]$PS1"
    ;;
  # If this is a screen session, set the window title.
  screen*)
    PROMPT_COMMAND='nx_prompt_command_for_tmux_titles'
    ;;
esac


###########
# ALIASES #
###########

# Alias to trim whitespace
alias trim='sed -e "s/^[[:space:]]*//;s/[[:space:]]*$//"'

# List files and directories
alias ls="ls --color=auto $NX_LS_DEF_FLAGS"
alias l="ls -F $NX_COLOR_FLAG"
alias la='l -A'
alias ll='l -l'
alias lal='l -Al'
# List only directories
alias lsd='ls -bd */'
alias lld='ls -bld */'
alias lald='ls -bAld */ .*/'

# This command strips color codes out of text, giving you "(b)are" text.
# Useful if trying to do ll > bla.txt, given my forced-color output.
# You can strip colors from a file via "bare -i filename", too :)
alias bare='sed "s/\x1B\[\([0-9]\{1,3\}\(\(;[0-9]\{1,3\}\)*\)\?\)\?[m|K]//g"'
alias b='bare'

# wrap diff to use colordiff if it's available or normal diff otherwise
alias diff='nx_diff_wrapper'
alias diffc='CDIFF_FORCE_COLOR=1 nx_diff_wrapper'

# enable svn wrapper that handles colordiff/cdiff and automatically colorizes
# diff if outputting to a terminal
alias svn='nx_svn_wrapper'

# grep (force colorizing match string)
alias grepc="grep $NX_COLOR_FLAG"
alias fgrepc="fgrep $NX_COLOR_FLAG"
alias egrepc="egrep $NX_COLOR_FLAG"

# grep (no colorizing match string)
alias grep='grep --color=none'
alias fgrep='fgrep --color=none'
alias egrep='egrep --color=none'

# a version of less that supports color output
alias less='less -R'

# less provides better usability than more
alias more='less'
alias m='less'

# Directory traversal
alias cd..='cd ..'
alias s='cd ..'
alias p='cd -'

# Convenience
alias md='mkdir'
alias rd='rmdir'
alias c='clear'
alias n='yes "" | head -n"${LINES:=100}"'

# Misc
if nx_path_search nvim &>/dev/null; then
	alias vi='nvim'
	alias vim='nvim'
	alias view='nvim -R'
	alias vimdiff='nvim -d'
else
	alias vi='vim'
	alias view='vim -R'
fi
alias emacs='emacs -nw'
alias df='df -h'
alias du='du -h'
alias dict='nx_dict'

# sudo preserves environment, rsudo gives the original sudo if you find this undesirable. 
alias rsudo='nx_nonaliased sudo'
alias sudo='sudo -E'

# Memory
# output: kb pid args
alias memtop='ps -e -orss=,pid=,args= | sort -b -k1,1n | pr -TW$COLUMNS'
alias memuse='echo "$(($(ps -e -orss= | paste -sd+)))"'
alias memtotal="cat /proc/meminfo | sed -n 's/^MemTotal:[[:space:]]*\([[:digit:]]*\).*$/\1/p'"
alias memfree='echo "$(($(memtotal)-$(memuse)))"'

nx_dealias mem
mem()
{
  local used="$(memuse)"
  local total="$(memtotal)"
  local free="$(($total-$used))"
  echo -e "Total:\t$total kB\nUsed:\t$used kB\nFree:\t$free kB"
}

if nx_path_search eix &>/dev/null; then
	# Gentoo eix portage tool; default command auto colors
	alias eixc='eix --force-color'
fi

# Set the number of cores to use in make and scons
alias make="make -j $NX_BUILD_CORES"

# Load local scripts
for NX_TEMPVAR in "$NX_LIBRARY_PATH/local/bashrc.d"/*
do
	if [ -r "$NX_TEMPVAR" ]; then
        source "$NX_TEMPVAR"
    fi
done

# less variable pollution
unset NX_TEMPVAR
