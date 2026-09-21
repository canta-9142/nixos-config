_:

{
  users.users."jinji" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlm/LW+R2mEGbAFhhdbd3vcAYxgZ/bzswlTTiKb4bmR termux@pixel8a"
    ];
    extraGroups = [
      "networkManager"
      "input"
      "audio"
      "video"
    ];

  };
}
