{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    micro
    git
    gh
    wget
    curl
    btop
    fish
    ripgrep
    tree
    yazi
    mc
    nvme-cli
    nixfmt-tree
    statix
    deadnix
    nixd
    sops
    age
  ];
}
