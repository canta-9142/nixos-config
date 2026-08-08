{ config, pkgs, ... }:

{
	imports = [
		# ../noctalia.nix
		../binds.nix
	];

	#programs.niri.package = inputs.niri.packages.${pkgs.system}.niri;

	programs.niri.settings = {
		input = {
			keyboard.xkb = {
				layout = "us";
			};
			touchpad = {
				tap = true;
				dwt = true;
				natural-scroll = true;
				accel-speed = 0.10;
			};
			mouse = {
			};
		};
		
		outputs = {
			"eDP-1" = {
				mode = { width = 1920; height = 1080; refresh = 48.001; };
				scale = 1.0;
				position = { x = 1920; y = 0; };
			};
			"HDMI-A-1" = {
				scale = 1.0;
				position = { x = 0; y = 0; };
			};
		};

		layout = {		
			gaps = 10;
			
			center-focused-column = "never";

			default-column-width = { proportion = 0.5; };
			preset-column-widths = [
				{ proportion = 1.0 / 3.0; }
				{ proportion = 1.0 / 2.0; }
				{ proportion = 2.0 / 3.0; }
			];
		};

		spawn-at-startup = [
			{ command = [ "noctalia" ]; }
			{ command = [ "mako" ]; }
		];

		hotkey-overlay = {
		};

		screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y%m%d-%H%M%S.png";

		animations = {
		};

		window-rules = [
			{
				geometry-corner-radius = {
					top-left = 12.0;
					top-right = 12.0;
					bottom-left = 12.0;
					bottom-right = 12.0;
				};
				clip-to-geometry = true;
			}
			# Not implemented yet to niri-flake
			#{
			#	matches = [
			#		{ app-id = "com.mitchellh.ghostty"; }
			#	];
			#	background-effects = [
			#		{ blur = true; }
			#		{ xray = true; }
			#	];
			#}
		];
	};
}
