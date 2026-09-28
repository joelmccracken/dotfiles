{
  pkgs,
  config,
  lib,
  nix-doom-emacs-unstraightened,
  ...
}:
let
  doomArgs = {
    doomDir = ./doomdir;
    doomLocalDir = "${config.xdg.dataHome}/nix-doom-unstraightened";
    # emacsPackageOverrides = eself: esuper: { };
    extraPackages = epkgs: [
      epkgs.daml-mode
    ];
  };
  emacs-with-doom = pkgs.emacsWithDoom doomArgs;
  emacseditor-wrapper = pkgs.writeShellScriptBin "emacseditor" ''
    if [ -z "$1" ]; then
      exec ${emacs-with-doom}/bin/emacsclient --create-frame --alternate-editor ${emacs-with-doom}/bin/emacs
    else
      exec ${emacs-with-doom}/bin/emacsclient --alternate-editor ${emacs-with-doom}/bin/emacs "$@"
    fi
  '';
  doom-emacs-launcher = pkgs.writeShellScriptBin "doom-emacs-launcher" ''
    exec ${emacs-with-doom}/bin/emacsclient \
      --alternate-editor=${emacs-with-doom}/bin/emacs \
      --create-frame \
      "$@"
  '';
  doom-emacs-desktop = pkgs.makeDesktopItem {
    name = "doom-emacs";
    desktopName = "Doom Emacs";
    genericName = "Text Editor";
    comment = "Edit text files";
    exec = "${doom-emacs-launcher}/bin/doom-emacs-launcher %F";
    icon = "emacs";
    type = "Application";
    terminal = false;
    categories = [ "Development" "TextEditor" ];
    startupWMClass = "Emacs";
    mimeTypes = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };
in
{
  home.packages = [
    emacs-with-doom
    emacseditor-wrapper
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    doom-emacs-launcher
    doom-emacs-desktop
  ]
   # ++ lib.optionals pkgs.stdenv.isDarwin [
    
  # ] 
  ++ (with pkgs; [
    coreutils
    fd
    findutils
    git
    ispell
    ripgrep

    bash-language-server
    nil
    yaml-language-server
    typescript-language-server

    # modeline; nerdfonts was split into nerd-fonts.* in 25.05. Remove the
    # fallback once all machines are on >= 25.05.
    (if pkgs ? nerd-fonts
     then nerd-fonts.symbols-only
     else nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    symbola # fallback
  ]);

  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
}
