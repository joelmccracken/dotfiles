sourceIfExists () {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

sourceIfExists ~/workstation/wssh/settings/paths.sh
sourceIfExists ~/workstation/wssh/settings/build.sh

if [ -e /Users/joel/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/joel/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
