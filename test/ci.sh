#!/usr/bin/env bash

set -x
bash <(curl -L "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")
env

if [ "$RUNNER_OS" == "macOS" ]; then
    CI_WS_NAME=ci_macos
else
    CI_WS_NAME=ci_ubuntu
fi


$HOME/.local/share/ws/ws -v bootstrap -n "$CI_WS_NAME" \
    --initial-config-repo 'https://github.com/joelmccracken/dotfiles.git' \
    --initial-config-repo-ref "$DOTFILES_SHA" || {

  nix_daemon_profile='/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  set +u
  . "$nix_daemon_profile";
  set -u


    cd ~/.config/workstation/nix;
    nix build  --show-trace -v -L '.#homeConfigurations.ci_ubuntu.runner'
    nix run  --show-trace -v -L '.#homeConfigurations.ci_ubuntu.runner'
}
