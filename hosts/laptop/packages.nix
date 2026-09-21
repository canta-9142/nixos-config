{ pkgs, ... }:

{

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    meld

    bubblewrap
    fd
    eza
    bat

    ghostty

    e2fsprogs
    usbutils

    smartmontools

    iw
    wireguard-tools
    wireguard-ui
    cloudflared

    flatpak
    flatpak-builder
    wineWow64Packages.wayland
    zathura
    nautilus
    chromium
    firefox
    google-chrome
    discord
    spotatui
    slack
    thunderbird
    gimp
    inkscape
    kicad
    arduino-ide
    kooha
    pympress
    github-desktop
  ];

  services.flatpak = {
    enable = true;
    update.onActivation = true;
    uninstallUnmanaged = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "org.gitfourchette.gitfourchette"
    ];
  };

  # nix-flatpak accesses Flathub during activation.  On a switch that also
  # restarts NetworkManager, wait until networking (including DNS) is ready.
  systemd.services.flatpak-managed-install = {
    wants = [ "network-online.target" ];
    after = [
      "NetworkManager.service"
      "NetworkManager-wait-online.service"
      "network-online.target"
    ];
  };
}
