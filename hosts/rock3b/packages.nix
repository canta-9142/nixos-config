{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    vim

    fastfetch
    fetch

    htop

    zellij

    dnsutils
  ];

  programs.firefox.enable = true;
}
