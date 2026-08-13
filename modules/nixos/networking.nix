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
		allowedTCPPorts = [ 55544 ];
		allowedUDPPorts = [ 51820 ];
	};
}
