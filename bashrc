#!/bin/bash

###########################################################
#
# IF YOU SEE THIS, YOU SHOULDN'T BE CHANGING IT!!!!
#
# Put your local configurations within:
#   ${NS_LIBRARY_PATH}/local/bashrc.d
#   ${NS_LIBRARY_PATH}/local/environment.d
#
###########################################################

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/environment"

if [[ $- != *i* ]]; then
  # shell is non-interactive; bail
  return
fi

source "${NS_LIBRARY_PATH}/framework"

############
# LIBARIES #
############
ns_library neovim ssh_key_util prompt colordiff dict stringops developer aws system_update

###############
# ENVIRONMENT #
###############

# xterm/screen/etc.. get promoted to 256color variants if available
if [[ "${TERM}" != *-256color ]] \
    && ns_tput_terminfo_exists "${TERM}-256color"; then
  export TERM="${TERM}-256color"
  ns_tput_init
fi
# force ignoredups and ignorespace
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# after each command check window size and keep LINES and COLUMNS up to date
shopt -s checkwinsize
# disable history expansion so we can use ! in strings and filenames
set +H

# set the editors
if ns_path_search nvim &>/dev/null; then
  export SVN_EDITOR='nvim'
  export EDITOR='nvim'
  export VISUAL='nvim'
  export DIFFPROG='nvim -d'
else
  export SVN_EDITOR='vim'
  export EDITOR='vim'
  export VISUAL='vim'
  export DIFFPROG='vim -d'
fi
export PAGER='less -R'

NS_CPU_CORES=$(grep "^processor" /proc/cpuinfo --count 2>/dev/null)
# one extra is usually advised for parallellizing builds
NS_BUILD_CORES=$((${NS_CPU_CORES:-2} + 1))

# Disable terminal blanking
setterm -blank 0 &>/dev/null
setterm -powersave off &>/dev/null
setterm -powerdown 0 &>/dev/null

# Set prompt and titles
ns_set_bash_prompt
ns_wsl_osc99_prompt_command
ns_set_titles_with_prompt
ns_enable_dircolors
ns_enable_bash_completion

# run the best ssh-agent available
ns_ssh_agent

###########
# ALIASES #
###########
alias sudo='sudo '  # allow alias expansion of command after sudo
alias update='ns_system_update'
alias trim='sed -e "s/^[[:space:]]*//;s/[[:space:]]*$//"'

# -X: sort by extension
alias ls='ls --color=auto -X --group-directories-first'
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

alias diff='ns_diff_wrapper'
alias diffc='CDIFF_FORCE_COLOR=1 ns_diff_wrapper'

# remove any system aliases for grep
ns_dealias grep fgrep egrep
# grep with color forced
alias grepc='grep --color=always'
alias fgrepc='fgrep --color=always'
alias egrepc='egrep --color=always'

# enable colors in less
alias less='less -R'
alias more='less'
alias m='less'

# Directory traversal
alias s='cd ..'
alias p='cd -'

# Convenience
alias md='mkdir'
alias rd='rmdir'
alias c='clear'
alias n='yes "" 2>/dev/null | head -n"${LINES:=100}"'

# Editors
if ns_path_search nvim &>/dev/null; then
  alias view='nvim -R'
  alias nvimdiff='nvim -d'
else
  alias vi='vim'
  alias view='vim -R'
fi
alias emacs='emacs -nw'
alias dict='ns_dict'

# Memory
# Output: kb pid args
alias memtop='ps -e -orss=,pid=,args= | sort -b -k1,1n | pr -TW${COLUMNS}'
alias memuse='echo "$(($(ps -e -orss= | paste -sd+)))"'
alias memtotal="cat /proc/meminfo | sed -n 's/^MemTotal:[[:space:]]*\([[:digit:]]*\).*$/\1/p'"
alias memfree='echo "$(($(memtotal)-$(memuse)))"'

# if a system has something like "alias mem='top', making a function like 'mem()' actually
# results in making 'top()' so we fix that by dealiasing before creating functions.
ns_dealias mem
mem() {
  local used total free
  used="$(memuse)"
  total="$(memtotal)"
  free="$((total - used))"
  echo -e "Total:\t${total} kB\nUsed:\t${used} kB\nFree:\t${free} kB"
}

if ns_path_search eix &>/dev/null; then
  # Gentoo eix portage tool; default command auto colors
  alias eixc='eix --force-color'
fi

# Set the number of cores to use in make and scons
alias make="make -j \"\${NS_BUILD_CORES}\""

# Source local scripts
for ns_tempvar in "${NS_LIBRARY_PATH}/local/bashrc.d"/*; do
  if [ -r "${ns_tempvar}" ]; then
    source "${ns_tempvar}"
  fi
done

# Less variable pollution
unset ns_tempvar
