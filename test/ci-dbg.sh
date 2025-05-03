#!/usr/bin/env bash


set -x
bash <(curl -L "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")
env


# BEGIN ws_prop_nix_global_config
# configuration from ws property ws_prop_nix_global_config
# AUTOMATICALLY MANAGED: region edits will be overwritten in the future
#
sh <(curl -L https://releases.nixos.org/nix/nix-2.24.14/install) --daemon;
# load the needful after installing
nix_daemon_profile='/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
if [[ ! -e "$nix_daemon_profile" ]]; then
  echo "nix installed, but cannot find profile file to load" 1>&2
  return 8
fi

set +u
. "$nix_daemon_profile";
set -u



sudo mkdir -p /etc/nix

cat > ./nix.conf <<-EOF
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=
substituters = https://cache.nixos.org https://cache.iog.io
experimental-features = nix-command flakes
trusted-users = root runner
build-users-group = nixbld
EOF

sudo mv nix.conf /etc/nix/nix.conf


tree /etc/nix
cat /etc/nix/nix.conf
set +e
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
set -e

cd nix/
flake_out='.#homeConfigurations."runner@ci_macos".activationPackage';
nix --log-format raw --debug -v -L --show-trace build "${flake_out}";
nix --log-format raw --debug -v -L --show-trace run "${flake_out}";
