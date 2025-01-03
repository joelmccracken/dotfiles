#!/usr/bin/env bash


rm -rf $HOME/.config/workstation

unset WORKSTATION_DIR
export WORKSTATION_NAME=angrist
export WORKSTATION_VERSION
DOTFILES_VERSION="$(git log -n 1 --format="%H")"
#DOTFILES_VERSION="refs/heads/$(git branch --show-current)"
WORKSTATION_VERSION="$(cd ../ws; git log -n 1 --format="%H")"
#WORKSTATION_VERSION="refs/heads/$(cd ../ws; git branch --show-current)"

bash <(curl -L "https://raw.githubusercontent.com/joelmccracken/ws/${WORKSTATION_VERSION}/ws_install.sh")

$HOME/.config/workstation/vendor/ws/ws bootstrap -n angrist \
    --initial-config-repo 'https://github.com/joelmccracken/dotfiles.git' \
    --initial-config-repo-ref "$DOTFILES_VERSION"
