#!/bin/bash

# when leaving the console clear the screen to increase privacy
if [ "$SHLVL" -eq 1 ]; then
	type -P clear_console &>/dev/null && clear_console -q || type -P clear &>/dev/null && $(type -P clear) || clear
fi
