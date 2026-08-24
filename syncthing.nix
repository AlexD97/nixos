{ config, pkgs, lib, ... }:
let
  allDevicesExceptPixel = {
    phone = {
      name = "phone";
      id = "A2KIQS2-TFUCGOR-OM7RYUB-FRPLNDV-GB2S37W-7Z6PAST-UYSPLUB-ORV5SA4";
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
