{ pkgs, ... }:

{
  security.apparmor = {
    enable = true;
    policies.zathura = {
      state = "enforce";
      # Compile at build time as well as at activation; never load policy here.
      path = pkgs.runCommand "zathura-apparmor" { nativeBuildInputs = [ pkgs.apparmor-parser ]; } ''
        apparmor_parser --skip-kernel-load --skip-cache \
          -I ${pkgs.apparmor-profiles}/etc/apparmor.d ${./zathura.apparmor}
        cp ${./zathura.apparmor} "$out"
      '';
    };
    policies.pympress = {
      state = "enforce";
      path = pkgs.runCommand "pympress-apparmor" { nativeBuildInputs = [ pkgs.apparmor-parser ]; } ''
        apparmor_parser --skip-kernel-load --skip-cache \
          -I ${pkgs.apparmor-profiles}/etc/apparmor.d ${./pympress.apparmor}
        cp ${./pympress.apparmor} "$out"
      '';
    };
  };
}
