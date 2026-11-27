{ lib, pkgs, ... }:
let
  kernelPkgs = import pkgs.path {
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in
{
  imports = [
    {
      options.boot.kernelPatches = lib.mkOption {
        apply =
          patches:
          map (
            patch:
            if
              (patch.name or "") == "a523-cpu-ccu-driver"
              && lib.versionAtLeast kernelPkgs.linuxPackages_latest.kernel.version "7.3"
            then
              patch
              // {
                # Linux 7.3 uses bit 12 for IOSC calibration. Rebase the CPU
                # patch's header context and give its private flag bit 13.
                patch = builtins.toFile "a523-cpu-ccu-driver-7.3.patch" (
                  builtins.replaceStrings
                    [
                      "@@ -21,6 +21,10 @@"
                      " #define CCU_FEATURE_UPDATE_BIT\t\tBIT(11)\n"
                      "+#define CCU_FEATURE_CLEAR_MOD\t\tBIT(12)"
                    ]
                    [
                      "@@ -21,7 +21,11 @@"
                      " #define CCU_FEATURE_UPDATE_BIT\t\tBIT(11)\n #define CCU_FEATURE_IOSC_CALIBRATION\tBIT(12)\n"
                      "+#define CCU_FEATURE_CLEAR_MOD\t\tBIT(13)"
                    ]
                    (builtins.readFile patch.patch)
                );
              }
            else
              patch
          ) patches;
      };
    }
  ];
  boot = {
    # Compile the patched ARM kernel on Ryzen without QEMU.
    kernelPackages = import ../../lib/kernel-ccache {
      pkgs = kernelPkgs;
      kernelPackages = kernelPkgs.linuxPackages_latest;
    };
    kernelPatches = lib.mkAfter [
      {
        name = "sunxi-pcie-link-training";
        patch = ./patches/sunxi-pcie-link-training.patch;
      }
    ];
  };
}
