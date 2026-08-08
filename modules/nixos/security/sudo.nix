{ ... }:

{
  security.sudo.extraRules = [
    {
      users = [ "jinji" ];
      commands = map (command: {
        inherit command;
        options = [ "NOPASSWD" ];
      }) [
        "/run/current-system/sw/bin/wg-quick up wg0"
        "/run/current-system/sw/bin/wg-quick down wg0"
        "/run/current-system/sw/bin/wg"
        "/run/current-system/sw/bin/nixos-rebuild"
        "/run/current-system/sw/bin/nix"
      ];
    }
  ];
}
