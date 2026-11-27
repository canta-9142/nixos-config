{ pkgs, ... }:
{
  users.users.jinji = {
    isNormalUser = true;
    description = "Kanta Imai";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlm/LW+R2mEGbAFhhdbd3vcAYxgZ/bzswlTTiKb4bmR termux@pixel8a"
    ];
  };
}
