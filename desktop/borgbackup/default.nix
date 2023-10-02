{pkgs, lib, config, ...} : {
  config.services.borgbackup.jobs =
    let common-excludes = [
          # Largest cache dirs
          ".cache"
          "*/cache2" # firefox
          "*/Cache"
          "*/.cache"
          "*/cache"
          ".gradle"
          ".cmake"
          ".crashlytics"
          ".mozilla"
          ".java"
          ".julia"
          ".jupyter"
          ".mathlib"
          ".vpython_cipd_cache"
          ".vpython_root"
          ".zoom"
          ".config/kwinrc.lock"
          ".local/share/baloo"
          ".config/Code/CachedData"
          ".container-diff"
          ".npm/_cacache"
          # Work related dirs
          "*/node_modules"
          "*/bower_components"
          "*/_build"
          "*/.tox"
          "*/venv"
          "*/.venv"
        ];
        homePath = "/home/alexander";
  in {
    homeBackup = rec {
      paths = "${homePath}";
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${homePath}/.ssh/id_nixos_server";
      environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      repo = "ssh://alexander@nixosserver/sharedfolders/Backups/NixosLaptopBackup";
      exclude = map (x: paths + "/" + x) common-excludes;
      startAt = "*-*-01/2 00:00:00";
      extraCreateArgs = "--verbose --stats";
    };
  };
  config.systemd.services = {
    notify-borgbackup-failure = {
      enable = true;
      serviceConfig.User = "alexander";
      environment = {
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus";
      };
      script = ''
        ${pkgs.libnotify}/bin/notify-send -u critical "Borgbackup failed!" "Check journalctl logs"
      '';
    };
    notify-borgbackup-success = {
      enable = true;
      serviceConfig.User = "alexander";
      environment = {
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus";
      };
      script = ''
        ${pkgs.libnotify}/bin/notify-send "Borgbackup successful"
      '';
    };
    borgbackup-job-homeBackup = {
      unitConfig.OnFailure = "notify-borgbackup-failure.service";
      unitConfig.OnSuccess = "notify-borgbackup-success.service";
      preStart = lib.mkBefore ''
        # waiting for internet after resume-from-suspend
        until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do :; done
      '';
      #timerConfig.Persistent = true;
    };
  };
  config.systemd.timers = {
    borgbackup-job-homeBackup.timerConfig.Persistent = lib.mkOverride 0 true;
  };
}
