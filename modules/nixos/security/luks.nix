{ lib, ... }:

{
  boot = {
    initrd = {
      systemd.enable = true;
      luks.devices.cryptroot = {
        device = "/dev/disk/by-uuid/2d46f4dd-2a5f-48ee-8090-947c9076c710";
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };

    lanzaboote.measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };
  };

  fileSystems."/".device = lib.mkForce "/dev/mapper/cryptroot";
}
