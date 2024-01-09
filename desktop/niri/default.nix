input@{ config, pkgs, ... }:
let 
  confFile = builtins.readFile ./config.kdl;
in
{
  xdg.configFile."niri/config.kdl".text = confFile;

  imports = [
  ];

  home.packages = with pkgs; [
  ];

}

