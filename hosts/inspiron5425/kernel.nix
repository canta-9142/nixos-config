{ pkgs, ... }:
{
  boot = {
    # The remote builder must expose this persistent cache in its sandbox.
    kernelPackages = pkgs.linuxPackages_latest.extend (
      _final: prev: {
        kernel =
          (prev.kernel.override {
            stdenv = pkgs.ccacheStdenv.override {
              extraConfig = ''
                export CCACHE_DIR=/srv/kernel/ccache
                export CCACHE_MAXSIZE=50G
                export CCACHE_COMPRESS=1
                export CCACHE_UMASK=007
                # Match nixpkgs' ccache wrapper policy across derivation changes.
                export CCACHE_SLOPPINESS=random_seed
              '';
            };
          }).overrideAttrs
            (old: {
              # Keep compiler source/include paths independent of the output hash.
              preConfigure = (old.preConfigure or "") + ''
                ln -s "$PWD" "$NIX_BUILD_TOP/kernel-source"
              '';
              makeFlags = (old.makeFlags or [ ]) ++ [
                "srcroot=$(NIX_BUILD_TOP)/kernel-source"
              ];
            });
      }
    );

    kernelPatches = [
      {
        name = "kconfig-stable-autoconf-comment";
        patch = ./kconfig-stable-autoconf-comment.patch;
      }
      {
        name = "iwlwifi-ax210-6ghz-diagnostic";
        patch = ./iwlwifi-ax210-6ghz-diagnostic.patch;
      }
    ];

  };
}
