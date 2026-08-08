{ config, pkgs, ... }:

let
    custom-sddm-astronaut = pkgs.sddm-astronaut.override {
        themeConfig = {
            Background = toString ../../../assets/nix-catppuccin-latte.png;
            Blur = 0.4;
            ParticalBlur = true;
            Font = "Noto Sans CJK JP";
        };
    };

in {
	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
		extraPackages = with pkgs; [
			custom-sddm-astronaut
			kdePackages.qtmultimedia
		];

		theme = "${custom-sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
		settings = {
			Theme = {
				Current = "sddm-astronaut-theme";
			};
		};
	};

	environment.systemPackages = with pkgs; [
		custom-sddm-astronaut
		kdePackages.qtmultimedia
	];
}
