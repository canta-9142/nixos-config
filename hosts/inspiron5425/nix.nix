{ config, lib, ... }:
let
  # Fill this file with the public key obtained directly from Ryzen before activation.
  publicKey = lib.trim (builtins.readFile ./nix-cache.pub);
in
{
  sops.secrets.nix_builder_private_key = {
    sopsFile = ../../secrets/nix-builder.yaml;
    owner = "root";
    mode = "0400";
  };

  nix = {
    distributedBuilds = true;
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      keep-derivations = false;
      max-jobs = 0;
      builders-use-substitutes = true;
    }
    // lib.optionalAttrs (publicKey != "") {
      extra-substituters = [ "https://cache.floating-gate.com?priority=50" ];
      extra-trusted-public-keys = [ publicKey ];
      # Use cached outputs even for runCommandLocal, including fish completions.
      always-allow-substitutes = true;
      # Continue with the existing builder when fetching a substitute fails.
      fallback = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
    buildMachines = [
      {
        hostName = "ryzen.home.arpa";
        protocol = "ssh-ng";
        sshUser = "nix-builder";
        sshKey = config.sops.secrets.nix_builder_private_key.path;
        system = "x86_64-linux";
        maxJobs = 12;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "R! /tmp/nh-* - - - -"
  ];

  programs.ssh.knownHosts.ryzen-builder = {
    hostNames = [ "ryzen.home.arpa" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDE+1llHeMRVTtzixbjwsajkArSdUgqVrQzsRw3Yig3Y";
  };
  programs.ssh.extraConfig = ''
    Host ryzen.home.arpa
      BatchMode yes
      IdentitiesOnly yes
      StrictHostKeyChecking yes
      ConnectTimeout 10
      ServerAliveInterval 15
      ServerAliveCountMax 3
  '';
}
