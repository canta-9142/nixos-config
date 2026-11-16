{ config, pkgs, ... }:

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
      # Exit codes 1–254 skip the unit without marking it failed.
      ExecCondition = "${pkgs.coreutils}/bin/timeout 5s ${pkgs.bash}/bin/bash -c 'exec 3<>/dev/tcp/192.168.190.107/631'";
      TimeoutStartSec = "30s";
    };

    script = ''
      lpadmin -p Brother_MFC_L3780CDW -E \
        -L NVC -m everywhere -o PageSize=A4 \
        -v ipp://192.168.190.107
      lpadmin -d Brother_MFC_L3780CDW
    '';
  };

  systemd.timers.configure-brother-printer = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitInactiveSec = "1min";
      AccuracySec = "1s";
    };
  };
}
