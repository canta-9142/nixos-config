{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./initrd-debug.nix
    ../../modules/system/server/common.nix
    ../../modules/system/server/ssh.nix
  ];

  networking = {
    hostName = "cubiea5e";
    networkmanager.enable = true;
  };

  programs.direnv.enable = true;
  nix.package = pkgs.lixPackageSets.stable.lix;
  environment = {
    sessionVariables.NH_FLAKE = "/home/jinji/servers-config#cubiea5e";
    systemPackages = [ pkgs.pciutils ];
  };

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - jinji users - /home/jinji/servers-config"
  ];

  system.stateVersion = "26.05";
}
