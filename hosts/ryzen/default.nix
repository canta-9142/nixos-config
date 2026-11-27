{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./forgejo.nix
    ./immich.nix
    ./runner.nix
    ./web.nix
    ./nix-cache.nix
    ./nix-ci.nix
    ./kernel-build.nix
    ../../modules/system/server/common.nix
    ../../modules/system/server/ssh.nix
    ../../modules/system/server/cloudflare-mesh.nix
    ../../modules/system/server/maintenance.nix
    ../../modules/system/server/nix-builder.nix
  ];

  networking = {
    hostName = "ryzen";
    # The router reserves the address using the physical Ethernet MAC.
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  environment.sessionVariables.NH_FLAKE = "/home/jinji/servers-config#ryzen";

  system.stateVersion = "26.05";
}
