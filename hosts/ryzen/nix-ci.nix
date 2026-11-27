{
  config,
  lib,
  pkgs,
  ...
}:
let
  update = pkgs.writeShellApplication {
    name = "nix-cache-update";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      gitMinimal
      jq
      config.nix.package
    ];
    text = builtins.readFile ../../scripts/update-nix-cache.sh;
  };
  serversUpdate = pkgs.writeShellApplication {
    name = "servers-nix-cache-update";
    text = ''
      export CACHE_UPDATE_REPOSITORY=jinji/servers-config
      export CACHE_UPDATE_PUBLIC_KEY_FILE=modules/system/nix/cache.pub
      exec ${update}/bin/nix-cache-update \
        .#nixosConfigurations.ryzen.config.system.build.toplevel \
        .#nixosConfigurations.rock3b.config.system.build.toplevel \
        .#nixosConfigurations.cubiea5e.config.system.build.toplevel \
        .#rock3b-image \
        .#cubiea5e-image
    '';
  };
  runners = {
    nix = {
      label = "ryzen-nix-build";
      tokenFile = "/etc/forgejo-runner/nix.env";
      stateDirectory = "gitea-runner-nix";
      workDirectory = "/var/lib/gitea-runner-nix/nix";
    };
    servers = {
      label = "ryzen-servers-build";
      tokenFile = "/etc/forgejo-runner/servers-nix.env";
      stateDirectory = "gitea-runner-servers";
      workDirectory = "/var/lib/gitea-runner-servers";
    };
  };
in
{
  imports = [ ../../modules/system/server/forgejo-runner-registration.nix ];

  nix.settings = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://look.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "look.cachix.org-1:8elPCeSVBzlDZXqIRKBK9GyLIK/Hoe1xiWZF0ir7uX4="
    ];
  };

  environment.systemPackages = [
    update
    serversUpdate
  ];
  users.groups.nix-ci = { };
  users.users.nix-ci = {
    isSystemUser = true;
    group = "nix-ci";
    home = "/var/lib/gitea-runner-nix/nix";
  };

  services.forgejo-runner.instances = lib.mapAttrs (_: runner: {
    enable = true;
    registration = {
      name = runner.label;
      inherit (runner) tokenFile;
    };
    hostPackages = with pkgs; [
      bash
      coreutils
      gitMinimal
      nodejs_22
      config.nix.package
    ];
    settings = {
      server.connections.default.url = "http://127.0.0.1:3000";
      runner = {
        labels = [ "${runner.label}:host" ];
        capacity = 1;
        timeout = "8h";
      };
      cache.enabled = false;
    };
  }) runners;

  systemd.services = lib.mapAttrs' (
    name: runner:
    lib.nameValuePair "forgejo-runner-${name}" {
      after = [ "forgejo.service" ];
      wants = [ "forgejo.service" ];
      environment = {
        HOME = lib.mkForce runner.workDirectory;
        NIX_REMOTE = "daemon";
      };
      unitConfig.ConditionPathExists = [
        "/srv/forgejo/.migration-ready"
        runner.tokenFile
        "/var/lib/nix-cache/signing-key"
      ];
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "nix-ci";
        Group = "nix-ci";
        StateDirectory = lib.mkForce runner.stateDirectory;
        StateDirectoryMode = "0700";
        WorkingDirectory = lib.mkForce "-${runner.workDirectory}";
        ExecPaths = lib.mkForce [ "/var/lib/${runner.stateDirectory}" ];
        UMask = "0077";
      };
    }
  ) runners;

  # Workflow authors can sign and publish store outputs, but cannot read the key.
  # nix-ci remains an untrusted Nix daemon user and is not a wheel member.
  security.sudo.extraRules = [
    {
      users = [ "nix-ci" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-cache-publish";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
