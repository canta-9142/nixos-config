{ config, pkgs, ... }:

{
	i18n.inputMethod = {
		enable = true;
		type = "fcitx5";
		fcitx5 = {
			waylandFrontend = true;
			addons = with pkgs; [
				fcitx5-mozc
				fcitx5-gtk
			];
			settings.inputMethod = {
				GroupOrder = {
					"0" = "Default";
				};
				"Groups/0" = {
					Name = "Default";
					"Default Layout" = "us";
					DefaultIM = "mozc";
				};
				"Groups/0/Items/0" = {
					Name = "keyboard-us";
					Layout = "";
				};
				"Groups/0/Items/1" = {
					Name = "mozc";
					Layout = "";
				};
			};
		};
	};
	services.xserver.desktopManager.runXdgAutostartIfNone = true;
	systemd.services.fcitx5-restart-after-resume = {
		description = "Restart Fcitx5 after suspend resume";
		wantedBy = [ "sleep.target" ];
		before = [ "sleep.target" ];
		unitConfig = {
			DefaultDependencies = false;
			StopWhenUnneeded = true;
		};
		script = "true";
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			User = "jinji";
			ExecStop = pkgs.writeShellScript "fcitx5-restart-after-resume" ''
				uid="$(${pkgs.coreutils}/bin/id -u)"
				export XDG_RUNTIME_DIR="/run/user/$uid"
				export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
				${pkgs.fcitx5}/bin/fcitx5-remote -r
			'';
		};
	};
}
