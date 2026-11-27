{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "cloudflare-warp";
  services.cloudflare-warp.enable = true;
  networking.firewall.checkReversePath = lib.mkDefault "loose";
}
