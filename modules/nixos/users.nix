{ config, pkgs, ... }:

{
	users.users."jinji" = {
		isNormalUser = true;
		description = "Kanta IMAI";
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlm/LW+R2mEGbAFhhdbd3vcAYxgZ/bzswlTTiKb4bmR termux@pixel8a"
		];
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
