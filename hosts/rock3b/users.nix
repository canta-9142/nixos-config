{ pkgs, ... }:

{
  users.users = {
    root = {
      shell = pkgs.fish;
    };
    nixos = {
      isNormalUser = true;
    };
    jinji = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEPtrVcxLNcVNkdjM80No+IjJ9Viijp8O13mopAwaEX"
      ];
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "jinji" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
