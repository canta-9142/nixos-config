_:

{
  imports = [
    ../../modules/home/programs/git.nix
    ../../modules/home/programs/ssh.nix
    ../../modules/home/programs/fish
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/fastfetch
    ../../modules/home/programs/ghostty.nix
    ../../modules/home/programs/micro.nix
    ../../modules/home/programs/vscode.nix
    ../../modules/home/desktop/gtk.nix
    ../../modules/home/desktop/hyprlock.nix
    ../../modules/home/desktop/mako.nix
    ../../modules/home/desktop/noctalia
    ../../modules/home/desktop/niri
    ../../modules/home/programs/codex
  ];

  home = {
    username = "jinji";
    homeDirectory = "/home/jinji";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
