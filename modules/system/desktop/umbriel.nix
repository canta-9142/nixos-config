{ inputs, ... }:

{
  imports = [ inputs.umbriel.nixosModules.default ];

  programs.umbriel.enable = true;

  xdg.portal.config.umbriel."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

  # Reuse the existing authentication agent in either compositor session.
  systemd.user.services.niri-flake-polkit.wantedBy = [ "umbriel.service" ];
}
