test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

VIM="$HOME/.vim"

##############
## HOMEBREW ##
##############
eval "$(/opt/homebrew/bin/brew shellenv)"
ctags=/opt/homebrew/bin/ctags

##############
### GCLOUD ###
##############
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dave/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dave/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/dave/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dave/google-cloud-sdk/completion.zsh.inc'; fi

#############
## COPILOT ##
#############
eval "$(github-copilot-cli alias -- "$0")"

##############
## STARSHIP ##
##############
eval "$(starship init zsh)"

##############
### PYENV ####
##############
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#############
## FINALLY ##
#############
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.config/.aliases
source $HOME/.config/completion.zsh
