{ config, pkgs, inputs, ... }:

{
	stylix = {
		enable = true;
		
		image = ../../../assets/wallpapers/img-2026-04-06_17-14-21.png.jpg;

		polarity = "dark";

		base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

		fonts = {
			serif = {
				package = pkgs.noto-fonts-cjk-serif;
				name = "Noto Serif CJK JP";
			};
			sansSerif = {
				package = pkgs.noto-fonts-cjk-sans;
				name = "Noto Sans CJK JP";
			};
			monospace = {
				package = pkgs.cascadia-code;
				name = "Cascadia Code NF";
			};
			emoji = {
				package = pkgs.noto-fonts-color-emoji;
				name = "Noto Color Emoji";
			};
		};

		cursor = {
			package = pkgs.bibata-cursors;
			name = "Bibata-Modern-Ice";
			size = 24;
		};

		targets = {
			fish.enable = false;
			gtk.enable = true;
		};
	};
}
