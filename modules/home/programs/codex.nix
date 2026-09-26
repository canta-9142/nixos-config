{ pkgs, ... }:

{
  systemd.user.services.codex-cleanup = {
    Unit = {
      Description = "Keep the latest two Codex standalone releases";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 ${./codex-cleanup.py}";
    };
  };

  systemd.user.timers.codex-cleanup = {
    Unit.Description = "Clean old Codex standalone releases daily";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
