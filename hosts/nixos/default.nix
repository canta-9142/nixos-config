{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/sysytem/core.nix
    ../../modules/system/gc.nix
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/packages.nix
    ../../modules/system/users.nix
    ../../modules/system/desktop
    ../../modules/system/distrobox.nix
    ../../modules/system/virtualbox.nix
    ../../modules/system/security/luks.nix
    ../../modules/system/security/apparmor.nix
    ../../modules/system/security/sudo.nix
    ../../modules/system/security/sops.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
