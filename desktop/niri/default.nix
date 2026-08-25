{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.etc."niri/config.kdl".source = ./config.kdl;

  programs.waybar.enable = true;

  systemd.user.services.waybar = {
    # Defining the unit here generates a drop-in; without this it
    # would carry the NixOS default Environment="PATH=coreutils:…",
    # so waybar's custom/notification exec-if (`which swaync-client`)
    # cannot find swaync-client from the user profile.
    enableDefaultPath = false;
    serviceConfig.RestartSec = 3;
  };
}
