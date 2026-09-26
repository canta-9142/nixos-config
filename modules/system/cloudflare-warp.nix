{ lib, ... }:

{
  services.cloudflare-warp.enable = true;
  networking.firewall.checkReversePath = lib.mkDefault "loose";
}
