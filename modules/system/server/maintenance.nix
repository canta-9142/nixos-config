{
  services = {
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        mail.enable = false;
        wall.enable = false;
        x11.enable = false;
        systembus-notify.enable = false;
      };
    };
    fstrim.enable = true;
    journald.settings.Journal = {
      Storage = "persistent";
      SystemMaxUse = "512M";
      RuntimeMaxUse = "128M";
      MaxRetentionSec = "30day";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "Sun 02:00";
    options = "--delete-older-than 14d";
    persistent = true;
  };
}
