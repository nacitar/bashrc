bashrc
======

My modularized bashrc configuration


installation
============

Simply run install.sh and it will overwrite your .bashrc and related files
with symbolic links to the ones from this package.  An example installation
into "$HOME/.bash":

```
git clone git://github.com/nacitar/bashrc.git "$HOME/.bash"
"$HOME/.bash/install.sh"
```

shell check
===========
```
cd "$HOME/.bash"
shellcheck --shell=bash bashrc environment framework bash_logout bash_profile lib/* --exclude=SC1090,SC1091
```
