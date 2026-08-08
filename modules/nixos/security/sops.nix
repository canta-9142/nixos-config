{ config, lib, pkgs, ... }:

let
	ageKeyFile = "/home/jinji/key.txt";
in
{
	sops = {
		age.keyFile = ageKeyFile;
		age.generateKey = true;
	};
	environment.variables = {
		SOPS_AGE_KEY_FILE = ageKeyFile;
	};
}
