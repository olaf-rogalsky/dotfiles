# Install steps for a new system

## clone main repository
    git clone --bare git@github.com:olaf-rogalsky/dotfiles.git "$HOME/.dotfiles"

## checkout
If the checkout fails due to existing files either delete or backup those, first.

    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout


## don't show untracked files
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" --local status.showUntrackedFiles no

## alias
The following alias is defined in .bashrc as shorthand for woring with the bare repository

    alias dotcfg="git --git-dir='$HOME/.dotfiles' --work-tree='$HOME'"
    
## all installation commands combined (cut & paste)
    git clone --bare git@github.com:olaf-rogalsky/dotfiles.git "$HOME/.dotfiles"
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" --local status.showUntrackedFiles no

# Update the current system from the remote github repository

# fetch & merge
    dotcfg fetsh  # optionally: dotcfg diff
    dotcfg merge

# pull
Or do it in one ste w/o chance to check differences before merging

    dotcfg pull
