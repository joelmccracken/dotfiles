# -*- mode: sh; sh-shell: zsh; -*-

export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.commonrc"

setopt append_history # append rather then overwrite
setopt extended_history # save timestamp
setopt inc_append_history # add history

# rbenv
eval "$(rbenv init - zsh)"

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
