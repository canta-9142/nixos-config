_:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/ssh.nix

    ./core.nix
    ./gc.nix
    ./boot.nix
    ./networking.nix
    ../../modules/system/audio.nix
    ./packages.nix
    ./users.nix
    ../../modules/system/desktop
    ../../modules/system/distrobox.nix
    ../../modules/system/cloudflare-warp.nix
    ../../modules/system/virtualbox.nix
    ../../modules/system/security/luks.nix
    ../../modules/system/security/apparmor.nix
    ../../modules/system/security/sudo.nix
    ../../modules/system/security/sops.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
