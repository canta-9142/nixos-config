{ ... }:

{
	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;

		settings = {
			"github.com" = {
				Hostname = "github.com";
				User = "git";
				IdentityFile = "/run/secrets/ssh_private_key";
				IdentitiesOnly = true;
			};

			"ssh.floating-gate.com" = {
				Hostname = "ssh.floating-gate.com";
				User = "jinji";
				SetEnv = {
					TERM = "xterm-256color";
				};
				ProxyCommand = "cloudflared access ssh --hostname ssh.floating-gate.com";
				IdentityFile = "/run/secrets/ssh_private_key";
				IdentitiesOnly = true;
			};

			"forgejossh.floating-gate.com" = {
				Hostname = "forgejossh.floating-gate.com";
				User = "git";
				ProxyCommand = "cloudflared access ssh --hostname forgejossh.floating-gate.com";
				IdentityFile = "/run/secrets/ssh_private_key";
				IdentitiesOnly = true;
			};

			"*" = {
				ServerAliveInterval = 60;
				ServerAliveCountMax = 3;
			};
		};
	};
}
