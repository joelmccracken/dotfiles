{
  description = "Joel's workstation, the nix bits n bobs";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixos-26.05";
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
      url = "github:nix-community/home-manager/release-26.05";
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
          # Hetzner Cloud CLI
          # reads API token from ~/secrets into env var
          hcloud = pkgs.writeShellScriptBin "hcloud" ''
            token_file="$HOME/secrets/hcloud_token"
            if [ -z "''${HCLOUD_TOKEN:-}" ]; then
              if [ -s "$token_file" ] && [ -r "$token_file" ]; then
                HCLOUD_TOKEN="$(cat "$token_file")"
                export HCLOUD_TOKEN
              else
                echo "hcloud wrapper: warning: $token_file is missing, empty or unreadable; running without a token" >&2
              fi
            fi
            exec ${pkgs.hcloud}/bin/hcloud "$@"
          '';
          home-config-mod =
              { config, lib, pkgs, ... }:
                let
                  # Note [Harvesting home-manager's shell integration]
                  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  # home-manager's programs.* modules (direnv, and anything
                  # added later: zoxide, fzf, atuin, starship...) write their
                  # shell hooks into programs.{bash,zsh}.init* UNCONDITIONALLY.
                  # Only the step that writes ~/.bashrc is gated behind
                  # programs.bash.enable, which this configuration deliberately
                  # leaves off -- the rc files are hand-maintained in the
                  # dotfiles repo and home-manager must not own them.
                  #
                  # So the content is harvested into files of our own, which
                  # .commonrc sources.  Before this, every such hook had to be
                  # hand-copied into .commonrc (direnv's was), which silently
                  # failed to happen for anything added later.
                  #
                  # The emitted text carries absolute /nix/store paths, so it
                  # does not depend on PATH and can be sourced anywhere.
                  #
                  # Two files because .commonrc serves both shells and the
                  # hooks differ (`direnv hook bash` vs `... zsh`).
                  #
                  # The zsh option was renamed initExtra -> initContent, and
                  # the linux (24.11) and darwin (26.05) pins sit on opposite
                  # sides of that rename, so both spellings are tried.
                  hmBashInit =
                    if config.programs.bash ? initExtra
                    then config.programs.bash.initExtra
                    else "";
                  hmZshInit =
                    if config.programs.zsh ? initContent
                    then config.programs.zsh.initContent
                    else if config.programs.zsh ? initExtra
                    then config.programs.zsh.initExtra
                    else "";
                in
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
                    # direnv is installed by programs.direnv below, not here.
                    pkgs.mr  # myrepos https://myrepos.branchable.com/install/
                    pkgs.graphviz
                    pkgs.cmake
                    pkgs.coreutils
                    pkgs.wget
                    pkgs.racket
                    pkgs.gh
                    hcloud  # wrapper defined above; token from ~/secrets/hcloud_token
                    # Pulled from unstable (26.05 on x86_64-darwin) to track a
                    # recent release of the CLI.
                    pkgs-newer.claude-code
                    bitwarden-cli
                  ];

                  # See Note [Harvesting home-manager's shell integration].
                  # mkIf keeps an empty file out of ~ when nothing injects.
                  home.file = {
                    ".shell-rc-home-manager.bash" =
                      lib.mkIf (hmBashInit != "") { text = hmBashInit; };
                    ".shell-rc-home-manager.zsh" =
                      lib.mkIf (hmZshInit != "") { text = hmZshInit; };
                  };

                  # Note [Rebuild the font cache on every activation]
                  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  # fontconfig decides a cached directory is stale by comparing
                  # the directory's mtime against the cached one.  Nix pins
                  # every store mtime to epoch 1 for reproducibility, so
                  # ~/.nix-profile/share/fonts and friends look UNCHANGED
                  # across a generation switch even when the store path behind
                  # the symlink is completely different.
                  #
                  # That is normally harmless, because the cached file paths
                  # still resolve.  It breaks when a package changes its
                  # internal layout: nerd-fonts moved its files from
                  # NerdFonts/*.ttf into NerdFonts/Symbols/*.ttf, the cache
                  # kept pointing at the old flat paths, and every consumer
                  # happily reported the font as present -- fc-list, fc-match,
                  # Emacs's font-family-list and char-displayable-p all said
                  # yes.  Only actually opening the file failed, so doom's
                  # modeline icons rendered as tofu with no error anywhere.
                  #
                  # Nothing self-heals it: the invalidation trigger never
                  # fires, so a new process, a re-login and a reboot all read
                  # the same stale cache.  home-manager does not run fc-cache
                  # itself, hence this.
                  #
                  # -r (erase and rebuild) rather than -f: the stale entries
                  # look valid, so an incremental refresh leaves them in place.
                  home.activation.rebuildFontCache =
                    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                      $DRY_RUN_CMD ${pkgs.fontconfig}/bin/fc-cache -r
                    '';

                  home.sessionPath = [
                    "~/.nix-profile/bin/"
                  ];

                  home.sessionVariables = {};

                  programs.home-manager.enable = true;

                  # direnv lives here rather than in the NixOS system config,
                  # so the macOS machines get the same setup.  This replaces a
                  # bare `pkgs.direnv` in home.packages: that installed the
                  # binary but no nix-direnv and no configuration.
                  #
                  # The shell hook is NOT installed from here -- home-manager
                  # only injects it into programs.bash/zsh, which this
                  # configuration does not use.  It lives in .commonrc instead.
                  # What home-manager does provide is ~/.config/direnv/, which
                  # direnv reads by itself:
                  #   direnv.toml          <- programs.direnv.config
                  #   lib/hm-nix-direnv.sh <- programs.direnv.nix-direnv
                  programs.direnv = {
                    enable = true;

                    # Caches `use flake` evaluation and holds a GC root, so
                    # entering a project is instant rather than a full re-eval,
                    # and nix-collect-garbage does not discard the cache.
                    nix-direnv.enable = true;

                    config.global = {
                      # Flake evaluation routinely exceeds direnv's 5s default,
                      # which warns on every cd into a cold project.
                      warn_timeout = "30s";
                      # Don't print a screenful of env diff on every cd.
                      hide_env_diff = true;
                    };
                  };
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
          user = "joel"; ws-name = "angrist"; system = "aarch64-darwin"; home = "/Users/joel";
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
