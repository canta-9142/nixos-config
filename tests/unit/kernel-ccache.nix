{ pkgs, config }:
let
  cross = pkgs.pkgsCross.aarch64-multiplatform;
in
pkgs.stdenv.mkDerivation {
  name = "kernel-ccache-check";
  inherit (config.boot.kernelPackages.kernel) src;
  patches = [ ../../lib/kernel-ccache/kconfig-stable-autoconf-comment.patch ];
  nativeBuildInputs = with pkgs; [
    python3
    ccache
    flex
    bison
  ];
  phases = [
    "unpackPhase"
    "patchPhase"
    "buildPhase"
  ];
  buildPhase = ''
    make -j"$NIX_BUILD_CORES" defconfig
    python ${./test_kconfig_autoconf.py} "$PWD/scripts/kconfig/conf" gcc
    python ${./test_kconfig_autoconf.py} "$PWD/scripts/kconfig/conf" \
      ${cross.stdenv.cc}/bin/${cross.stdenv.cc.targetPrefix}gcc
    touch "$out"
  '';
}
