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

ssh agent integration
=====================

The library `lib/ssh_key_util` provides logic to start an ssh agent.  It will
first try to run `keychain`, and if that doesn't exist it will use `ssh-agent`
directly.  With keychain, this will load any existing agent for the user
unlike using ssh-agent directly, which will create a new instance for each
shell.  However, adding password-protected keys is something you'll have to
handle manually via `ssh-add`.  There is a setting for ssh, though, which will
automate the addition of keys upon use.  I recommend this for simplicitly.
Putting this into your `~/.ssh/config` will enable the feature:
```
# add unlocked keys to ssh agent upon usage
Host *
    AddKeysToAgent yes
```
