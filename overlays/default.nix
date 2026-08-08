{ inputs }:

[
  inputs.niri.overlays.niri

  # Compatibility shim until niri-flake stops referring to the removed name.
  (final: prev: {
    libdisplay-info_0_2 = prev.libdisplay-info_0_3.overrideAttrs {
      version = "0.2.0";
      __intentionallyOverridingVersion = true;
    };
  })
]
