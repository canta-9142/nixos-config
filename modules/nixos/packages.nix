{ pkgs, ... }:

let
  nh = pkgs.symlinkJoin {
    name = "nh-${pkgs.nh.version}";
    paths = [ pkgs.nh ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nh --set NH_PRESERVE_ENV 0
    '';
  };
in

{

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    nh
    micro
    git
    gh
    meld
    wget
    curl
    btop
    fish
    ripgrep
    bubblewrap
    fd
    eza
    bat
    tree
    ghostty
    yazi

    e2fsprogs
    usbutils
    nvme-cli
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
      "com.usebottles.bottles"
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
