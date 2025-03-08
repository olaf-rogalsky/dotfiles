# Install steps for a new system

## clone main repository
    git clone --bare git@github.com:olaf-rogalsky/dotfiles.git "$HOME/.dotfiles"

## alias
The following alias is later also defined in .bashrc

    alias dotcfg="git --git-dir='$HOME/.dotfiles' --work-tree='$HOME'"
    
## checkout
If the checkout fails due to existing files either delete or backup those, first.

    dotcfg checkout

## don't show untracked files
    dotcfg config --local status.showUntrackedFiles no

  
## all installation commands combined (cut & paste)
    git clone --bare git@github.com:olaf-rogalsky/dotfiles.git "$HOME/.dotfiles"
    alias dotcfg="git --git-dir='$HOME/.dotfiles' --work-tree='$HOME'"
    dotcfg checkout
    dotcfg config --local status.showUntrackedFiles no

# Update the current system from the remote github repository

# fetch & merge
    dotcfg fetsh  # optionally: dotcfg diff
    dotcfg merge

# pull
Or do it in one step w/o chance to check differences before merging

    dotcfg pull


# initial setup of the dotfiles repository
   mkdir .dotfiles
   alias dotcfg='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
   dotcfg init
   dotcfg config --local status.showUntrackedFiles no
   dotcfg branch -M main # optional: main is the default nowadays
   dotcfg remote add origin git@github.com:olaf-rogalsky/dotfiles.git
   dotcfg push --set-upstream origin main
   mkdir $HOME/.github
   echo "description ..." >"$HOME/.github/README.md"
   dotcfg add "$HOME/.github/README.md"
   dotcfg commit -m "added .github/README.md"
   
