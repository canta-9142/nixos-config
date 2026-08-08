{
  programs.fastfetch = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./fastfetch.jsonc);
  };

  # Replace the pre-existing, unmanaged config on the first activation.
  xdg.configFile."fastfetch/config.jsonc".force = true;
}
