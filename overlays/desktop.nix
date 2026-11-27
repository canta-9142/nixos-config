{ inputs }:

[
  inputs.niri.overlays.niri
  inputs.nix-meltype.overlays.default

  # Compatibility shim until niri-flake stops referring to the removed name.
  (final: prev: {
    libdisplay-info_0_2 = prev.libdisplay-info_0_3.overrideAttrs {
      version = "0.2.0";
      __intentionallyOverridingVersion = true;
    };

    # GitWand-Nix still uses the deprecated appimageTools.extractType2 alias.
    gitwand = inputs.gitwand.packages.${final.stdenv.hostPlatform.system}.default.override {
      appimageTools = final.appimageTools // {
        extractType2 = final.appimageTools.extract;
      };
    };

    # sops-nix still uses buildGo125Module which was removed in nixpkgs.
    buildGo125Module = final.buildGoModule;

    # MediaPipe opens background models with O_RDWR, which fails in the Nix store.
    # https://github.com/NixOS/nixpkgs/issues/543857
    discord = prev.discord.override {
      buildFHSEnv =
        args:
        final.buildFHSEnv (
          args
          // {
            extraPreBwrapCmds = (args.extraPreBwrapCmds or "") + ''
              discord_models="''${XDG_CACHE_HOME:-$HOME/.cache}/discord/mediapipe/${args.version}"
              ${final.coreutils}/bin/mkdir -p "$discord_models" || exit 1
              discord_model_mounts=()
              for model in ${args.passthru.unwrappedDiscord}/opt/Discord/modules/discord_voice/*.tflite; do
                writable_model="$discord_models/''${model##*/}"
                ${final.coreutils}/bin/install -m 600 "$model" "$writable_model" || exit 1
                discord_model_mounts+=(--bind "$writable_model" "$model")
              done
            '';
            # Keep module realpaths intact for Discord's native module boundary check.
            extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ ''"''${discord_model_mounts[@]}"'' ];
          }
        );
    };
  })
]
