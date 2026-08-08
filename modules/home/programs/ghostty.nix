{ pkgs, inputs, ... }:

{
	programs.ghostty = {
		enable = true;
		package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
		enableFishIntegration = true;

		settings = {
			font-family = "Cascadia Code NF";
			font-size = 12;
			theme = "Everforest Dark Hard";
			cursor-style = "bar";
			background-opacity = 0.85;
			background-opacity-cells = true;
			window-decoration = false;
		};
	};
}
