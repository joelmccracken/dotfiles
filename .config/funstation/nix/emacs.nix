{
  pkgs,
  config,
  lib,
  nix-doom-emacs-unstraightened,
  ...
}:
let
  doom-emacs = pkgs.doomEmacs {
    doomDir = ./doomdir;
    doomLocalDir = "${config.xdg.dataHome}/nix-doom-unstraightened";
    # emacsPackageOverrides = eself: esuper: { };
    extraPackages = epkgs: [
      epkgs.daml-mode
    ];
  };
  emacs-alias = pkgs.writeShellScriptBin "emacs" ''
    exec ${doom-emacs}/bin/doom-emacs "$@"
  '';
  emacsclient-wrapper = pkgs.writeShellScriptBin "emacsclient" ''
    exec ${doom-emacs.emacsWithPackages}/bin/emacsclient "$@"
  '';
  emacseditor-wrapper = pkgs.writeShellScriptBin "emacseditor" ''
    if [ -z "$1" ]; then
      exec ${doom-emacs.emacsWithPackages}/bin/emacsclient --create-frame --alternate-editor ${doom-emacs}/bin/doom-emacs
    else
      exec ${doom-emacs.emacsWithPackages}/bin/emacsclient --alternate-editor ${doom-emacs}/bin/doom-emacs "$@"
    fi
  '';
  doom-emacs-launcher = pkgs.writeShellScriptBin "doom-emacs-launcher" ''
    exec ${emacsclient-wrapper}/bin/emacsclient \
      --alternate-editor= \
      --create-frame \
      --eval '(select-frame-set-input-focus (selected-frame))' \
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
    doom-emacs
    emacs-alias
    emacsclient-wrapper
    emacseditor-wrapper
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    doom-emacs-launcher
    doom-emacs-desktop
  ] ++ (with pkgs; [
    coreutils
    fd
    findutils
    git
    ispell
    ripgrep

    bash-language-server
    nil
    yaml-language-server

    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; }) # modeline
    symbola # fallback
  ]);

  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
}
