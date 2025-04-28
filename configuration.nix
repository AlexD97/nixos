# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, builtins, ... }:
let
  user = "alexander";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./framework_laptop.nix
      ./syncthing.nix
      ./desktop/borgbackup
      ./zsh.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-daacb8ec-48e8-4f8a-bb18-8a541c3c2824".device = "/dev/disk/by-uuid/daacb8ec-48e8-4f8a-bb18-8a541c3c2824";
  boot.initrd.luks.devices."luks-daacb8ec-48e8-4f8a-bb18-8a541c3c2824".keyFile = "/crypto_keyfile.bin";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.i2c.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  #networking.networkmanager.wifi.scanRandMacAddress = false;
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.displayManager.sddm.settings.Wayland.SessionDir = "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
  # services.xserver.desktopManager.plasma5.runUsingSystemd = true;
  services.xserver.displayManager.lightdm.enable = false;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "de";
      variant = "neo";
    };
  };

  # services.xserver.desktopManager.session = [
  #   { #manage = "desktop";
  #     name = "newm";
  #     #start = ''
  #     #  systemctl --user import-environment PATH
  #     #  dbus-update-activation-environment --systemd PATH
  #     #  systemctl --user start newm.service
  #     #'';
  #     start = ''
  #       ${pkgs.stdenv.shell} ${pkgs.newm}/bin/start-newm & waitPID=$!
  #     '';
  #   }
  # ];

  # Configure console keymap
  console.keyMap = "neo";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns4 = true;

  # Swaylock
  security.pam.services.swaylock = {};

  # Polkit
  security.polkit.enable = true;
  
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Android
  # services.udev.packages = [ pkgs.android-udev-rules ];
  programs.adb.enable = true;
  # users.users.alexander.extraGroups = [ "adbusers" ];
  
  # Screen share on wlroots
  xdg = {
    portal = {
      enable = true;
      # config.common.default = "*";
      # config = {
      #   niri = {
      #     default = [ "gnome" "gtk" ];
      #     "org.freedesktop.impl.portal.Secret" = [
      #       "gnome-keyring"
      #     ];
      #   };
      # };
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        # xdg-desktop-portal-gtk
        # xdg-desktop-portal-gnome
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Brightness control
  hardware.acpilight.enable = true;

  # Thunderbolt
  services.hardware.bolt.enable = true;

  environment.variables = {
    QT_QPA_PLATFORM="wayland-egl";
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    #NIXOS_OZONE_WL = "1";
    EDITOR = "emacsclient -nw -c -F '((font . \"Iosevka-12\"))' -a 'emacs -nw'";
    QT_QPA_PLATFORMTHEME = "kde";
    #TYPST_FONT_PATHS = "${config.home.profileDirectory}/share/fonts";
    #GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"; # for gtk / udiskie (pixbuf)
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # SSD trim
  services.fstrim.enable = lib.mkDefault true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "alexander";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "qemu-libvirtd" "adbusers" ];
    packages = with pkgs; [
      firefox
      brave
      kdePackages.kate
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # programs.firefox.languagePacks = [ "de" "en-US" ];

  # Allow unfree packages
  # Option already set in flake.nix
  # nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wayland
    xwayland
    qt5.qtwayland
    git
    clang
    gcc
    brightnessctl
    pulseaudio
    wget
    gnupg
    pinentry
    pass
    pass-secret-service
    htop
    udisks
    pciutils
    samba
    unzip
    dig

    
    virt-manager
    win-virtio

  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];

  # fonts.packages = with pkgs; [
  #   vollkorn
  # ];
  
  # kdeconnect
  # programs.kdeconnect.enable = true;

  # Android MTP mount
  services.gvfs.enable = true;

  # Virtualisation
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
  programs.virt-manager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
  #   enableSSHSupport = true;
   };

   programs.ssh.startAgent = true;

  #  programs.evolution = {
  #   enable = true;
  #   #plugins = [ pkgs.evolution-ews ];
  # };

  # Battery life / tlp
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
      START_CHARGE_THRESH_BAT0 = 80;
      STOP_CHARGE_THRESH_BAT0 = 85;
      RUNTIME_PM_ON_BAT = "auto";
      #USB_AUTOSUSPEND=1;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  nix = {
    #package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
