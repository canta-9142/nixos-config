{ config, pkgs, ... }:

{
	services.activitywatch = {
		package = pkgs.activitywatch;
		enable = true;

		settings = {
			port = 5999;
		};

		watchers = {
			
		};
	};
}
