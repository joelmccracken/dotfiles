
workstation_props_angrist=()
workstation_props_angrist+=(ws_prop_current_settings_symlink)
workstation_props_angrist+=(ws_prop_dotfiles_git_track)
workstation_props_angrist+=(ws_prop_nix_daemon_installed)
workstation_props_angrist+=(ws_prop_nix_global_config)
workstation_props_angrist+=(ws_prop_df_dotfiles)
workstation_props_angrist+=(ws_prop_nix_home_manager)
workstation_props_angrist+=(ws_prop_bitwarden_secrets)
workstation_props_angrist+=(ws_prop_homebrew_bundle)

workstation_props_dotfiles_angrist() {
  ws_df_dotfile --ln --dot bashrc
  ws_df_dotfile --ln --dot ghci
  ws_df_dotfile --ln --dot gitconfig
  ws_df_dotfile --ln --dot hammerspoon
  ws_df_dotfile --ln --dot nix-channels
  ws_df_dotfile --ln --dot npmrc
  ws_df_dotfile --ln --dot reddup.yml
  ws_df_dotfile --ln --dot zshrc

#  ws_df_dotfile --ln Brewfile
#  ws_df_dotfile --ln Brewfile.lock.json
  ws_df_dotfile --ln bitbar

  ws_df_dotfile --ln --dot --dir config/git
  ws_df_dotfile --ln --dot --dir config/doom
}

# since I am working on this frequently, and often just using the currently installed version,
# I want the 'git' origin value (so I can push after testing a fresh setup)
WS_REPO_ORIGIN="git@github.com:joelmccracken/ws.git";


# config just for CI below
workstation_props_ci_macos=("${workstation_props_angrist[@]}")

workstation_props_ci_ubuntu=("${workstation_props_angrist[@]}")

workstation_props_dotfiles_ci_macos() {
  workstation_props_dotfiles_angrist
}

workstation_props_dotfiles_ci_ubuntu() {
  workstation_props_dotfiles_angrist
}
