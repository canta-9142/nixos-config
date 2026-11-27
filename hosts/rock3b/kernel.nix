{ pkgs, ... }:
let
  kernelPkgs = import pkgs.path {
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in
{
  boot = {
    # Compile the patched ARM kernel on Ryzen without QEMU.
    kernelPackages = import ../../lib/kernel-ccache {
      pkgs = kernelPkgs;
      kernelPackages = kernelPkgs.linuxPackages_latest;
    };
    # Remove once upstream checks link state before Root Port recovery.
    kernelPatches = [
      {
        name = "rk3568-pcie-reset-loop";
        patch = pkgs.fetchurl {
          name = "rk3568-pcie-reset-loop.patch";
          url = "https://raw.githubusercontent.com/armbian/build/15a308c95033b06a87b0d99bfd4a3bd6538c7394/patch/kernel/archive/rockchip64-7.3/rk3568-pcie-dw-rockchip-fix-linkdown-reset-loop.patch";
          hash = "sha256-bK4So7teZCdk0BtdlPm2YlsiqsMZi5VzyGvA7m/gnOA=";
        };
      }
    ];
  };
}
