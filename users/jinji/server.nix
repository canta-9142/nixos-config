{
  imports = [ ./nixos.nix ];
  users.users.jinji.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEPtrVcxLNcVNkdjM80No+IjJ9Viijp8O13mopAwaEX jinji@inspiron-5425"
  ];
}
