{ inputs, config, pkgs, lib, ... }:

{
	boot.loader = {
		timeout = 10;

		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot";
		};

		systemd-boot = {
			enable = true;
			configurationLimit = 30;
		};
		
		#grub = {
		#	enable = true;
		#	efiSupport = true;
		#	devices = [ "nodev" ];
		#	useOSProber = true;
		#	configurationLimit = 5;
		#	extraEntriesBeforeNixOS = false;
		#	extraEntries = ''
		#		menuentry "Reboot" {
		#			reboot
		#		}
		#		menuentry "Poweroff" {
		#			halt
		#		}
		#	'';
		#	theme = lib.mkForce inputs.nixos-grub-themes.packages.${pkgs.system}.hyperfluent;
		#};
	};
	
	nix.gc = {
	  	automatic = true;
	  	dates = "daily";
	  	options = "--delete-older-than 5d";
	};
}
