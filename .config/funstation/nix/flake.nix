{
  description = "Joel's workstation, the nix bits n bobs";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixos-24.11";
    # Newer nixpkgs used only for select packages (e.g. bitwarden-cli, which
    # needs a newer version to log in). Do NOT pull other packages from here.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs 26.11 (and so unstable) dropped x86_64-darwin; 26.05 is the last
    # release supporting it. Used in place of unstable on Intel macs.
    nixpkgs-2605-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-26.05";
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

  outputs = { nixpkgs-linux, nixpkgs-darwin, nixpkgs-unstable, nixpkgs-2605-darwin, home-manager-linux, home-manager-darwin, nix-doom-emacs-unstraightened, ... }:
    let
      home-config = settings@{nixpkgs, system, home, user, home-manager, ...}:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nix-doom-emacs-unstraightened.overlays.default ];
            config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [ "symbola" ];
          };
          # Importing unstable at all on x86_64-darwin throws, so select the
          # source before importing.
          nixpkgs-newer =
            if system == "x86_64-darwin" then nixpkgs-2605-darwin else nixpkgs-unstable;
          pkgs-newer= import nixpkgs-newer {
            inherit system;
            config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs-newer.lib.getName pkg) [ "claude-code" ];
          };
          # On darwin, node-gyp (for native npm modules built from source) runs
          # `xcodebuild -version`, but the nixpkgs package only provides xcrun.
          # bitwarden now needs a newer version to log in (for recent 2fa requirements)
          bitwarden-cli = pkgs-newer.bitwarden-cli.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs
              ++ nixpkgs.lib.optionals pkgs-newer.stdenv.isDarwin [ pkgs-newer.xcbuild ];
          });
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
                    # Pulled from unstable (26.05 on x86_64-darwin) to track a
                    # recent release of the CLI.
                    pkgs-newer.claude-code
                    bitwarden-cli
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
