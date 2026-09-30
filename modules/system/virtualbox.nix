_:

{
  virtualisation.virtualbox = {
    host.enable = true;
  };

  systemd.services.network-addresses-vboxnet0 = {
    requires = [ "vboxnet0.service" ];
    after = [ "vboxnet0.service" ];
  };

  users = {
    users.jinji.extraGroups = [ "vboxusers" ];
    extraGroups.vboxusers.members = [ "user-with-access-to-vitualbox" ];
  };
}
