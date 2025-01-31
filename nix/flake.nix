{
  description = "Joel's workstation, the nix bits n bobs";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      home-config =
        { home, username }:
          { config, pkgs, ... }:
            {
              # Home Manager needs a bit of information about you and the paths it should
              # manage.
              home.username = username;
              home.homeDirectory = home;

              # This value determines the Home Manager release that your configuration is
              # compatible with. This helps avoid breakage when a new Home Manager release
              # introduces backwards incompatible changes.
              #
              # You should not change this value, even if you update Home Manager. If you do
              # want to update the value, then make sure to first check the Home Manager
              # release notes.
              home.stateVersion = "24.11"; # Please read the comment before changing.

              # The home.packages option allows you to install Nix packages into your
              # environment.
              home.packages = [
                pkgs.git
                pkgs.ripgrep
                pkgs.jq
                # it is broken because of course it is
                # everything about nix being stable and repeatable is a lie
                # pkgs.jl
                pkgs.fd
                pkgs.ispell
                # it is broken because of course it is
                # everything about nix is an lie
                # pkgs.bitwarden-cli
                pkgs.direnv
                pkgs.mr  # myrepos https://myrepos.branchable.com/install/
                pkgs.graphviz
                pkgs.cmake
                pkgs.coreutils
                pkgs.wget
                pkgs.racket
              ];

              # Home Manager is pretty good at managing dotfiles. The primary way to manage
              # plain files is through 'home.file'.
              home.file = {
                # # Building this configuration will create a copy of 'dotfiles/screenrc' in
                # # the Nix store. Activating the configuration will then make '~/.screenrc' a
                # # symlink to the Nix store copy.
                # ".screenrc".source = dotfiles/screenrc;

                # # You can also set the file content immediately.
                # ".gradle/gradle.properties".text = ''
                #   org.gradle.console=verbose
                #   org.gradle.daemon.idletimeout=3600000
                # '';
              };

              home.sessionPath = [
                "~/.nix-profile/bin/"
              ];

              programs.emacs = {
                enable = true;
                extraPackages = epkgs: [ epkgs.vterm ];
              };

              # Home Manager can also manage your environment variables through
              # 'home.sessionVariables'. These will be explicitly sourced when using a
              # shell provided by Home Manager. If you don't want to manage your shell
              # through Home Manager then you have to manually source 'hm-session-vars.sh'
              # located at either
              #
              #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
              #
              # or
              #
              #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
              #
              # or
              #
              #  /etc/profiles/per-user/joel.mccracken/etc/profile.d/hm-session-vars.sh
              #
              home.sessionVariables = {
                # EDITOR = "emacs";
              };

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
            };
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."angrist"."joel.mccracken" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          (home-config {
            home="/Users/joel.mccraken";
            username="joel.mccracken";
          })
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}

# nix run -v -L ".#homeConfigurations.\"angrist\".\"joel.mccracken\".activationPackage" --show-trace
# nix build -v -L ".#homeConfigurations.\"angrist\".\"joel.mccracken\".activationPackage" --show-trace --dry-run
