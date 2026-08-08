{ config, lib, pkgs, ... }:

{
	sops = {
		defaultSopsFile = ../../../secrets/ssh.yaml;
		
		age = {
			keyFile = "/home/jinji/.config/sops/age/keys.txt";
			generateKey = false;
		};

		secrets.ssh_private_key = {
			owner = "jinji";
			mode = "0400";
		};
	};
	
	environment.variables.SOPS_AGE_KEY_FILE = "/home/jinji/.config/sops/age/keys.txt";
}
