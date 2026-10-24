{ pkgs, ... }:

{
  users.users.jinji = {
    isNormalUser = true;
    description = "Kanta IMAI";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkManager"
      "input"
      "audio"
      "video"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlm/LW+R2mEGbAFhhdbd3vcAYxgZ/bzswlTTiKb4bmR termux@pixel8a"
    ];
  };

  home-manager.users.jinji = import ./home.nix;

  sops = {
    defaultSopsFile = ../../secrets/ssh.yaml;
    age = {
      keyFile = "/home/jinji/.config/sops/age/keys.txt";
      generateKey = false;
    };
    secrets.ssh_private_key = {
      owner = "jinji";
      mode = "0400";
    };
  };

  environment.variables.SOPS_AGE_KEY_FILE = "/home/jinji/.config/sops/age/keys.txt";
}
