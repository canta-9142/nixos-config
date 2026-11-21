{ pkgs, ... }:

{
  imports = [
    ./niri.nix
    ./sddm.nix
    ./input-method.nix
    ./fonts.nix
    ./obs-studio.nix
  ];

  programs.dconf.enable = true;

  hardware.opentabletdriver = {
    enable = true;
    package = pkgs.opentabletdriver.overrideAttrs (old: {
      # Use the patched source for both embedded tablet definitions and udev rules.
      src = pkgs.applyPatches {
        inherit (old) src;
        patches = [
          # WH851 wheel support: https://github.com/OpenTabletDriver/OpenTabletDriver/pull/5198
          (pkgs.fetchurl {
            url = "https://github.com/OpenTabletDriver/OpenTabletDriver/commit/a45a04630c11e7b49e00385e764fd585165691e7.patch";
            hash = "sha256-fZ7gTTaMAsxbIU0t+MdQbeuiVNTW2nOPxpMEnule/48=";
          })
        ];
      };
    });
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
