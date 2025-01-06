#!/usr/bin/env bash


rm -rf $HOME/.config/workstation

unset WS_DIR
export WS_NAME=angrist
export WS_VERSION
DOTFILES_VERSION="$(git log -n 1 --format="%H")"
#DOTFILES_VERSION="refs/heads/$(git branch --show-current)"
WS_VERSION="$(cd ../ws; git log -n 1 --format="%H")"
#WS_VERSION="refs/heads/$(cd ../ws; git branch --show-current)"

bash <(curl -L "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")

$HOME/.config/workstation/vendor/ws/ws bootstrap -n angrist \
    --initial-config-repo 'https://github.com/joelmccracken/dotfiles.git' \
    --initial-config-repo-ref "$DOTFILES_VERSION"
