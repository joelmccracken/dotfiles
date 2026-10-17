#!/bin/bash
# Enable Remote Login (SSH) and Screen Sharing on macOS, restricted to the current user.
# Run as your normal user (not with sudo); it will prompt for your password if sudo needs it.
#
# Usage:
#   enable-remote-access.sh          enable SSH and Screen Sharing
#   enable-remote-access.sh --check  report whether both are enabled; exit 0 if so,
#                                    1 if not. Changes nothing and needs no sudo.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [--check]" >&2
}

CHECK=false
case "${1:-}" in
  "") ;;
  --check) CHECK=true ;;
  -h|--help) usage; exit 0 ;;
  *) usage; exit 2 ;;
esac

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-$(id -un)}"
if [[ "$TARGET_USER" == "root" ]]; then
  echo "Run this as your normal user, not as root." >&2
  exit 1
fi

# Screen Sharing and Remote Management share the same service; refuse to fight it.
# (Output is captured before grepping: with pipefail, `grep -q` exiting early can
# SIGPIPE launchctl and make the pipeline fail even on a match.)
remote_management_on() {
  pgrep -xq ARDAgent || return 1
  local out
  out=$(launchctl print system/com.apple.RemoteDesktop.agent 2>/dev/null) || return 1
  grep -q 'state = running' <<<"$out"
}

remote_management_off() {
  ! remote_management_on
}

# Is the user in the service access group? (The group only exists once access is restricted.)
in_access_group() {
  dseditgroup -o checkmember -m "$TARGET_USER" "$1" >/dev/null 2>&1
}

# Is the system launch daemon explicitly enabled and loaded?
daemon_enabled() {
  local label=$1
  # Newer macOS prints "=> enabled", older prints "=> false" (i.e. not disabled).
  local disabled
  disabled=$(launchctl print-disabled system 2>/dev/null) || return 1
  grep -Eq "\"$label\" => (enabled|false)" <<<"$disabled" &&
    launchctl print "system/$label" >/dev/null 2>&1
}

port_listening() {
  nc -z localhost "$1" >/dev/null 2>&1
}

if $CHECK; then
  failed=0
  check() {
    local what=$1; shift
    if "$@"; then
      echo "ok:   $what"
    else
      echo "FAIL: $what"
      failed=1
    fi
  }
  check "Remote Management is off"                        remote_management_off
  check "$TARGET_USER is in com.apple.access_ssh"          in_access_group com.apple.access_ssh
  check "Remote Login (sshd) is enabled and loaded"        daemon_enabled com.openssh.sshd
  check "SSH listening on port 22"                         port_listening 22
  check "$TARGET_USER is in com.apple.access_screensharing" in_access_group com.apple.access_screensharing
  check "Screen Sharing is enabled and loaded"             daemon_enabled com.apple.screensharing
  check "Screen Sharing listening on port 5900"            port_listening 5900
  exit "$failed"
fi

if remote_management_on; then
  echo "Remote Management appears to be on. Turn it off in System Settings > General > Sharing first." >&2
  exit 1
fi

echo "Enabling SSH and Screen Sharing for user: $TARGET_USER"
# Get sudo credentials up front. Not `sudo -v`, which would ask for password, even
# with my NOPASSWD entry 
sudo true

# Create a service access group (if needed) and add the user to it.
# When the group exists, macOS only allows its members to use that service.
add_to_access_group() {
  local group=$1
  if ! dscl . -read "/Groups/$group" >/dev/null 2>&1; then
    sudo dseditgroup -o create -q "$group"
  fi
  sudo dseditgroup -o edit -a "$TARGET_USER" -t user "$group"
}

# Enable a system launch daemon and load it if it isn't already loaded.
enable_daemon() {
  local label=$1 plist=$2
  sudo launchctl enable "system/$label"
  if ! sudo launchctl print "system/$label" >/dev/null 2>&1; then
    sudo launchctl bootstrap system "$plist"
  fi
}

echo "==> Remote Login (SSH)"
add_to_access_group com.apple.access_ssh
enable_daemon com.openssh.sshd /System/Library/LaunchDaemons/ssh.plist

echo "==> Screen Sharing"
add_to_access_group com.apple.access_screensharing
enable_daemon com.apple.screensharing /System/Library/LaunchDaemons/com.apple.screensharing.plist

sleep 1
echo "==> Checking ports"
port_listening 22 && echo "SSH listening on port 22" || echo "WARNING: nothing on port 22"
port_listening 5900 && echo "Screen Sharing listening on port 5900" || echo "WARNING: nothing on port 5900"

HOST="$(scutil --get LocalHostName 2>/dev/null || hostname -s).local"
echo
echo "Done. Connect with:"
echo "  ssh $TARGET_USER@$HOST"
echo "  open vnc://$HOST"
