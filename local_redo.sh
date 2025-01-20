#!/usr/bin/env sh

# point of this is to have a sort of local "remove everything, redo everything"
# option. need to manually consider what parts I can even do
# what would removing then reinstalling nix look like as a script?
# not hard to do the
local_ws_redo () {
  local the_dir=
}

date | sed 's/[[:space:]]/-/g'

rm -rf ~/.config/home-manager; nix profile remove home-manager-path; nix-collect-garbage -d

nix build --no-link .#homeConfigurations.angrist."joel.mccracken".activationPackage --show-trace
"$(nix path-info ~/workstation/#homeConfigurations.${WORKSTATION_NAME}.$(whoami).activationPackage)"/activate --show-trace

WORKSTATION_HOME_MANAGER_VERSION=master
nix run "home-manager/$WORKSTATION_HOME_MANAGER_VERSION" -- switch
nix run -L --debug "home-manager/master" -- switch



nix run -v -L .#homeConfigurations."joel.mccracken".activationPackage --show-trace

nix-repl> :p outputs.homeConfigurations."joel.mccracken".activationPackage




nix run -v -L ".#homeConfigurations.\"joel.mccracken\".activationPackage" --show-trace
