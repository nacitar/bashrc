#!/bin/bash
NX_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

set -e

ln -sf "$NX_LIBRARY_PATH/bashrc" "$HOME/.bashrc"
ln -sf "$NX_LIBRARY_PATH/bash_profile" "$HOME/.bash_profile"
ln -sf "$NX_LIBRARY_PATH/bash_logout" "$HOME/.bash_logout"
