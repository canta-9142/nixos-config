{ config, ... }:
{
  imports = [ ../../modules/system/nix/cache-client.nix ];

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
