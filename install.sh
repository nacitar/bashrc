#!/bin/bash

pushd "$(dirname "$0")" &>/dev/null

fullname()
{
	readlink -f "$@"
}

ln -sf "$(fullname bashrc)" "$HOME/.bashrc"
ln -sf "$(fullname bash_profile)" "$HOME/.bash_profile"
ln -sf "$(fullname bash_logout)" "$HOME/.bash_logout"

popd &>/dev/null
