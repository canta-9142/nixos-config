{ pkgs, ... }:
{
  imports = [
    ../../users/jinji/server.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./kernel.nix
    ./fan-control.nix
    ./ethernet-leds.nix
    ./boot.nix
    ./networking.nix
    ../../modules/system/server
    ../../modules/system/server/ssh.nix
    ../../modules/system/cloudflare-warp.nix
  ];

  networking.hostName = "rock3b";

  programs.direnv.enable = true;

  nixpkgs.overlays = [
    (_final: prev: {
      phytool = prev.phytool.overrideAttrs {
        env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable";
      };
    })
  ];

  environment = {
    sessionVariables.NH_FLAKE = "/home/jinji/servers-config#rock3b";
    systemPackages = with pkgs; [
      wget
      curl
      ripgrep
      yazi
      fastfetch
      fetch
      htop
      zellij
      dnsutils
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - jinji users - /home/jinji/servers-config"
  ];

  system.stateVersion = "26.05";
}
