{ config, pkgs, lib, ... }:
let
  allDevicesExceptPixel = {
    desktop = {
      name = "desktop";
      id = "S6NVNGZ-6S56NOX-RM3YCQP-PAKJN3J-BJHQ3VE-FRAA6BC-XPYBXUM-T5WEBAO";
    };
    phone = {
      name = "phone";
      id = "R3X7TBQ-HG35NDY-OXJSFNG-MFNWHAV-HUIRI4G-YCKWIT6-4WXYHG2-3QHBIQM";
    };
    tablet = {
      name = "tablet";
      id = "LQBHRI2-RDHW5ZM-PBQ42UZ-6XUC2BV-R6V24ML-UDOJTQB-XN37KDK-4FOJ7QJ";
    };
    nas = {
      name = "nas";
      # id = "ZOBQMXM-ACM5UZJ-5MZPATJ-2SLBGSI-RCE5N5G-ZU5TFMT-JJWHRXM-SDFOFQ3";
      id = "DHVK56T-UYDGRYR-T24BQJ4-U2GM6MY-PSXDCXA-LTMKIKZ-W2CSRR2-ZSHETQS";
    };
  };
  allDevices = allDevicesExceptPixel // {
    pixel = {
      name = "pixel";
      id = "SAJDLKJ-3XSNWEG-64OCUL2-KZ4YBTA-OYM25JJ-PI2G7K6-LW4BAIK-ZBBKYA7";
    };
  };
  devicesNamesExceptPixel = [
    "desktop"
    "phone"
    "tablet"
    "nas"
  ];
  devicesNames = devicesNamesExceptPixel ++ [
    "pixel"
  ];
in
{
  services.syncthing = {
    enable = true;
    dataDir = "/home/alexander";
    user = "alexander";

    settings = {
      devices = allDevices;
      folders =
        let
          staggered = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        in
          {
          Notizen = {
            path = "~/Dokumente/Notizen";
            versioning = staggered;
            devices = devicesNamesExceptPixel;
            id = "bvl4i-olzll";
          };
          Geistliches = {
            path = "~/Dokumente/Geistliches";
            versioning = staggered;
            devices = devicesNamesExceptPixel;
            id = "64kub-awlpo";
          };
        };
      };
    };
}
