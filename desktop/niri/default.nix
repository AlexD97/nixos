input@{ config, pkgs, lib, niri, ... }:
let 
  confFile = builtins.readFile ./config.kdl;

in
{ 
  # xdg.configFile."niri/config.kdl".text = confFile;
  programs.niri.config = confFile;
  #programs.niri.package = pkgs.niri-unstable;

  imports = [
  ];

  home.packages = with pkgs; [
    xwayland-satellite
  ];

  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;

  systemd.user.services.waybar.Service = {
    Restart = lib.mkOverride 0 "on-failure";
    RestartSec = "3";
  };

}

