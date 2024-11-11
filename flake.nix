{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    # newmpkg.url = "github:jbuchermn/newm";
    # newmpkg.url = "sourcehut:~atha/newm-atha";
    #ewmpkg.url = "github:EpsilonKu/newm-atha";
    #ewmpkg.inputs.nixpkgs.follows = "nixpkgs";
    #pywm-fullscreenpkg.url = "github:jbuchermn/pywm-fullscreen";
    #pywm-fullscreenpkg.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    #niri.url = github:AlexD97/niri-flake;
    #niri.inputs.niri-src.url = "github:YaLTeR/niri";

    #emacs-overlay.url = "github:nix-community/emacs-overlay/8c56baa0e5ba4bbf9947605a31672e2f4735b1a9";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    #vscode-marketplace.url = "github:ameertaweel/nix-vscode-marketplace";
    vscode-marketplace.url = "github:nix-community/nix-vscode-extensions";

  };

  outputs = { self, nixpkgs, home-manager, nur, niri, vscode-marketplace, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlay
          # (self: super: {
          #   newm = newmpkg.packages.x86_64-linux.newm-atha;
          #   #pywm-fullscreen = pywm-fullscreenpkg.packages.x86_64-linux.pywm-fullscreen;
          # })
          (import self.inputs.emacs-overlay)

          (self: super: {
            iosevka-fixed = super.iosevka.override { set = "fixed"; };
            iosevka-fixed-slab = super.iosevka.override { set = "fixed-slab"; };
          })

          # (self: super: {ripgrep-all = super.ripgrep-all.overrideAttrs (old: {
          #   doInstallCheck = false; });}
          # )

          (final: prev: {vaapiIntel = prev.vaapiIntel.overrideAttrs (old: {
            enableHybridCodec = true; });}
          )

          # (final: prev: {typst = prev.typst.overrideAttrs (old: {
          #   src = prev.fetchFromGitHub {
          #     owner = "typst";
          #     repo = "typst";
          #     rev = "master";
          #     hash = "sha256-q2b/PoNwpzarJbIPzokYgZRD2/Oe/XB40C4VXdwL/NA=";
          #   };
          #   version = "master"; });}
          # )

          (final: prev: {rofi-wayland = prev.rofi-wayland.overrideAttrs (old: {
            src = prev.fetchFromGitHub {
              owner = "lbonn";
              repo = "rofi";
              rev = "0a0cc5f";
              fetchSubmodules = true;
              hash = "sha256-R+6ChMPXARftFu9xOygQAsu8Nv53L33lBrUdfeuiqK0=";
            };
            version = "latest"; });}
          )
          /*(self: super: {
            my-custom-snip = super.callPackage ./custom/snip.nix { };
          })*/

          niri.overlays.niri
          #niri.overlays.niri
        ];
      };
      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        alexander = lib.nixosSystem {
          inherit system pkgs;
          modules = [ 
           ./configuration.nix
           home-manager.nixosModules.home-manager {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.users.alexander = {
               imports = [ ./home.nix ];
             };
             home-manager.extraSpecialArgs = {
               inherit pkgs vscode-marketplace system;
             };
           }
           niri.nixosModules.niri
           {
             programs.niri.enable = true;
             nixpkgs.overlays = [ niri.overlays.niri ];
             programs.niri.package = pkgs.niri-unstable;
           }
          ];
        };
      };
      
    };
    
}
