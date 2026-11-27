{ pkgs, ... }:
{
  boot = {
    # The remote builder must expose this persistent cache in its sandbox.
    kernelPackages = import ../../lib/kernel-ccache {
      inherit pkgs;
      kernelPackages = pkgs.linuxPackages_latest;
    };

    kernelPatches = [
      {
        name = "iwlwifi-ax210-6ghz-diagnostic";
        patch = ./iwlwifi-ax210-6ghz-diagnostic.patch;
      }
    ];

  };
}
