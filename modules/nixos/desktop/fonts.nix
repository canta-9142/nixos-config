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
			nerd-fonts.caskaydia-cove
		];

		fontconfig = {
			enable = true;
			defaultFonts = {
				sansSerif = [ "Noto Sans CJK JP" ];
				serif = [ "Noto Sans CJK JP" ];
				monospace = [ "Cascadia Code NF" ];
				emoji = [ "Noto Color Emoji" ];
			};
		};
	};
}
