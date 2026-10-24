{ pkgs, ... }:

let
  nh = pkgs.symlinkJoin {
    name = "nh-${pkgs.nh.version}";
    paths = [ pkgs.nh ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nh --set NH_PRESERVE_ENV 0
    '';
  };
in
{
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  environment.systemPackages = [ nh ];
}
