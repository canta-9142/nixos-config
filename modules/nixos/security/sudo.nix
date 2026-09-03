{ pkgs, ... }:

let
  env = "${pkgs.coreutils-full}/bin/env";
  envArgs = "^((USER=jinji|NH_[A-Za-z0-9_]+=[^[:space:]]*|NIXOS_INSTALL_BOOTLOADER=1|NIXOS_NO_CHECK=[^[:space:]]*)[[:space:]]+)*";
  system = "/nix/store/[a-z0-9]{32}-nixos-system-[^[:space:]]+";
in

{
  security.sudo.extraRules = [
    {
      users = [ "jinji" ];
      commands =
        map
          (command: {
            inherit command;
            options = [ "NOPASSWD" ];
          })
          [
            "/run/current-system/sw/bin/wg-quick up wg0"
            "/run/current-system/sw/bin/wg-quick down wg0"
            "/run/current-system/sw/bin/wg"
            "/run/current-system/sw/bin/nixos-rebuild"
            "/run/current-system/sw/bin/nix"
            "${env} ${envArgs}${system}/bin/switch-to-configuration (test|boot)$"
            "${env} ${envArgs}nix build --no-link --profile /nix/var/nix/profiles/system ${system}$"
            "${env} ${envArgs}ln -sfn /nix/var/nix/profiles/system-[0-9]+-link /nix/var/nix/profiles/system$"
          ];
    }
  ];
}
