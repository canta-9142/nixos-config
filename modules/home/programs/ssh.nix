_:

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

      "*.home.arpa" = {
        User = "jinji";
        IdentityFile = "/run/secrets/ssh_private_key";
        IdentitiesOnly = true;
      };

      "*" = {
        SetEnv = {
          TERM = "xterm-256color";
        };
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
    };
  };
}
