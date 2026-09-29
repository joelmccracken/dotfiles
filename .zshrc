# -*- mode: sh; sh-shell: zsh; -*-

. "$HOME/.commonrc"

setopt append_history # append rather then overwrite
setopt extended_history # save timestamp
setopt inc_append_history # add history

# rbenv
command -v rbenv 2>&1 >/dev/null && \
    eval "$(rbenv init - zsh)"

# homebrew
command -v rbenv 2>&1 >/dev/null && \
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
