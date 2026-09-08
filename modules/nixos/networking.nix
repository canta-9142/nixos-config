_:

{
	networking = {
		wireless.enable = true;
		networkmanager.enable = true;
		firewall = {
			enable = true;
			allowPing = false;
			checkReversePath = "loose";
			allowedTCPPorts = [ 55544 57621 ];
			allowedUDPPorts = [ 67 51820 ];
		};
	};

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

	hardware.wirelessRegulatoryDatabase = true;
	boot.extraModprobeConfig = ''
		options cfg80211 ieee80211_regdom="JP"
	'';
}
