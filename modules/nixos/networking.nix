{ config, pkgs, ... }:

{
	networking.wireless.enable = true;
	networking.networkmanager.enable = true;

	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

	services.openssh = {
		enable = true;
		openFirewall = true;
		settings = {
			AllowUsers = [ "jinji" ];
			KbdInteractiveAuthentication = false;
			PasswordAuthentication = false;
			PermitRootLogin = "no";
		};
	};

	networking.firewall = {
		enable = true;
		allowPing = false;
		checkReversePath = "loose";
		allowedTCPPorts = [ 55544 57621 ];
		allowedUDPPorts = [ 67 51820 ];
	};
}
