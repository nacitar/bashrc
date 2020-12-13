#!/bin/bash
export NX_LIBRARY_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

fullname()
{
	echo "$NX_LIBRARY_PATH/$@"
}

ln -sf "$(fullname bashrc)" "$HOME/.bashrc"
ln -sf "$(fullname bash_profile)" "$HOME/.bash_profile"
ln -sf "$(fullname bash_logout)" "$HOME/.bash_logout"

