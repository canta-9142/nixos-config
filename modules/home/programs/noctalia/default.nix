{ inputs, lib, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = lib.mkForce (builtins.fromTOML (builtins.readFile ./settings.toml));
    systemd.enable = true;
  };
}
