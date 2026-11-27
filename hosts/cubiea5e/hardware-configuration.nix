{
  lib,
  cubiea5e,
  ...
}:
{
  imports = [
    (cubiea5e + "/modules/cubie-a5e.nix")
    (cubiea5e + "/modules/aic8800-sdio.nix")
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
