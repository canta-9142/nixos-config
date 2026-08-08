{ ... }:

{
  programs.fastfetch.enable = true;

  # Replace the pre-existing, unmanaged config on the first activation.
  xdg.configFile = {
    "fastfetch/config.jsonc" = {
      source = ./fastfetch.jsonc;
      force = true;
    };
    "fastfetch/narrow.jsonc".source = ./narrow.jsonc;
  };
}
