{ config, ... }:

{
  services = {
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # IPP Everywhere probes the printer; an offline device must not stop CUPS.
  systemd.services.configure-brother-printer = {
    description = "Configure the Brother MFC-L3780CDW printer";
    wantedBy = [ "multi-user.target" ];
    wants = [ "cups.service" ];
    after = [ "cups.service" ];
    path = [ config.services.printing.package ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "1min";
      TimeoutStartSec = "30s";
    };

    script = ''
      lpadmin -p Brother_MFC_L3780CDW -E \
        -L NVC -m everywhere -o PageSize=A4 \
        -v ipp://192.168.190.107
      lpadmin -d Brother_MFC_L3780CDW
    '';
  };
}
