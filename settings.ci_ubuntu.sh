#!/usr/bin/env sh

export WS_NAME=ci_ubuntu
export WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT='.#homeConfigurations."runner@$WS_NAME".activationPackage';
