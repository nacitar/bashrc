#!/bin/bash
NX_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

set -e

cd "$NX_LIBRARY_PATH"
files=('bashrc' 'environment' 'framework' 'bash_logout' 'bash_profile' 'lib'/*)
shellcheck --shell=bash "${files[@]}" --exclude=SC1090,SC1091
