# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ICLOUD=$HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs

ZSH_THEME="agnoster"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

ENABLE_CORRECTION="true"

# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="%F{cyan}hmm...%f"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-interactive-cd)

source $ZSH/oh-my-zsh.sh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
#  export ARCHFLAGS="-arch x86_64"

 
VIM=$HOME/.vim
#Pyenv version manager
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="$HOME/.local/bin:$PATH"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
 alias zshconfig="vim ~/.zshrc"
 alias zsource="source ~/.zshrc"
 alias ohmyzsh="vim ~/.oh-my-zsh"
 alias vimconfig="vim ~/.vimrc"
 alias getsshpub="tr -d '\n' < ~/.ssh/id_ed25519.pub | pbcopy" 
 

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

