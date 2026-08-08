{ pkgs, ... }:

{
	programs.niri.enable = true;

	programs.niri.package = pkgs.niri-unstable;
	
	security.polkit.enable = true;
	services.gnome.gnome-keyring.enable = true;
	security.pam.services.swaylock = {};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-gtk
			xdg-desktop-portal-gnome
		];

	    config.niri = {
	    	"org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
	    };
	};

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	services.power-profiles-daemon.enable = true;
	services.upower.enable = true;
	services.logind.settings.Login.HandleLidSwitch = "suspend";

	environment.systemPackages = with pkgs; [
		niri
		
		fuzzel
		mako

		swaylock-effects
		swayidle

		wl-clipboard
		wl-mirror
		grim
		slurp
		swappy

		brightnessctl
		playerctl
		pamixer
		pavucontrol

		xwayland-satellite

		gowall
		papirus-icon-theme
		adwaita-icon-theme
		bibata-cursors
		nwg-look
	];
}
