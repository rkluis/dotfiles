# SPDX-License-Identifier: GPL-3.0-or-later
# created by Tobias Powalowski <tpowa@archlinux.org>

# Check for Bash shell
[ -n "$BASH_VERSION" ] || return

# Not an interactive shell?
case "$-" in
  *i*) ;;
  *) return ;;
esac

if [ "$UID" = 0 ]; then
    # red for root user, host green, print full working dir
    PS1='[\[\e[1;31m\]\u\[\e[m\]@\[\e[1;32m\]\h\[\e[m\] \[\e[1m\]\w\[\e[m\]]\$ '
else
    # blue for normal user, host green, print full working dir
    PS1='[\[\e[1;34m\]\u\[\e[m\]@\[\e[1;32m\]\h\[\e[m\] \[\e[1m\]\w\[\e[m\]]\$ '
fi

# color man pages
export GROFF_NO_SGR=1

# color eza date to cyan
export EZA_COLORS="da=37"

# keep history clean from dups and spaces
HISTCONTROL="erasedups:ignorespace"

# if installed set neovim as default editor
if command -v nvim >/dev/null 2>&1; then
    alias vi='nvim'
    alias vim='nvim'
    alias edit='nvim'
fi
