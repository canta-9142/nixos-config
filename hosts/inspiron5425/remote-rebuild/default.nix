{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nixos-remote-rebuild";
      runtimeInputs = [
        config.nix.package
        pkgs.coreutils
        pkgs.git
        pkgs.openssh
        pkgs.rsync
        pkgs.util-linux
      ];
      text = builtins.readFile ./remote-rebuild.sh;
    })
  ];

  programs.fish.shellFunctions = {
    nsr.body = "nixos-remote-rebuild switch $argv";
    nbr.body = "nixos-remote-rebuild boot $argv";
  };
}
