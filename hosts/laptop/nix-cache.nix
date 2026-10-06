{ lib, ... }:
let
  # Fill this file with the public key obtained directly from Ryzen before activation.
  publicKey = lib.trim (builtins.readFile ./nix-cache.pub);
in
{
  nix.settings = lib.mkIf (publicKey != "") {
    extra-substituters = [ "https://cache.floating-gate.com?priority=50" ];
    extra-trusted-public-keys = [ publicKey ];
    # Use cached outputs even for runCommandLocal, including fish completions.
    always-allow-substitutes = true;
    # Continue with the existing builder when fetching a substitute fails.
    fallback = true;
  };
}
