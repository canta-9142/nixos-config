# Run with: nix run --impure --file ./tests/discord-mediapipe.nix
let
  flake = builtins.getFlake (toString ../.);
  inherit (flake.nixosConfigurations.nixos) pkgs;
  inherit (pkgs) discord;
in
pkgs.buildFHSEnv (
  discord.args
  // {
    pname = "discord-mediapipe-check";
    executableName = "discord-mediapipe-check";
    meta.mainProgram = "discord-mediapipe-check";
    extraInstallCommands = "";
    runScript = pkgs.writeShellScript "discord-mediapipe-check" ''
      set -eu
      for model in ${discord.unwrappedDiscord}/opt/Discord/modules/discord_voice/*.tflite; do
        # Opening the actual runtime paths with O_RDWR reproduces MediaPipe's access.
        ${pkgs.python3}/bin/python3 -c 'import os, sys; os.close(os.open(sys.argv[1], os.O_RDWR))' "$model"
        echo "O_RDWR OK: ''${model##*/}"
      done
    '';
  }
)
