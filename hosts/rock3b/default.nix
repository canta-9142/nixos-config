_:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ./rock3b.nix

    ./boot.nix
    ./networking.nix
    ../../modules/system/ssh.nix
    ./packages.nix
    ./users.nix

    ../../modules/system/server
  ];

  services.openssh = {
    openFirewall = false;
    settings.PubkeyAuthentication = true;
  };

  networking.hostName = "rock3b-nixos";

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - jinji users - /home/jinji/nixos-config"
  ];

  system.stateVersion = "26.05";

  _module.args.homelab = {
    siteDomain = "floating-gate.com";
    sshDomain = "ssh.floating-gate.com";
    gitDomain = "forgejo.floating-gate.com";
    gitsshDomain = "forgejossh.floating-gate.com";
    siteRoot = "/srv/www/floating-gate";
  };
}
