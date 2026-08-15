{ config, pkgs, ... }:

{
	systemd.user.services.codex-remote = {
		Unit = {
			Description = "Codex CLI Remote Control Daemon";
			After = [ "network.target" ];
		};
		Service = {
			ExecStart = "${pkgs.codex-cli}/bin/codex remote-control start";
			Restart = "on-failure";
		};
		Install = {
			WantedBy = [ "default.target" ];
		};
	};
}
