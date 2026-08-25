{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.etc."niri/config.kdl".source = ./config.kdl;

  programs.waybar.enable = true;

  systemd.user.services.waybar.serviceConfig.RestartSec = 3;
}
