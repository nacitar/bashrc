bashrc
======

My modularized bashrc configuration


installation
============

Simply run install.sh and it will overwrite your .bashrc and related files
with symbolic links to the ones from this package.  An example installation
into "$HOME/.bash":

```
git clone https://github.com/nacitar/bashrc.git "$HOME/.bash"
"$HOME/.bash/install.sh"
```
If you are running archlinux, and you intend on using 'yay' to install
plex-media-server, you may want the 'update' command to restart that service
whenever it is updated.  You can install a sample script for that:
```
ns_install_sample archlinux_update_restarts_new_plex
```
