# -*- mode: sh; sh-shell: zsh; -*-

. "$HOME/.config/workstation/dotfiles/commonrc"

setopt append_history # append rather then overwrite
setopt extended_history # save timestamp
setopt inc_append_history # add history

# bun completions
[ -s "/Users/joelmccracken/.bun/_bun" ] && source "/Users/joelmccracken/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
