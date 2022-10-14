input@{ config, pkgs, ... }:
let 
  confFile = builtins.readFile ./config.py;

  systemd-newm = pkgs.writeShellScriptBin "systemd-newm" ''
    systemctl --user import-environment PATH
    dbus-update-activation-environment --systemd PATH
    systemctl --user start newm.service
  '';
in
{
  xdg.configFile."newm/config.py".text = confFile;
  xdg.configFile."newm/launcher.py".text = ''
    entries = {
      "firefox": "MOZ_ENABLE_WAYLAND=1 firefox",
      "nautilus": "nautilus",
      "alacritty": "alacritty",
    }

    shortcuts = {
      1: ("Firefox", "MOZ_ENABLE_WAYLAND=1 firefox"),
      2: ("Emacs", "emacs"),
      3: ("Nautilus", "nautilus")
    }
  '';

  xdg.configFile."mako/config".text = ''
    layer=overlay
    background-color=#0D2D2A
    default-timeout=5000
    border-size=0
    border-radius=12
  '';

  xdg.configFile."waybar/config".source = ./waybar/config;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."rofi/config.rasi".source = ./rofi.rasi;

  imports = [
    ./swaync
  ];

  home.packages = with pkgs; [
    newm
    systemd-newm
    waybar
    wob
    rofi-wayland
    #mako
    #deadd-notification-center
    dunst
    libnotify

    pywm-fullscreen

    grim
    slurp
    wdisplays

    gnome.nautilus
    dconf
    #evolution
    #evolution-ews
    gnome.adwaita-icon-theme
    xfce.thunar

    pavucontrol
    eww-wayland

    sway
  ];

  home.file."wallpaper.jpg".source = ./wallpaper.jpg;

  systemd.user.services.newm = {
    Unit = {
      Description = "Newm - Wayland window manager";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
      # We explicitly unset PATH here, as we want it to be set by
      # systemctl --user import-environment in startsway
      # environment.PATH = lib.mkForce null;
    };
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.newm}/bin/start-newm
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # dunst
  #services.dunst.enable = true;
  services.dunst.waylandDisplay = "wayland-0";
  services.dunst.settings = {
    global = {
      follow = "mouse";
    };
    logger = {
      summary = "*";
      script = "/home/alexander/.config/eww/Control-Center/scripts/logger.zsh";
    };
  };

  /*systemd.user.services.deadd-notification-center = {
    Unit = {
      Description = "Deadd Notification Center";
      PartOf = [ "graphical-session.target" ];
      #X-Restart-Triggers = [ "${config.xdg.configFile."deadd/deadd.conf".source}" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.deadd-notification-center}/bin/deadd-notification-center";
      Restart = "always";
      RestartSec = "1sec";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."deadd/deadd.conf".source = ./deadd/deadd.conf;
  xdg.configFile."deadd/deadd.css".source = ./deadd/style.css;*/
}
