#!/usr/bin/env sh

export WS_NAME=ci_macos
export WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT=".#homeConfigurations.\"ci_macos\".\"runner\".activationPackage";
