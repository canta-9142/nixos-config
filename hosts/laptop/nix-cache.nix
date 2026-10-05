{ lib, ... }:
let
  # Fill this file with the public key obtained directly from Ryzen before activation.
  publicKey = lib.trim (builtins.readFile ./nix-cache.pub);
in
{
  nix.settings = lib.mkIf (publicKey != "") {
    extra-substituters = [ "https://cache.floating-gate.com?priority=50" ];
    extra-trusted-public-keys = [ publicKey ];
    # Continue with the existing builder when fetching a substitute fails.
    fallback = true;
  };
}
