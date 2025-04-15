#!/usr/bin/env sh

export WS_NAME=ci-ubuntu
export WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT=".#homeConfigurations.\"ci-ubuntu\".\"runner\".activationPackage";
