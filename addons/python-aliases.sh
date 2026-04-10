if [[ $- != *i* ]]; then
    # shell is non-interactive; bail
    return
fi

# python development
alias checks="ns_run_ancestor checks"
