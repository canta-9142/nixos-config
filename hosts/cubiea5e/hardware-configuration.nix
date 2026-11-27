{
  lib,
  pkgs,
  cubiea5e,
  ...
}:
let
  kernelPkgs = import pkgs.path {
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in
{
  imports = [
    (cubiea5e + "/modules/cubie-a5e.nix")
    (cubiea5e + "/modules/aic8800-sdio.nix")
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

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware = {
    cubie-a5e = {
      enable = true;
      combophy = "pcie";
    };
    # Use wired Ethernet; avoid the out-of-tree WiFi/Bluetooth driver.
    aic8800.enable = lib.mkForce false;
    deviceTree = {
      enable = true;
      name = "allwinner/sun55i-a527-cubie-a5e.dtb";
      filter = "sun55i-a527-cubie-a5e.dtb";
    };
  };

  boot = {
    # Compile the patched ARM kernel on Ryzen without QEMU.
    kernelPackages = kernelPkgs.linuxPackages_latest;
    kernelPatches = lib.mkAfter [
      {
        name = "sunxi-pcie-link-training";
        patch = ./patches/sunxi-pcie-link-training.patch;
      }
    ];
    kernelParams = [
      "earlycon=uart8250,mmio32,0x02500000"
      "console=ttyS0,115200n8"
    ];
    initrd.availableKernelModules = [ "nvme" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    growPartition = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a527a5e0-0000-4000-8000-000000000001";
    fsType = "ext4";
    autoResize = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swap";
      size = 4096;
    }
  ];

  services.fstrim.enable = true;
}
