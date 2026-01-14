checks() {
    local directory=${PWD}
    while [[ -n ${directory} ]]; do
        local script_path=${directory}/checks
        if [[ -x ${script_path} ]]; then
            "${script_path}" "${@}"
            return
        fi
        directory=${directory%/*}
    done
    >&2 echo "Could not find 'checks' script in CWD or any parent."
    return 1
}
