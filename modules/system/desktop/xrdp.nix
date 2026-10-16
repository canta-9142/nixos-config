{ config, pkgs, ... }:

{
  services = {
    xserver.desktopManager.xfce.enable = true;
    xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = ${pkgs.xfce4-14.xfce4-session}/bin/xfce4-session;
    };
  };
}
