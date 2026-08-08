{ config, pkgs, ... }:

{
	stylix.targets.fish.enable = false;

	programs.fish = {
		enable = true;
		
		shellAliases = {
			fastfetch = ''${pkgs.fastfetch}/bin/fastfetch (test $COLUMNS -le 130; and printf "%s\n" --config "${config.xdg.configHome}/fastfetch/narrow.jsonc")'';
		};

		interactiveShellInit = ''
			set fish_greeting ""
			set -gx NH_FLAKE "/home/jinji/nixos-config#nixos"

			fastfetch;
		'';

		plugins = [
			{
				name = "z";
				src = pkgs.fishPlugins.z.src;
			}
			{
				name = "fzf-fish";
				src = pkgs.fishPlugins.fzf-fish.src;
			}
		];
	};

	programs.oh-my-posh = {
		enable = true;
		enableFishIntegration = true;
		useTheme = "peru";
	};
}
