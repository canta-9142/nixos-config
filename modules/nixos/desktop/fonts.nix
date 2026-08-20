{ config, pkgs, ... }:

{
    fonts = {
    	fontDir.enable = true;

		packages = with pkgs; [
			noto-fonts
			noto-fonts-cjk-sans
			noto-fonts-cjk-serif
			noto-fonts-color-emoji
			cascadia-code
		];

		fontconfig = {
			enable = true;
			defaultFonts = {
				sansSerif = [ "Noto Sans CJK JP" ];
				serif = [ "Noto Sans CJK JP" ];
				monospace = [
					"Cascadia Code NF"
					"Noto Sans Mono CJK JP"
				];
				emoji = [ "Noto Color Emoji" ];
			};
		};
	};

	services.kmscon = {
		enable = true;
		config = {
			font-engine = "pango";
			font-name = "Cascadia Code NF";
		};
	};
}
