_: {
  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = [ "jinji" ];
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
