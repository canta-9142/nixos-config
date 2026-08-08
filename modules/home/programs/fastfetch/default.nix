{ ... }:

{
  programs.fastfetch.enable = true;

  # The width-aware fastfetch alias that selects between these configs is
  # defined in ../fish.nix.
  # Replace the pre-existing, unmanaged config on the first activation.
  xdg.configFile = {
    "fastfetch/config.jsonc" = {
      source = ./fastfetch.jsonc;
      force = true;
    };
    "fastfetch/narrow.jsonc".source = ./narrow.jsonc;
  };
}
