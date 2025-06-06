bashrc
======

A simple bashrc, with various features.
- a functional bash prompt.
  - colorized in a manner that indicates the exit status of the last command.
  - intelligent window title setting
    - abbreviates paths in the window title in order to make terminal tabs that
    size to fit the title (e.g. tmux, kitty, ...) to save as much horizontal
    space as possible.  Always keeps the last 2 directory components, but
    abbreviates every other to try to get under 30 characters.
      - can be tweaked by putting your own call to `ns_set_bash_prompt` in your
        `~/.bashrc`; look at the existing call to see the arguments.
    - if connected over ssh, shows `user@host` like usual.
    - if local, doesn't show `user@host` for the user that started X/Wayland,
    as that is sanely the 'default' user.  If any other user, shows `user` but
    removes `@host`.
- automatic starting of an ssh agent (keychain or ssh-agent).
- useful settings and aliases.
- (WIP) two scripts for updating systems.
  - ns\_system\_update: updates the system.
    - prompts for a sudo password.
    - interactively merges updated configuration files at the end (if needed).
  - ns\_archlinux\_update\_with\_plex: updates the system with extra logic to
    restart plex-media-server if it was updated.  ArchLinux only.
- sets +H to disable history expansion, for safety and to avoid unexpected
  behavior.  If you're someone who uses this feature, simply add set -H to
  your `~/.bashrc` after installation to override the setting.


installation
============

Simply run install.sh and it will prepend a line to your `.bashrc` making it
source this bashrc, creating `.bashrc` if it doesn't exist.  This is not
destructive and will preserve your `.bashrc` fully.  This approach allows you
to use this bashrc while also conveniently still having a local configuration.

It recommended by the bash info pages (and generally) to make a `.bash_profile`
that sources `.bashrc` so login shells also get the configuration.  If you desire
this you can pass the argument --replace-bash-profile and it will **REPLACE**
your `.bash_profile` with one that does.  This **IS** destructive as the
argument name implies and is simply a convenience.  Most users will want to
pass this flag, but if you have preferences surrounding this you're clearly
knowledgeable enough to not need my advice.

An example installation into "${HOME}/.bash":

```
git clone https://github.com/nacitar/bashrc.git "${HOME}/.bash"
"${HOME}/.bash/install.sh" --replace-bash-profile
```


ssh agent integration
=====================

The bashrc starts an ssh agent for you.  It will first try to run `keychain`,
and if that doesn't exist it will use `ssh-agent` directly.  With keychain,
this will load any existing agent for the user unlike using ssh-agent directly,
which will create a new instance for each shell.  However, adding
password-protected keys is something you'll have to handle manually via
`ssh-add`.  There is a setting for ssh, though, which will automate the
addition of keys upon use.  I recommend this for simplicitly. Putting this into
your `~/.ssh/config` will enable the feature:
```
# add unlocked keys to ssh agent upon usage
Host *
    AddKeysToAgent yes
```
