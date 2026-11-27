{ pkgs, ... }:
{
  imports = [
    ../nix
    ../cli.nix
    ../fish.nix
    ../nix/cache-client.nix
  ];

  time.timeZone = "Asia/Tokyo";

  users.users.root.shell = pkgs.fish;
  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = [ pkgs.vim ];
}
