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
  ];
}
