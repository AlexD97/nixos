inputs@{ config, pkgs, lib, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    # other python packages you want
    python-lsp-server
    numpy
    pillow
    matplotlib
    scipy
    requests
    beautifulsoup4
    pypdf2
    openai
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

  agda-with-my-packages = pkgs.agda.withPackages (p: [ p.standard-library p.cubical ]);
in

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "alexander";
  home.homeDirectory = "/home/alexander";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./desktop/newm
    ./desktop/sway
    ./desktop/emacs
    #./desktop/email
    ./desktop/eww
    ./desktop/applications
    # ./zsh.nix

    ./custom/fsautocomplete.nix
    ./custom/snip.nix
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM="wayland-egl";
  };

  systemd.user.sessionVariables = {
    TYPST_FONT_PATHS = "${config.home.path}/share/fonts";
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = [ "org.gnome.Evince.desktop" "sioyek.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Evince.desktop" "sioyek.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    alacritty
    #emacs
    vlc
    mpv
    yt-dlp
    ffmpeg
    anki
    syncthingtray
    warpd
    sqlite
    ripgrep
    ripgrep-all
    pinentry-gnome
    imagemagick
    poppler_utils
    graphviz
    jq

    #nyxt

    libreoffice-fresh
    hunspellDicts.de_DE
    aspell
    aspellDicts.de
    
    isync
    notmuch

    libappindicator

    udiskie
    jmtpfs

    #python3
    python-with-my-packages
    julia-bin
    ghc
    agda-with-my-packages
    dotnet-sdk
    gnumake
    rnix-lsp
    nodejs
    idris2
    haskell-language-server
    cabal-install
    cargo
    rustc

    tree-sitter
    tree-sitter-grammars.tree-sitter-typst

    zsh
    fzf
    zsh-powerlevel10k
    moreutils
    bc
    recode

    emacs-all-the-icons-fonts
    material-design-icons
    (nerdfonts.override { fonts = ["FiraCode" "DroidSansMono" "Iosevka" "SourceCodePro" "JetBrainsMono" ]; })
    #iosevka-fixed
    #iosevka-fixed-slab
    (iosevka-bin.override { variant = "sgr-iosevka-fixed"; } )
    (iosevka-bin.override { variant = "sgr-iosevka-fixed-curly-slab"; } )
    alegreya
    alegreya-sans
    gyre-fonts
    libertinus
    xits-math
    vistafonts
    stix-two
    dejavu_fonts
    vollkorn

    texlive.combined.scheme-full
    ghostscript
    lhs2tex

    pandoc
    pdftk

    typst
    typst-lsp
    typst-fmt

    sioyek
    evince
    pympress

    borgbackup
    vorta
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; with inputs.vscode-marketplace.extensions.${inputs.system}.vscode-marketplace; [
      james-yu.latex-workshop
      julialang.language-julia
      ms-dotnettools.csharp
      ionide.ionide-fsharp
      bbenoist.nix
      ms-python.python
      pkgs.vscode-extensions.github.copilot
      nvarner.typst-lsp
      mgt19937.typst-preview
      rust-lang.rust-analyzer

      akamud.vscode-theme-onelight
    ];
  };

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
    syncthing = {
    #  enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
  };

  systemd.user.services.kdeconnect.Service = {
    Restart = lib.mkOverride 0 "on-failure";
    RestartSec = "3";
  };

  systemd.user.services.kdeconnect-indicator.Service = {
    Restart = lib.mkOverride 0 "on-failure";
    RestartSec = "3";
  };

  systemd.user.services.syncthingtray.Service = {
    Restart = "on-failure";
    RestartSec = "3";
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

}
