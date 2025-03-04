#!/bin/bash

###############
# ENVIRONMENT #
###############
NS_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
while read -r ns_tempvar; do
    # if it exists and isn't already in PATH
    if [[ -d ${ns_tempvar} && ! ${PATH} =~ (^|:)${ns_tempvar}/?(:|$) ]]; then
        export PATH="${ns_tempvar}:${PATH}"
    fi
    # in reverse order of priority; the last entry will come first
done <<EOF
/opt/bin
/opt/sbin
/bin
/sbin
/usr/bin
/usr/sbin
/opt/local/bin
/opt/local/sbin
/usr/local/bin
/usr/local/sbin
${NS_LIBRARY_PATH}/bin
${HOME}/.local/bin
${HOME}/bin
EOF
unset ns_tempvar NS_LIBRARY_PATH

export LD_LIBRARY_PATH="${HOME}/lib:${LD_LIBRARY_PATH}"

if [[ $- != *i* ]]; then
    # shell is non-interactive; bail
    return
fi

#############
# FUNCTIONS #
#############
ns_ssh_agent() {
    if [[ -z ${SSH_AUTH_SOCK} || -z ${SSH_AGENT_PID} ]]; then
        if command -v keychain &>/dev/null; then
            eval "$(keychain -q --nogui --noask --eval --agents ssh)"
        elif command -v ssh-agent &>/dev/null; then
            eval "$(ssh-agent -s)"
        fi
    fi
}
ns_select_ssh_id() {
    if [[ $# -ne 1 ]]; then
        >&2 echo "ERROR: must specify exactly one ssh id."
        return 1
    fi
    local key_path=${HOME}/.ssh/id_${1}
    local selected_key_path=${HOME}/.ssh/id_default
    if [[ ! -e ${key_path} ]]; then
        >&2 echo "ERROR: no such ssh key: ${key_path}"
        return 1
    fi
    local default_key_path
    for default_key_path in "${selected_key_path}"{,.pub}; do
        if [[ -L ${default_key_path} ]]; then
            unlink "${default_key_path}"
        elif [[ -e ${default_key_path} ]]; then
            >&2 echo "ERROR: ssh key is not a symlink: ${default_key_path}"
            return 1
        fi
    done
    ln -s "${key_path##*/}" "${selected_key_path}"
    if [[ -e ${key_path}.pub ]]; then
      ln -s "${key_path##*/}.pub" "${selected_key_path}.pub"
    fi
}
ns_is_integral() {
    while ((${#})); do
        # NOTE: must use [ ] instead of [[ ]] for this check to work
        [ "${1}" -eq "${1}" ] 2>/dev/null || return 1
        shift
    done
    return 0
}
ns_is_local_machine() {
    [[ -z ${SSH_CLIENT} && -z ${SSH_TTY} ]]
}
ns_is_gui_session_owner() {
    if [[ -n ${WAYLAND_DISPLAY} ]]; then
        if [[ -O /run/user/${UID}/${WAYLAND_DISPLAY} ]]; then
            return 0
        fi
    fi
    if [[ -n ${DISPLAY} ]]; then
        local display_number=${DISPLAY%.*}
        display_number=${display_number#:}
        if [[ -O /tmp/.X11-unix/X${display_number} ]]; then
            return 0
        fi
    fi
    return 1
}
ns_abbreviate_dir() {  # NOTE: simple argument handling for speed in prompt
    local IFS=/ dir="${1:-$PWD}" max="${2:-0}" keep="${3:-1}"
    if [[ ${dir} == "${HOME}"* ]]; then
        dir="~${dir:${#HOME}}"
    fi
    # shellcheck disable=2206
    local parts=(${dir}) length=${#dir}
    local i=-1 end=$((${#parts[@]}-keep))
    while ((++i < end && length > max)); do
        if [[ "${parts[i]:0:1}" = '.' ]]; then
            ((length-=${#parts[i]}-2))
            parts[i]=${parts[i]:0:2}
        else
            ((length-=${#parts[i]}-1))
            parts[i]=${parts[i]:0:1}
        fi
    done
    echo "${parts[*]}"
}
ns_set_bash_prompt() {
    local target_title_path_length="" keep_path_levels=1 cwd_definition
    while (($#)); do
        case "${1}" in
            --target-title-path-length=*) target_title_path_length="${1#*=}" ;;
            --keep-path-levels=*) keep_path_levels="${1#*=}" ;;
            *) >&2 echo "ERROR: unsupported argument: ${1}"; return 1 ;;
        esac
        shift
    done
    if [[ -n "${target_title_path_length}" ]]; then
        if ! ns_is_integral "${target_title_path_length}"; then
            >&2 echo "ERROR: target_title_path_length must be an integer."
            return 1
        fi
        if ! ns_is_integral "${keep_path_levels}"; then
            >&2 echo "ERROR: keep_path_levels must be an integer."
            return 1
        fi
        # shellcheck disable=2016
        cwd_definition="$(printf %s \
            'cwd="\w";' \
            'cwd="$(ns_abbreviate_dir "${cwd@P}"' \
                " \"${target_title_path_length}\"" \
                " \"${keep_path_levels}\"" \
            ')"' \
        )"
    else
        # shellcheck disable=2016
        cwd_definition='cwd="\w"; cwd="${cwd@P}"'
    fi
    if command -v tput &>/dev/null; then
        # hash everything used by the prompt
        hash tput wslpath git &>/dev/null
        local reset
        reset="$(tput sgr0 2>/dev/null)"
        # NOTE: intentionally disabling git status check on WSL paths (slow)
        # shellcheck disable=2016
        PS1="$(printf %s \
            '$(E=$?;((E))' \
            "&&ESTYLE='$(tput setaf 1 bold 2>/dev/null)'" \
            "||ESTYLE='$(tput setaf 4 bold 2>/dev/null)'" \
            ";echo -n \"\[${reset}\$ESTYLE\][" \
            "\[${reset}$(tput setaf 2 2>/dev/null)\]\\u@\\h \[\"" \
            ';[[ ! $(wslpath -ma "$PWD" 2>/dev/null) =~ ^(/.*)?$' \
            ' || -z $(git status --porcelain 2>/dev/null) ]]' \
            "&&echo -n '$(tput setaf 6 bold 2>/dev/null)'" \
            "||echo -n '$(tput setaf 3 bold 2>/dev/null)'" \
            ';echo -n "\]\w\[$ESTYLE\]]"' \
            ';exit $E)' \
        )\\\$\[${reset}\] "
    else
        >&2 echo "WARNING: tput is not in PATH, cannot colorize bash prompt!"
        PS1='[\u@\h \w]\$ '
    fi
    # PROMPT_COMMAND is an array; simply assigning a string only sets [0]
    # shellcheck disable=2016
    PROMPT_COMMAND=("printf '\e]0;%s\a' \"\$($(printf %s \
        'if ns_is_local_machine;then' \
        ' if ns_is_gui_session_owner;then header="";else header="\u";fi;' \
        'else header="\u@\h";fi;' \
        'header="${header:+${header@P}: }";' \
        "${cwd_definition};" \
        'echo -n "${header}${cwd}"' \
    ))\"")
    # osc99 for wsl + windows terminal so new tabs open in same directory
    if command -v wslpath &>/dev/null; then
        # shellcheck disable=2016
        PROMPT_COMMAND+=('printf "\e]9;9;%s\e\\" "${PWD}"')
    fi
}

#################
# CONFIGURATION #
#################
if command -v tput &>/dev/null; then
    if tput -T "${TERM}-256color" -S < /dev/null &>/dev/null ; then
        export TERM="${TERM}-256color"
    fi
fi
ns_set_bash_prompt --target-title-path-length=30 --keep-path-levels=2
ns_ssh_agent

# force ignoredups and ignorespace
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# after each command check window size and keep LINES and COLUMNS up to date
shopt -s checkwinsize
# disable history expansion so we can use ! in strings and filenames
set +H

# Disable terminal blanking
setterm -blank 0 &>/dev/null
setterm -powersave off &>/dev/null
setterm -powerdown 0 &>/dev/null

# enable tab completion after sudo
complete -cf sudo
# allow alias expansion of command after sudo
alias sudo='sudo '

alias diff='diff --color'
alias diffc='diff --color=always'

if command -v nvim &>/dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
    export DIFFPROG='nvim -d'
    alias vi='nvim'
    alias vim='nvim'
    alias vimdiff='nvim -d'
    alias view='nvim -R'
elif command -v vim &>/dev/null; then
    export EDITOR='vim'
    export VISUAL='vim'
    export DIFFPROG='vim -d'
    alias vi='vim'
    alias view='vim -R'
fi
if command -v less &>/dev/null; then
    export PAGER='less -R'
    alias less='less -R'
    alias more='less'
    alias m='less'
fi
if command -v eix &>/dev/null; then
    alias eixc='eix --force-color'
fi

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
alias grepc='grep --color=always'

# Directory traversal
alias s='cd ..'
alias p='cd -'

# Convenience
alias md='mkdir'
alias rd='rmdir'
alias c='clear'
alias n='yes "" 2>/dev/null | head -n"${LINES:=100}"'

# Efficiency
# shellcheck disable=2139
alias make="make -j$(($(nproc)+1))"
