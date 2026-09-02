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
eval "$(pyenv init --path)"

#############
#### NVM ####
#############
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion


#############
#### GO #####
#############
export PATH=$PATH:$(go env GOPATH)/bin

#############
## FINALLY ##
#############
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.config/.functions
source $HOME/.config/.aliases
source $HOME/.config/completion.zsh
export GOOGLE_CLOUD_PROJECT_ID="divesites-205820"

[ -f ~/.inshellisense/key-bindings.zsh ] && source ~/.inshellisense/key-bindings.zsh


