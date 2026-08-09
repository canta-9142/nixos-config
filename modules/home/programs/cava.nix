{ ... }:

{
	programs.cava = {
		enable = true;
		settings = {
			general = {
				framerate = 60;
				bars = 20;
			};
			input = {
				method = "pipewire";
				source = "auto";
			};
		};
	};
}
