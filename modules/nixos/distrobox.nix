{ config, pkgs, ... }:

{
	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};

	enviromnent.systemPackages = [ pkgs.distrobox ];
}
