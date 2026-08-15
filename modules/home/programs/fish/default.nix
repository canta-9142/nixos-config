{ config, pkgs, ... }:

{
	programs.fish = {
		enable = true;
		
		shellAliases = {
			fastfetch = ''${pkgs.fastfetch}/bin/fastfetch (test $COLUMNS -le 130; and printf "%s\n" --config "${config.xdg.configHome}/fastfetch/narrow.jsonc")'';
		};
		
		shellAbbrs = {
			no = "nh os switch";
			nou = "nh os switch --update";
			mi = "micro";
			".." = "cd ..";
			"..." = "cd ../..";
			"...." = "cd ../../..";
			g = "git";
			ga = "git add";
			gaa = "git add .";
			gb = "git branch --all";
			gbd = "git branch -d";
			gc = "git commit";
			gca = "git commit -a";
			gcm = "git commit -m";
			gcam = "git commit -a -m";
			gco = "git checkout";
			gd = "git diff";
			gf = "git fetch";
			gl = "git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822";
			gpl = "git pull";
			gp = "git push";
			gs = "git status";
			gst = "git stash";
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
		configFile = ./config.omp.json;
	};
}
