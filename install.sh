#!/bin/bash
NS_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

set -e

ln -sf "$NS_LIBRARY_PATH/bashrc" "$HOME/.bashrc"
ln -sf "$NS_LIBRARY_PATH/bash_profile" "$HOME/.bash_profile"
