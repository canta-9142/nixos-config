{
  inputs,
  self,
  pkgs,
}:
inputs.deploy-rs.lib.${pkgs.stdenv.hostPlatform.system}.deployChecks self.deploy
// {
  deploy-rollback = import ./deploy.nix {
    inherit pkgs;
    deployLib = inputs.deploy-rs.lib.${pkgs.stdenv.hostPlatform.system};
  };
  cubiea5e = import ./cubiea5e.nix {
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
        python ${./fanctl.py} ${../hosts/rock3b/fanctl.sh}
        touch "$out"
      '';
  forgejo = import ./forgejo.nix { inherit pkgs; };
  immich = import ./immich.nix { inherit pkgs; };
  web = import ./web.nix { inherit pkgs; };
  runner = import ./runner.nix { inherit pkgs; };
  nix-cache = import ./nix-cache.nix { inherit pkgs; };
  nix-cache-gc = pkgs.runCommand "nix-cache-gc-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    PYTHONDONTWRITEBYTECODE=1 python ${./nix-cache-gc.py} ${../scripts/nix-cache-gc.py}
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
        python ${./nix-cache-update.py} ${../scripts/update-nix-cache.sh}
        touch "$out"
      '';
}
