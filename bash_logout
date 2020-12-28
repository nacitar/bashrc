#!/bin/bash

# when leaving the console clear the screen to increase privacy
if [[ "${SHLVL}" -eq 1 ]]; then
  if type -p clear_console &>/dev/null; then
    clear_console -q
  else
    if type -p clear &>/dev/null; then
      clear
    fi
  fi
fi
