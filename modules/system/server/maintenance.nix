_:

{
  nix.gc = {
    automatic = true;
    dates = "Sun 04:00";
    options = "--delete-older-than 14d";
  };

  services.journald.settings.Journal = {
    SystemMaxUse = "512M";
    RuntimeMaxUse = "128M";
    MaxRetentionSec = "14day";
  };
}
