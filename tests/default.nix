{
  inputs,
  self,
  pkgs,
}:
inputs.deploy-rs.lib.${pkgs.stdenv.hostPlatform.system}.deployChecks self.deploy
// {
  deploy-rollback = import ./vm/deploy.nix {
    inherit pkgs;
    deployLib = inputs.deploy-rs.lib.${pkgs.stdenv.hostPlatform.system};
  };
  cubiea5e = import ./unit/cubiea5e.nix {
    inherit pkgs;
    inherit (self.nixosConfigurations.cubiea5e) config;
  };
  fanctl =
    pkgs.runCommand "fanctl-check"
      {
        nativeBuildInputs = with pkgs; [
          bash
          python3
        ];
      }
      ''
        python ${./unit/fanctl.py} ${../hosts/rock3b/fanctl.sh}
        touch "$out"
      '';
  forgejo = import ./vm/forgejo.nix { inherit pkgs; };
  immich = import ./vm/immich.nix { inherit pkgs; };
  web = import ./vm/web.nix { inherit pkgs; };
  runner = import ./vm/runner.nix { inherit pkgs; };
  nix-cache = import ./vm/nix-cache.nix { inherit pkgs; };
  nix-cache-gc = pkgs.runCommand "nix-cache-gc-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    PYTHONDONTWRITEBYTECODE=1 python ${./unit/nix-cache-gc.py} ${../scripts/nix-cache-gc.py}
    touch "$out"
  '';
  nix-cache-update =
    pkgs.runCommand "nix-cache-update-check"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          gitMinimal
          jq
          python3
        ];
      }
      ''
        python ${./unit/nix-cache-update.py} ${../scripts/update-nix-cache.sh}
        touch "$out"
      '';

  remote-rebuild =
    pkgs.runCommand "remote-rebuild-check"
      {
        nativeBuildInputs = with pkgs; [
          bash
          gitMinimal
          openssh
          rsync
          util-linux
        ];
      }
      ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        bash ${./unit/test_remote_rebuild.sh} ${../modules/system/remote-rebuild/remote-rebuild.sh}
        touch "$out"
      '';
  codex-cleanup = pkgs.runCommand "codex-cleanup-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    PYTHONDONTWRITEBYTECODE=1 python ${./unit/test_codex_cleanup.py} ${../modules/home/programs/codex/cleanup.py}
    touch "$out"
  '';
  kernel-ccache = import ./unit/kernel-ccache.nix {
    inherit pkgs;
    inherit (self.nixosConfigurations.inspiron5425) config;
  };
}
