{ pkgs, ... }:
{
  imports = [
    ../../users/jinji/server.nix
    ./hardware-configuration.nix
    ./kernel.nix
    ./initrd-debug.nix
    ../../modules/system/server
    ../../modules/system/server/ssh.nix
  ];

  networking = {
    hostName = "cubiea5e";
    networkmanager.enable = true;
  };

  programs.direnv.enable = true;
  environment = {
    sessionVariables.NH_OS_FLAKE = "/home/jinji/nixos-config#cubiea5e";
    systemPackages = [ pkgs.pciutils ];
  };

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - jinji users - /home/jinji/nixos-config"
  ];

  system.stateVersion = "26.05";
}
