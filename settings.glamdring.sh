#!/usr/bin/env sh

export WS_NAME=glamdring

export WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT=".#homeConfigurations.\"joelmccracken@$WS_NAME\".activationPackage";
