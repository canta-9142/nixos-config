{ lib, ... }:
let
  publicKey = lib.trim (builtins.readFile ./nix-cache.pub);
in
{
  assertions = [
    {
      assertion = publicKey != "";
      message = "The binary cache requires its verified public key in modules/system/nix-cache.pub.";
    }
  ];

  nix.settings = {
    extra-substituters = [ "https://cache.floating-gate.com?priority=50" ];
    extra-trusted-public-keys = [ publicKey ];
    always-allow-substitutes = true;
    fallback = true;
  };
}
