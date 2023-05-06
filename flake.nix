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
    newmpkg.url = "sourcehut:~atha/newm-atha#newm-atha";
    newmpkg.inputs.nixpkgs.follows = "nixpkgs";
    pywm-fullscreenpkg.url = "github:jbuchermn/pywm-fullscreen";
    pywm-fullscreenpkg.inputs.nixpkgs.follows = "nixpkgs";

    # Version from 2022-11-14 does not work with org-roam
    #emacs-overlay.url = "github:nix-community/emacs-overlay/ab39e4112f2f97fa5e13865fa6792e00e6344558";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    #emacs-overlay.url = "github:nix-community/emacs-overlay/5403096194fd02e1a5424a365d057d934c705639";

    #vscode-marketplace.url = "github:ameertaweel/nix-vscode-marketplace";
    vscode-marketplace.url = "github:nix-community/nix-vscode-extensions";

  };

  outputs = { self, nixpkgs, home-manager, nur, newmpkg, pywm-fullscreenpkg, vscode-marketplace, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlay
          (self: super: {
            newm = newmpkg.packages.x86_64-linux.newm;
            pywm-fullscreen = pywm-fullscreenpkg.packages.x86_64-linux.pywm-fullscreen;
          })
          (import self.inputs.emacs-overlay)

          (self: super: {
            iosevka-fixed = super.iosevka.override { set = "fixed"; };
            iosevka-fixed-slab = super.iosevka.override { set = "fixed-slab"; };
          })

          /*(self: super: {
            my-custom-snip = super.callPackage ./custom/snip.nix { };
          })*/
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
          ];
        };
      };
      
    };
    
}
