{ pkgs, ... }:

{
	programs.fish = {
		enable = true;

		interactiveShellInit = ''
			set fish_greeting ""
			set -gx NH_FLAKE "/home/jinji/nixos-config#nixos"

			${pkgs.fastfetch}/bin/fastfetch
		'';

		shellAliases = {
			
		};

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
}
