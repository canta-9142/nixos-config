{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/core.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/security/sudo.nix

    # SOPS is planned but not enabled yet.
    # ../../modules/nixos/security/sops.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
