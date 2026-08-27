{
  nix = {
    settings = {
      auto-optimise-store = true;
      keep-derivations = false;
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
  };

  systemd.tmpfiles.rules = [
    "R! /tmp/nh-* - - - -"
  ];
}
