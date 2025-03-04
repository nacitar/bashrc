#!/bin/bash
set -eu
NS_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

ln -sf "$NS_LIBRARY_PATH/bashrc" "$HOME/.bashrc"
ln -sf "$NS_LIBRARY_PATH/bash_profile" "$HOME/.bash_profile"
