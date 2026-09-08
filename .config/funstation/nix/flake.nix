{
  description = "Joel's workstation, the nix bits n bobs";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixos-24.11";
    # Newer nixpkgs used only for select packages (e.g. bitwarden-cli, which
    # needs a newer version to log in). Do NOT pull other packages from here.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager-linux = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs-linux";
    };
  };

  outputs = { nixpkgs-linux, nixpkgs-darwin, nixpkgs-unstable, home-manager-linux, home-manager-darwin, nix-doom-emacs-unstraightened, ... }:
    let
      home-config = settings@{nixpkgs, system, home, user, home-manager, ...}:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nix-doom-emacs-unstraightened.overlays.default ];
            config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [ "symbola" ];
          };
          pkgs-unstable = import nixpkgs-unstable { inherit system; };
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
                    pkgs.go
                    pkgs.ispell
                    pkgs.direnv
                    pkgs.mr  # myrepos https://myrepos.branchable.com/install/
                    pkgs.graphviz
                    pkgs.cmake
                    pkgs.coreutils
                    pkgs.wget
                    pkgs.racket
                  ] ++ nixpkgs.lib.optionals pkgs.stdenv.isLinux [
                    pkgs-unstable.bitwarden-cli
                  ];

                  home.file = {};

                  home.sessionPath = [
                    "~/.nix-profile/bin/"
                  ];

                  home.sessionVariables = {};

                  programs.home-manager.enable = true;
                };
        in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ home-config-mod ./emacs.nix ];
            extraSpecialArgs = { inherit nix-doom-emacs-unstraightened; };
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

        (linuxConfig {
          user = "joel"; ws-name = "aeglos"; system = "x86_64-linux"; home = "/home/joel";
        })

        (macConfig {
          user = "joelmccracken"; ws-name = "glamdring"; system = "x86_64-darwin"; home = "/Users/joelmccracken";
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
