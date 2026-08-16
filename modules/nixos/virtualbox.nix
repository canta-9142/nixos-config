{ config, pkgs, ... }:

{
	virtualisation.virtualbox = {
		host.enable = true;
	};

	users = {
		users.jinji.extraGroups = [ "vboxusers" ];
		extraGroups.vboxusers.members = [ "user-with-access-to-vitualbox" ];
	};
}
