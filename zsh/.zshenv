##############
# PATH MODS ##
##############
### LOCAL ####
export PATH="$HOME/.local/bin:$PATH"
#### RUST ####
. "$HOME/.cargo/env"
## LM Studio ##
export PATH="$PATH:/Users/dave/.lmstudio/bin"

#############
## VIEWERS ##
#############
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="nvim +Man!"

# Stow source of truth. The *config aliases resolve against this, so they edit
# tracked files directly rather than whatever happens to sit in ~/.config.
export DOTFILES="$HOME/.dotfiles"
