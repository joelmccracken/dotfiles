{
  description = "Joel's workstation, the nix bits n bobs";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager-linux = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };
  };

  outputs = { nixpkgs-linux, nixpkgs-darwin, home-manager-linux, home-manager-darwin, ... }:
    let
      home-config = settings@{nixpkgs, system, home, user, home-manager, ...}:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          home-config-mod =
              { config, pkgs, ... }:
                {
                  home.username = user;
                  home.homeDirectory = home;

                  home.stateVersion = "24.11";
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

                  home.file = {};

                  home.sessionPath = [
                    "~/.nix-profile/bin/"
                  ];

                  programs.emacs = {
                    enable = true;
                    extraPackages = epkgs: [ epkgs.vterm ];
                    package = (pkgs.emacs.override {withNativeCompilation = false; });
                  };

                  home.sessionVariables = {};

                  programs.home-manager.enable = true;
                };
        in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [home-config-mod];
          };

      macConfig = settings:
        {
          homeConfigurations."${settings.user}@${settings.ws-name}" = home-config (
            settings // { home-manager = home-manager-darwin; nixpkgs = nixpkgs-darwin; }
          );
        };

      linuxConfig = settings:
        {
          homeConfigurations."${settings.user}@${settings.ws-name}" = home-config (
            settings // { home-manager = home-manager-linux;  nixpkgs = nixpkgs-linux; }
          );
        };

      mergeDefs = m1: m2: {
        # darwinConfigurations = (m1.darwinConfigurations or {}) // (m2.darwinConfigurations or {});
        homeConfigurations = (m1.homeConfigurations or {}) // (m2.homeConfigurations or {});
      };

      machineDefs = machines: builtins.foldl' mergeDefs {} machines;
    in
      machineDefs [
        (macConfig {
          user = "joel.mccracken"; ws-name = "angrist"; system = "aarch64-darwin"; home = "/Users/joel.mccraken";
        })

        (macConfig {
          user = "joel"; ws-name = "aeglos"; system = "x86_64-darwin"; home = "/Users/joel";
        })

        (macConfig {
          user = "joel"; ws-name = "glamdring"; system = "x86_64-darwin"; home = "/Users/joelmccracken";
        })

        (linuxConfig {
          user = "joel"; ws-name = "belthronding"; system = "x86_64-linux"; home = "/home/joel";
        })

        (macConfig {
          user = "runner"; ws-name = "ci_macos"; system = "x86_64-darwin"; home = "/Users/runner";
        })

        (linuxConfig {
          user = "runner"; ws-name = "ci_ubuntu"; system = "x86_64-linux"; home = "/home/runner";
        })
      ];
}
