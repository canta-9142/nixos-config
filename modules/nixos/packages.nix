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
    fresh-editor
    git
    meld
    gh
    wget
    curl
    zip
    unzip
    btop
    htop
    bottom
    fish
    pfetch-rs
    fetch
    ripgrep
    bubblewrap
    fd
    eza
    bat
    tree
    ghostty
    zellij
    yazi
    cava
    clock-rs

    usbutils
    nvme-cli
    smartmontools
    disko

    ookla-speedtest

    netcat
    tcpdump
    iw
    wireguard-tools
    wireguard-ui
    remmina
    freerdp
    cloudflared

    flatpak
    flatpak-builder
    wine64
    wineWow64Packages.wayland
    zathura
    nautilus
    chromium
    firefox
    google-chrome
    discord
    concord-tui
    spotify
    spotatui
    slack
    thunderbird
    gimp
    inkscape
    kicad
    obs-studio
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
