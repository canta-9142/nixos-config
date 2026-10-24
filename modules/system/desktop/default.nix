{ ... }:

{
  imports = [
    ./niri.nix
    ./sddm.nix
    ./input-method.nix
    ./fonts.nix
  ];

  programs.dconf.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
