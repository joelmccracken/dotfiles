#!/usr/bin/env sh


rm -rf $HOME/.config/workstation

unset WORKSTATION_DIR
export WORKSTATION_NAME=angrist
export WORKSTATION_VERSION
DOTFILES_VERSION="$(git log -n 1 --format="%H")"
WORKSTATION_VERSION="$(cd ../ws; git log -n 1 --format="%H")"

bash <(curl "https://raw.githubusercontent.com/joelmccracken/ws/${WORKSTATION_VERSION}/ws_install.sh")

$HOME/.config/workstation/workstation_source/ws bootstrap -n angrist --initial-config-dir .
