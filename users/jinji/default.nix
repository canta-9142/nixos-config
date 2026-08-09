{ lib, ... }:

{
  imports = [
    ../../modules/home/programs/git.nix
    ../../modules/home/programs/ssh.nix
    ../../modules/home/programs/fish
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/fastfetch
    ../../modules/home/programs/ghostty.nix
    ../../modules/home/programs/noctalia
    ../../modules/home/programs/vscode.nix
    ../../modules/home/desktop/niri
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
