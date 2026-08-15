{ inputs }:

[
  inputs.niri.overlays.niri

  # Compatibility shim until niri-flake stops referring to the removed name.
  (final: prev: {
    libdisplay-info_0_2 = prev.libdisplay-info_0_3.overrideAttrs {
      version = "0.2.0";
      __intentionallyOverridingVersion = true;
    };

    # codex-cli-nix still uses the deprecated stdenv.isLinux alias.
    codex-cli = inputs.codex-cli.packages.${final.stdenv.hostPlatform.system}.default.override {
      stdenv = final.stdenv // {
        isLinux = final.stdenv.hostPlatform.isLinux;
      };
    };

    # GitWand-Nix still uses the deprecated appimageTools.extractType2 alias.
    gitwand = inputs.gitwand.packages.${final.stdenv.hostPlatform.system}.default.override {
      appimageTools = final.appimageTools // {
        extractType2 = final.appimageTools.extract;
      };
    };
  })
]
