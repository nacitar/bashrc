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

# Load the nx bash framework, or bail
[ -r "$HOME/.bash/framework" ] && source "$HOME/.bash/framework" &>/dev/null || return

############
# LIBARIES #
############
nx_library "termops" "tmux" "platform" "cdiff"

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

###############
# INTERACTIVE #
###############

# force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Disable terminal blanking
setterm -blank 0 &>/dev/null
setterm -powersave off &>/dev/null
setterm -powerdown 0 &>/dev/null

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

# We don't want to force color if the output isn't to a terminal however we also
# don't want to have to do something special to force it when we want it.  If we
# 'source' a script, it could be problematic.  However, any sane script would use
# 'ls' rather than any of the ll/etc.. derivatives, thus it should be safe to
# force color for the other aliases.


# If color is supported, we want to always use color where this flag is used.
if nx_tput_terminfo_colors &>/dev/null; then
	color_flag="--color=always"
else
	color_flag="--color=auto"
fi

# Alias to trim whitespace
alias trim='sed -e "s/^[[:space:]]*//;s/[[:space:]]*$//"'

# Make aliases for directory listing
# Check for directory grouping support
LS_DEF_FLAGS='-X'
if ls --group-directories-first /dev/null &>/dev/null; then
	LS_DEF_FLAGS="$LS_DEF_FLAGS --group-directories-first"
fi
# List files and directories
alias ls='ls --color=auto $LS_DEF_FLAGS'
alias l="ls -bF $color_flag"
alias la="l -A"
alias ll="l -l"
alias lal="l -Al"
# List only directories
alias lsd='ls -bd */'
alias lld='ls -bld */'
alias lald='ls -bAld */ .*/'

# This command strips color codes out of text, giving you "(b)are" text.
# Useful if trying to do ll > bla.txt, given my forced-color output.
# You can strip colors from a file via "bare -i filename", too :)
alias bare='sed -r "s/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g"'
alias b='bare'

# wrap diff to use colordiff if it's available or normal diff otherwise
alias diff="nx_diff_wrapper"
alias diffc="CDIFF_FORCE_COLOR=1 nx_diff_wrapper"

# enable svn wrapper that handles colordiff/cdiff and automatically colorizes diff if outputting to a terminal
alias svn="nx_svn_wrapper"

# grep (force colorizing match string)
alias grepc="grep $color_flag"
alias fgrepc="fgrep $color_flag"
alias egrepc="egrep $color_flag"

# grep (no colorizing match string)
alias grep="grep --color=none"
alias fgrep="fgrep --color=none"
alias egrep="egrep --color=none"

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

# Safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Misc
alias vi='vim'
alias emacs='emacs -nw'
alias df='df -h -x supermount'
alias du='du -h'

# sudo preserves environment, rsudo gives the original sudo if you find this undesirable. 
alias rsudo='nx_nonaliased sudo'
alias sudo='sudo -E'
alias su='su -p'
alias realsu='nx_nonaliased su'

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
	
# Gentoo eix portage tool; default command auto colors
alias eixc='eix --force-color'

# Cleanup
unset color_flag

# Get the number of CPU cores, if possible
CPU_CORES=$(grep "^processor" /proc/cpuinfo 2>/dev/null | wc -l)

# If the number of cores is actually a number
if [ $CPU_CORES = $[CPU_CORES+0] ]; then
	# add one to it
	CPU_CORES=$[CPU_CORES+1];
else
	# Default to 2
	CPU_CORES=2
fi

# Set the number of cores to use in make and scons
alias make="make -j $CPU_CORES"
export SCONSFLAGS="-j $CPU_CORES"
unset CPU_CORES

# Load local scripts
for f in "$NX_LIBRARY_PATH/local/bashrc"
do
	[ -r "$f" ] && source "$f"
done
unset f
