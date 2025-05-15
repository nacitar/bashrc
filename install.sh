#!/bin/bash
set -eu
bashrc_file="${HOME}/.bashrc"

show_usage() {
    >&2 cat << EOF
Usage: ${0##*/} OPTIONS

Creates or updates ~/.bashrc making it source ours at the start.

OPTIONS:
  -h, --help
      Display this help text and exit.

  --replace-bash-profile
      Replace .bash_profile with one that sources ~/.bashrc
EOF
}
error() {
    [ "${1}" = "-u" ] && shift && show_usage
    >&2 printf "\nERROR: %s: %s\n" "${0##*/}" "${*}"
    exit 1
}
replace_bash_profile=''
while [ ${#} -gt 0 ]; do
    case "${1}" in
        -h|--help) show_usage; exit 0 ;;
        --replace-bash-profile) replace_bash_profile=1 ;;
        --?*) error -u "unsupported long option: ${1}" ;;
        -??*) set -- "-${1:1:1}" "-${1:2}" "${@:2}"; continue ;;
        -?) error -u "unsupported short option: ${1}" ;;
        *) error -u "unsupported argument: ${1}" ;;
    esac
    shift
done

script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source_path="${script_dir}/bashrc"
if [[ ${source_path} == "${HOME}"* ]]; then
    source_path="\${HOME}${source_path:${#HOME}}"
fi
source_command="source \"${source_path}\""
source_comment='# ns bashrc (comment used by install script)'
source_line="${source_command}  ${source_comment}"

touch "${bashrc_file}"
got_first_line='' shebang='' old_source_line='' lines=()
while read -r line; do
    if [[ -z ${got_first_line} ]]; then
        if [[ -z ${shebang} && ${line} == '#!'* ]]; then
            shebang=${line}
            continue
        else
            got_first_line=1
            if [[ ${line} == *" ${source_comment}" \
                    || ${line} == "${source_command}" ]]; then
                old_source_line="${line}"
                continue
            fi
        fi
    fi
    lines+=("${line}")
done < "${bashrc_file}"


if [[ ${old_source_line} != "${source_line}" ]]; then
    echo "Updating source line in: ${bashrc_file}"
    # trim trailing empty lines
    i=${#lines[@]}  # Start from the last index
    while (( --i >= 0 )) && [[ -z "${lines[i]}" ]]; do
        echo "unsetting ${i}"
        unset 'lines[i]'
    done
    # prepend our lines
    if [[ -n "${lines[0]:-}" ]]; then
        lines=("" "${lines[@]}")
    fi
    lines=("${source_line}" "${lines[@]}")
    if [[ -n ${shebang} ]]; then
        lines=("${shebang}" "${lines[@]}")
    fi
    # write the bashrc
    printf "%s\n" "${lines[@]}" > "${bashrc_file}"
fi

# create a directory for other scripts to drop in bashrc supplements
mkdir -p "${HOME}/.bashrc.d"

if [[ -n ${replace_bash_profile} ]]; then
    cp -f "${script_dir}/bash_profile" "${HOME}/.bash_profile"
fi
