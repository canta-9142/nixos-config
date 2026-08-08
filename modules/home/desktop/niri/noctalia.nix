{ config, ... }:

{
	programs.niri.settings = {
		layout = {
			focus-ring = {
				active = "#ffb599";
				inactive = "#131313";
				urgent = "#ffb4ab";
			};

			border = {
				active = "#ffb599";
				inactive = "#131313";
			};

			shadow = {
				color = "#00000070";
			};

			tab-indicator = {
				active = "#ffb599";
				inactive = "#7b2f0a";
				urgent = "#ffb4ab";
			};
		};
	};
}
