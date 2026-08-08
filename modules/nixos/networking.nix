{ config, pkgs, ... }:

{
	networking.wireless.enable = true;
	networking.networkmanager.enable = true;

	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

	services.openssh = {
		enable = true;
		settings = {
			PermitRootLogin = "prohibit-password";
			PasswordAuthentication = false;
		};
	};

	networking.firewall = {
		enable = true;
		allowPing = false;
		checkReversePath = "loose";
		allowedTCPPorts = [  ];
		allowedUDPPorts = [ 51820 ];
	};
}
