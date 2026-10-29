# Run a tool's shell-init command once and source the saved output after that,
# instead of spawning the tool on every shell start. Regenerates when the
# command line or the binary's resolved path changes (a brew upgrade moves it
# to a new Cellar dir). Sets REPLY to the cache file.
_init_cache() {
  REPLY=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init/${1:t}.zsh
  local key="# ${${1:c}:A} ${@[2,-1]}" first
  [[ -r $REPLY ]] && read -r first < $REPLY
  [[ $first == "$key" ]] && return
  mkdir -p ${REPLY:h}
  { print -r -- $key && "$@"; } >| $REPLY || { rm -f $REPLY; return 1; }
}

##############
## HOMEBREW ##
##############
_init_cache /opt/homebrew/bin/brew shellenv && source $REPLY
ctags=/opt/homebrew/bin/ctags

##############
### GCLOUD ###
############### The next line enables shell command completion for gcloud.
if [ -f '/Users/dave/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dave/google-cloud-sdk/completion.zsh.inc'; fi

##############
## STARSHIP ##
##############
_init_cache starship init zsh && source $REPLY

##############
### PYENV ####
##############
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# Shims first, as `pyenv init` would do, minus the bash subprocess it spawns
# to do it. --no-rehash: regenerating every shim on each shell start isn't
# needed; pyenv already rehashes after installs and pip installs.
path=($PYENV_ROOT/shims ${path:#$PYENV_ROOT/shims})
_init_cache pyenv init - --no-rehash --no-push-path zsh && source $REPLY

#############
#### NVM ####
#############
export NVM_DIR="$HOME/.nvm"
# Sourcing nvm.sh costs ~280ms per shell, mostly resolving the default alias
# (lts/* -> lts/krypton -> v24...). Follow the alias files to the version
# directly, put it on PATH, and load nvm itself the first time `nvm` runs.
# Nested shells (zellij, nvim :terminal) keep whatever node they inherited,
# as nvm.sh would.
if (( ! ${path[(I)$NVM_DIR/versions/node/*/bin]} )); then
  () {
    local v=default n
    for n in 1 2 3 4 5; do
      [[ -f $NVM_DIR/alias/$v ]] || break
      v=$(<$NVM_DIR/alias/$v)
    done
    local dir=$NVM_DIR/versions/node/$v
    if [[ -d $dir/bin ]]; then
      path=($dir/bin $path)
      export NVM_BIN=$dir/bin NVM_INC=$dir/include/node
      [[ -n $MANPATH ]] && export MANPATH=$dir/share/man:$MANPATH
    else
      # Not an installed exact version (e.g. "22" or "node"): let nvm resolve it.
      source $NVM_DIR/nvm.sh
    fi
  }
fi
if (( ! $+functions[nvm] )); then
  nvm() {
    unfunction nvm
    source $NVM_DIR/nvm.sh --no-use
    nvm "$@"
  }
fi


#############
#### GO #####
#############
# go's default GOPATH; no need to spawn `go env` for it. Update this if
# GOPATH is ever set with `go env -w`.
export PATH=$PATH:${GOPATH:-$HOME/go}/bin

#############
## FINALLY ##
#############
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.config/.functions
source $HOME/.config/.aliases
source $HOME/.config/completion.zsh
export GOOGLE_CLOUD_PROJECT_ID="divesites-205820"

[ -f ~/.inshellisense/key-bindings.zsh ] && source ~/.inshellisense/key-bindings.zsh



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dave.frame/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dave.frame/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dave.frame/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dave.frame/google-cloud-sdk/completion.zsh.inc'; fi
