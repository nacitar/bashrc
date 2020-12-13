#!/bin/env bash

###########################################################
#
# IF YOU SEE THIS, YOU SHOULDN'T BE CHANGING IT!!!!
#
# Put your local configurations within:
#   $NX_LIBRARY_PATH/local/bashrc.d
#   $NX_LIBRARY_PATH/local/environment.d
#
###########################################################

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/environment"

if [[ $- != *i* ]]; then
    return  # shell is non-interactive; bail
fi

source "$NX_LIBRARY_PATH/framework"

############
# LIBARIES #
############
nx_library prompt colordiff dict stringops


###############
# ENVIRONMENT #
###############

# xterm/screen/etc.. get promoted to 256color variants if available
if [[ "$TERM" != *-256color ]] && nx_tput_terminfo_exists "$TERM-256color"; then
    export TERM="$TERM-256color"
    nx_tput_init
fi

HISTCONTROL=ignoreboth  # force ignoredups and ignorespace
shopt -s histappend  # append to the history file, don't overwrite it
shopt -s checkwinsize  # after each command check the window size and keep LINES and COLUMNS up to date
set +H  # disable history expansion so we can use ! in strings and filenames

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

# If color is supported, we want to always use color where this flag is used.
if nx_tput_colors &>/dev/null; then
    NX_COLOR_FLAG='--color=always'
else
    NX_COLOR_FLAG='--color=auto'
fi

NX_CPU_CORES=$(grep "^processor" /proc/cpuinfo --count 2>/dev/null)
NX_BUILD_CORES=$((${NX_CPU_CORES:-2} + 1))  # one extra is usually advised for parallellizing builds

# Disable terminal blanking
setterm -blank 0 &>/dev/null
setterm -powersave off &>/dev/null
setterm -powerdown 0 &>/dev/null

# Set prompt and titles
nx_set_bash_prompt
nx_set_titles_with_prompt
nx_enable_dircolors
nx_enable_bash_completion


###########
# ALIASES #
###########

# Alias to trim whitespace
alias trim='sed -e "s/^[[:space:]]*//;s/[[:space:]]*$//"'

# List files and directories
alias ls='ls --color=auto -X --group-directories-first'  # -X: sort by extension
alias l='ls -F'
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
# Output: kb pid args
alias memtop='ps -e -orss=,pid=,args= | sort -b -k1,1n | pr -TW$COLUMNS'
alias memuse='echo "$(($(ps -e -orss= | paste -sd+)))"'
alias memtotal="cat /proc/meminfo | sed -n 's/^MemTotal:[[:space:]]*\([[:digit:]]*\).*$/\1/p'"
alias memfree='echo "$(($(memtotal)-$(memuse)))"'

# if a system has something like "alias mem='top', making a function like 'mem()' actually
# results in making 'top()' so we fix that by dealiasing before creating functions.
nx_dealias mem
mem() {
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

# Source local scripts
for NX_TEMPVAR in "$NX_LIBRARY_PATH/local/bashrc.d"/*
do
	if [ -r "$NX_TEMPVAR" ]; then
        source "$NX_TEMPVAR"
    fi
done

# Less variable pollution
unset NX_TEMPVAR
