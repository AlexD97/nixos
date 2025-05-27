{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-git-pgtk;
    extraPackages = epkgs : [
      epkgs.vterm
      epkgs.async
      epkgs.vterm-toggle

      epkgs.auctex

      epkgs.pdf-tools

      epkgs.treesit-grammars.with-all-grammars

      #epkgs.typst-mode
      
      epkgs.undo-tree
      epkgs.olivetti
      epkgs.counsel
      epkgs.swiper
      epkgs.vertico
      epkgs.orderless
      epkgs.consult
      epkgs.affe
      epkgs.marginalia
      epkgs.embark
      #epkgs.company
      #epkgs.company-quickhelp
      epkgs.corfu
      #epkgs.corfu-doc
      epkgs.cape
      epkgs.ripgrep
      epkgs.flycheck

      epkgs.htmlize
      epkgs.all-the-icons
      epkgs.all-the-icons-dired
      epkgs.dired-hide-dotfiles
      epkgs.dired-open
      epkgs.svg-tag-mode
      epkgs.rainbow-delimiters
      epkgs.org-bullets
      epkgs.ligature

      epkgs.quelpa
      epkgs.bind-key
      epkgs.use-package
      epkgs.yasnippet

      epkgs.notmuch

      epkgs.eglot-jl
      epkgs.julia-mode
      epkgs.fsharp-mode
      epkgs.eglot-fsharp
      epkgs.nix-mode
      epkgs.python-mode
      epkgs.idris-mode
      epkgs.haskell-mode
      epkgs.lsp-haskell
      epkgs.rust-mode
      epkgs.lsp-mode

      epkgs.magit

      #epkgs.auctex-latexmk

      epkgs.org-roam
      epkgs.emacsql
      #epkgs.emacsql-sqlite
      epkgs.sqlite3
      epkgs.org-journal
      #epkgs.one-themes
      epkgs.doom-themes
      epkgs.org-ql
    ];
  };

  services.emacs.enable = true;
  services.emacs.startWithUserSession = "graphical"; # otherwise emacs doesn't start other programs in niri (has probably to do with wayland-display env var)

  home.file.".emacs".source = ./emacs_config;
  #home.file.".emacs".source = config.lib.file.mkOutOfStoreSymlink ./emacs_config;
}
