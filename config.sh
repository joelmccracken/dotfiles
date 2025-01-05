
workstation_props_angrist=()
workstation_props_angrist+=(ws_prop_current_settings_symlink)
workstation_props_angrist+=(ws_prop_dotfiles_git_track)
workstation_props_angrist+=(ws_prop_nix_daemon_installed)
workstation_props_angrist+=(ws_prop_nix_global_config)
workstation_props_angrist+=(ws_prop_df_dotfiles)

workstation_props_dotfiles_angrist() {
  dotfile --ln --dot bashrc
  dotfile --ln --dot ghci
  dotfile --ln --dot gitconfig
  dotfile --ln --dot hammerspoon
  dotfile --ln --dot nix-channels
  dotfile --ln --dot npmrc
  dotfile --ln --dot reddup.yml
  dotfile --ln --dot zshrc

  dotfile --ln Brewfile
  dotfile --ln Brewfile.lock.json
  dotfile --ln bitbar

  dotfile --ln --dot --dir config/git
  dotfile --ln --dot --dir config/doom
}
