# Install steps for a new system

## Clone main repository
    git clone --bare git@github.com:olaf-rogalsky/dotfiles.git "$HOME/.dotfiles"

## alias
    alias dotcfg="git --git-dir='$HOME/.dotfiles' --work-tree='$HOME'"

## checkout (this might fail due to existing files: delete or backup those)
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout

## don't show untracked files
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" --local status.showUntrackedFiles no
