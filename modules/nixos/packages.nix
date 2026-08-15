{ config, pkgs, inputs, ... }:

{
	
	nixpkgs.config.allowUnfree = true;
	
	programs.firefox.enable = true;
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
		kitty
		zellij
		yazi
		cava
		clock-rs
		
		usbutils
		nvme-cli
		smartmontools
		parted
		disko

		arduino-ide
		rpi-imager
		python314

		activitywatch
		ookla-speedtest
		
		netcat
		tcpdump
		iw
		wireguard-tools
		wireguard-ui
		remmina
		freerdp
		cloudflared

		nautilus
		thunar
		kdePackages.dolphin
		kdePackages.kio-extras
		kdePackages.kio-fuse
		ark
		file-roller

		flatpak
		flatpak-builder
		wine64
		wineWow64Packages.wayland
		zathura
		chromium
		firefox
		google-chrome
		discord
		concord-tui
		spotify
		spotatui
		slack
		zed
		thunderbird
		kicad
		gimp
		inkscape
		obs-studio
		libreoffice
		hunspell
		hunspellDicts.en_US
		pympress
	];

	services.flatpak = {
		enable = true;
		update.onActivation = true;
		uninstallUnmanaged = true;
		remotes = [{
			name = "flathub";
			location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
		}];
		packages = [
			"com.usebottles.bottles"
			"io.github.shiftey.Desktop"
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
