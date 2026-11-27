{ pkgs, ... }:
{
  systemd = {
    services = {
      mdmonitor.wantedBy = [ "multi-user.target" ];
      ryzen-storage-health = {
        description = "Check Ryzen MD RAID health (journal only)";
        after = [ "local-fs.target" ];
        serviceConfig.Type = "oneshot";
        path = with pkgs; [
          mdadm
          coreutils
        ];
        script = builtins.readFile ./storage-health.sh;
      };
      ryzen-raid-check = {
        description = "Check Ryzen RAID consistency without requesting repair";
        after = [ "local-fs.target" ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "infinity";
        };
        path = with pkgs; [
          mdadm
          coreutils
        ];
        script = builtins.readFile ./raid-check.sh;
      };
    };
    timers = {
      ryzen-storage-health = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "5min";
        };
      };
      ryzen-raid-check = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
  };

}
