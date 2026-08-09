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

		gcc
		arduino-ide
		rpi-imager
		python314
		go
		rustc
		cargo
		rustfmt
		clippy
		wasm-pack
		jq
		nodejs
		pnpm
		typescript
		tailwindcss
		mermaid-cli
		playwright
		playwright-driver.browsers

		activitywatch
		ookla-speedtest
		
		netcat
		tcpdump
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
		slack
		vscode
		zed
		thunderbird
		kicad
		gimp
		inkscape
		obs-studio
		zoom-us
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
}
