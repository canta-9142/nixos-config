_: {
  imports = [ ../ssh.nix ];

  services.openssh = {
    openFirewall = false;
    settings = {
      AllowUsers = [
        "rock"
      ];
    };
  };
  networking = {
    nftables.enable = true;
    firewall.extraInputRules = ''
      ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.96.0.0/12 } tcp dport 22 accept
      ip6 saddr { fc00::/7, fe80::/10 } tcp dport 22 accept
    '';
  };
}
