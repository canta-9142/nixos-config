_:

{
  programs.fastfetch.enable = true;

  # The terminal- and width-aware fastfetch function is defined in
  # ../fish/default.nix.
  # Replace the pre-existing, unmanaged config on the first activation.
  xdg.configFile = {
    "fastfetch/config.jsonc" = {
      source = ./fastfetch.jsonc;
      force = true;
    };
    "fastfetch/narrow.jsonc".source = ./narrow.jsonc;
    "fastfetch/nixos-logo2.png".source = ../../../../assets/images/nixos-logo2.png;
  };
}
