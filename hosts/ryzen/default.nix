{ lib, ... }:
{
  imports = [
    ../../users/jinji/server.nix
    ./hardware-configuration.nix
    ./storage.nix
    ./forgejo.nix
    ./immich.nix
    ./runner.nix
    ./web.nix
    ./nix-cache.nix
    ./nix-ci.nix
    ../../modules/system/nix/ccache.nix
    ../../modules/system/server
    ../../modules/system/server/ssh.nix
    ../../modules/system/cloudflare-warp.nix
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
