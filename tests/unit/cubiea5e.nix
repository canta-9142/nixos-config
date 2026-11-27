{ pkgs, config }:
let
  kernel = config.boot.kernelPackages.kernel;
  spiOverlay = (builtins.head config.hardware.deviceTree.overlays).dtsFile;
in
assert kernel.stdenv.buildPlatform.system == "x86_64-linux";
assert kernel.stdenv.hostPlatform.system == "aarch64-linux";
assert kernel.configfile.system == "x86_64-linux";
assert config.nix.package.system == "aarch64-linux";
assert config.boot.initrd.network.ssh.port == 2222;
assert config.boot.initrd.network.ssh.hostKeys == [ ];
assert builtins.elem "systemd-udev-trigger.service"
  config.boot.initrd.systemd.services.initrd-pcie-gen1.before;
assert builtins.elem "systemd-modules-load.service"
  config.boot.initrd.systemd.services.initrd-pcie-gen1.before;
assert
  config.boot.initrd.network.ssh.authorizedKeys
  == config.users.users.jinji.openssh.authorizedKeys.keys;
pkgs.stdenv.mkDerivation {
  name = "cubiea5e-kernel-dtb-check";
  inherit (kernel) src patches;
  nativeBuildInputs = [ pkgs.dtc ];
  phases = [
    "unpackPhase"
    "patchPhase"
    "buildPhase"
  ];
  buildPhase = ''
    # CPU CCU backport flags must not alias a feature added upstream.
    awk '$1 == "#define" && $2 ~ /^CCU_FEATURE_/ { if (seen[$3]++) exit 1 }' \
      drivers/clk/sunxi-ng/ccu_common.h

    cpp -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
      -I scripts/dtc/include-prefixes \
      arch/arm64/boot/dts/allwinner/sun55i-a527-cubie-a5e.dts > board.dts
    dtc -q -@ -I dts -O dtb -o board.dtb board.dts
    dtc -q -@ -I dts -O dtb -o spi.dtbo ${spiOverlay}
    fdtoverlay -i board.dtb -o configured.dtb spi.dtbo

    test "$(fdtget configured.dtb /soc/pcie@4800000 status)" = okay
    test "$(fdtget configured.dtb /soc/phy@4f00000 phy_use_sel)" = 0
    test "$(fdtget configured.dtb /soc/spi@4025000/flash@0 compatible)" = jedec,spi-nor
    bash ${./cubiea5e-pcie-watch.sh} ${../../hosts/cubiea5e/initrd-pcie-watch.sh}
    bash ${./cubiea5e-pcie-gen1.sh} ${../../hosts/cubiea5e/initrd-pcie-gen1.sh}
    touch "$out"
  '';
}
