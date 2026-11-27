{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    micro
    git
    gh
    btop
    tree
    nvme-cli
  ];
}
