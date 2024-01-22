input@{ config, pkgs, lib, niri, ... }:
let 
  confFile = builtins.readFile ./config.kdl;

in
{ 
  xdg.configFile."niri/config.kdl".text = confFile;

  imports = [
  ];

  home.packages = with pkgs; [
  ];

  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;

  systemd.user.services.waybar.Service = {
    Restart = lib.mkOverride 0 "on-failure";
    RestartSec = "3";
  };

}

