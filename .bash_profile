sourceIfExists () {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

sourceIfExists ~/workstation/wssh/settings/paths.sh
sourceIfExists ~/workstation/wssh/settings/build.sh
sourceIfExists /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
sourceIfExists ~/.nix-profile/etc/profile.d/hm-session-vars.sh
