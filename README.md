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
    - also runs `ns-uv-tool-update` and `ns-npm-tool-update`, which upgrade
      per-user tools installed via `uv tool` and `npm install -g`
      respectively.  Both are no-ops if their tool isn't installed.
      `ns-npm-tool-update` has no separate list of its own to maintain: it
      lists whatever is currently installed under `${HOME}/.local` (the
      bashrc-exported `NPM_CONFIG_PREFIX`, which also makes plain
      `npm install -g` per-user with no extra setup) and reinstalls each at
      `@latest`, the same way `ns-uv-tool-update` works off uv's own tool
      directory.  Add a new tool
      once with `npm install -g <package>` and it's kept current from then
      on.  To keep a package at a specific version instead, list it (e.g.
      `is-odd@2.0.0`) in `${XDG_CONFIG_HOME:-~/.config}/npm-tool-pins`, one
      per line, `#` comments and blank lines ignored -- npm records no
      version intent of its own for global installs, so this is the only
      way a pin survives the next upgrade.  It only overrides packages
      already installed; it isn't itself an install list.
  - ns\_archlinux\_update\_with\_plex: updates the system with extra logic to
    restart plex-media-server if it was updated.  ArchLinux only.
- sets +H to disable history expansion, for safety and to avoid unexpected
  behavior.  If you're someone who uses this feature, simply add set -H to
  your `~/.bashrc` after installation to override the setting.

Optional addons are also provided.
- Passing '--python-aliases' adds a script with my personal python development
  aliases into the `~/.integration/bashrc.d` directory.

The bashrc itself exports `NPM_CONFIG_PREFIX=${HOME}/.local` (see
ENVIRONMENT), so `npm install -g` is per-user by default with no extra setup
-- global npm installs are otherwise scoped by wherever node itself is
installed, which usually means root.  `~/.local/bin` and `~/.local/lib` are
the per-user equivalents of `/usr/bin` and `/usr/lib` per the
[Linux File System Hierarchy spec](https://uapi-group.org/specifications/specs/linux_file_system_hierarchy/),
same as where uv already puts its own tool shims.


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
"${HOME}/.bash/install.sh" --replace-bash-profile --python-aliases
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
