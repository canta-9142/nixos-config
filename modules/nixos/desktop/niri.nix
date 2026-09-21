{ pkgs, ... }:

{
  programs.niri.enable = true;

  programs.niri.package = pkgs.niri-unstable;

  security.polkit.enable = true;
  services = {
    gnome.gnome-keyring.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    logind.settings.Login.HandleLidSwitch = "suspend";
  };
  security.pam.services.hyprlock = { };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    niri

    fuzzel

    swayidle

    wl-clipboard
    wl-mirror
    grim
    slurp
    swappy

    brightnessctl
    playerctl
    pamixer
    pavucontrol

    xwayland-satellite

    gowall
    papirus-icon-theme
    adwaita-icon-theme
    bibata-cursors
    nwg-look
  ];
}
