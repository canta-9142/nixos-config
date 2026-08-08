{ config, pkgs, ... }:

{
	users.users."jinji" = {
		isNormalUser = true;
		description = "Kanta IMAI";
		extraGroups = [
			"wheel"
			"networkManager"
			"input"
			"audio"
			"video"
		];
		shell = pkgs.fish;
		packages = with pkgs; [
			
		];
	};
}
