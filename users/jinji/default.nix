{ lib, ... }:

{
  imports = [
    ../../modules/home/programs/fish.nix
    ../../modules/home/programs/fastfetch.nix
    ../../modules/home/programs/ghostty.nix
    ../../modules/home/programs/noctalia
    ../../modules/home/desktop/niri
    ../../modules/home/services/activitywatch.nix
    # ../../modules/home/programs/codex.nix
  ];

  home = {
    username = "jinji";
    homeDirectory = "/home/jinji";
    pointerCursor.enable = true;
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  gtk.enable = true;

  xdg.configFile = {
    "gtk-3.0/gtk.css".force = lib.mkForce true;
    "gtk-4.0/gtk.css".force = lib.mkForce true;
    "ghostty/config".force = lib.mkForce true;
  };
}
