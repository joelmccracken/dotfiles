
workstation_props_angrist=()
workstation_props_angrist+=(ws_prop_current_settings_symlink)
workstation_props_angrist+=(ws_prop_dotfiles_git_track)
workstation_props_angrist+=(ws_prop_nix_daemon_installed)
workstation_props_angrist+=(ws_prop_nix_global_config)
workstation_props_angrist+=(ws_prop_df_dotfiles)
workstation_props_angrist+=(ws_prop_nix_home_manager)

workstation_props_dotfiles_angrist() {
  ws_df_dotfile --ln --dot bashrc
  ws_df_dotfile --ln --dot ghci
  ws_df_dotfile --ln --dot gitconfig
  ws_df_dotfile --ln --dot hammerspoon
  ws_df_dotfile --ln --dot nix-channels
  ws_df_dotfile --ln --dot npmrc
  ws_df_dotfile --ln --dot reddup.yml
  ws_df_dotfile --ln --dot zshrc

  ws_df_dotfile --ln Brewfile
  ws_df_dotfile --ln Brewfile.lock.json
  ws_df_dotfile --ln bitbar

  ws_df_dotfile --ln --dot --dir config/git
  ws_df_dotfile --ln --dot --dir config/doom
}
