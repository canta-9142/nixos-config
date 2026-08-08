{ config, lib, pkgs, inputs, ... }:

{
	stylix.targets.ghostty.enable = false;

	xdg.configFile."ghostty/transparent.css".text = ''
		window,
		window.background,
		.background {
			background-color: transparent;
		}
	'';

	programs.ghostty = {
		enable = true;
		package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
		enableFishIntegration = true;

		settings = {
			font-family = lib.mkForce [
				"Cascadia Code NF"
				"Noto Sans Mono CJK JP"
				"Noto Color Emoji"
			];
			font-size = 12;
			theme = "Everforest Dark Med";
			cursor-style = "bar";
			background-opacity = 0.7;
			background-opacity-cells = true;
			gtk-custom-css = "${config.xdg.configHome}/ghostty/transparent.css";
			window-decoration = false;
		};
	};
}
