#!/usr/bin/env sh

set -x
bash <(curl -L "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")

if [ "$RUNNER_OS" == "macOS" ]; then
    CI_WS_NAME=ci-macos
else
    CI_WS_NAME=ci-ubuntu
fi

$HOME/.local/share/ws/ws bootstrap -n "$CI_WS_NAME" \
    --initial-config-repo 'https://github.com/joelmccracken/dotfiles.git' \
    --initial-config-repo-ref "$DOTFILES_SHA"
