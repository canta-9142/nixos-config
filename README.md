# nixos-config
NixOS and Home Manager configuration for the `nixos` laptop.
The ROCK 3B configuration is maintained separately in `servers-config`.

## Desktop

![Desktop image](./assets/images/desktop-rice.png)

## Layout

```plain
hosts/
  laptop/                 # nixos (x86_64-linux): boot, disk, network and packages
    nix.nix               # remote builder, binary cache and garbage collection
    locale.nix            # locale and timezone
    services.nix          # device and firmware services
modules/
  system/
    cli.nix               # shared command-line tools
    nix.nix               # Nix implementation, Flakes and nh
    fish.nix              # system Fish configuration
    remote-rebuild/       # remote rebuild command and its test
    ssh.nix               # SSH authentication policy
    desktop/              # system desktop modules
    security/             # reusable security modules
  home/
    programs/             # application configuration; related assets stay nearby
    desktop/              # desktop configuration, including Noctalia
users/jinji/
  nixos.nix               # NixOS account, secrets and Home Manager wiring
  home.nix                # Home Manager entry point
overlays/                 # laptop package overlays
assets/                   # wallpapers and images
secrets/                  # sops-encrypted secrets
```

Directory names do not change hostnames or flake selectors: use `.#nixos`
for the laptop.

Validation:

```console
nix fmt
nix develop -c statix check .
nix develop -c deadnix --fail .
nix flake check
```

## Remote evaluation and builds

In Fish, `nsr` and `nbr` sync `~/nixos-config` to
`~/.cache/nixos-remote-rebuild/laptop/source` on `jinji@ryzen.home.arpa`,
evaluate and build `nixosConfigurations.nixos` there, and copy the result back
before running `nh os switch` or `nh os boot` locally. The remote source and
latest build result are retained, so subsequent runs use incremental rsync
transfers. Tracked changes and new non-ignored files are included; deleted and
newly ignored files are removed from the mirror. Local calls are serialized to
keep synchronization and evaluation from overlapping. Local temporary snapshots
use hard links where possible and are removed on exit. A failed build or
transfer stops deployment.
Unsigned build outputs are accepted only for the direct transfer from this
SSH host, whose key is pinned in the laptop configuration.

Additional arguments, such as `nsr --ask`, are passed to the local `nh` command.
`ns` and `nb` preserve the previous `nh os switch` and `nh os boot`
abbreviations. After activating this configuration, start a new Fish shell.

## Secure Boot (Lanzaboote)

Lanzaboote signs boot images using keys in `/var/lib/sbctl` and keeps up to
30 generations. Keys must exist before installing the boot configuration;
building the configuration alone does not require them. The old systemd-boot
entry timestamp customization does not apply to Lanzaboote's signed images.

Initial setup (these commands change the machine and must be run manually):

1. Keep Secure Boot disabled initially. Prepare a recovery USB and back up the
   EFI partition. Check Secure Boot support for any other installed OS; this
   machine also has Windows, Fedora, and GhostBSD firmware entries. If Windows
   uses BitLocker, have its recovery key available before changing firmware keys.
2. Create signing keys, unless already present:

   ```console
   nix shell nixpkgs#sbctl -c sudo sbctl create-keys
   ```

   Keep an encrypted backup of `/var/lib/sbctl` outside this repository. Never
   copy private keys into the repository or the Nix store.
3. Install the boot configuration, then inspect signatures:

   ```console
   sudo nixos-rebuild boot --flake .#nixos
   nix shell nixpkgs#sbctl -c sudo sbctl verify
   ```

   Confirm the systemd-boot EFI binary and Lanzaboote generation EFI images are
   signed. Separate kernel payloads may be reported unsigned; see the upstream
   guide below. Reboot and confirm NixOS starts with Secure Boot still disabled.
4. Following the firmware's documentation, enter Secure Boot Setup Mode while
   retaining the forbidden-signature database (`dbx`). Do not blindly clear all
   keys. Boot NixOS and confirm Setup Mode with `sudo sbctl status`, then enroll:

   ```console
   sudo sbctl enroll-keys --microsoft --firmware-builtin
   ```

   This includes Microsoft and firmware-provided certificates for other boot
   loaders and hardware. It does not make unsigned operating systems bootable.
5. Enable Secure Boot in firmware, reboot, and confirm `bootctl status` reports
   `Secure Boot: enabled` and `sudo sbctl status` reports the expected keys.

If boot fails, disable Secure Boot in firmware to recover, then repair the
boot configuration using a working generation or the recovery USB. Secure Boot
does not encrypt the root filesystem or enable TPM disk unlocking.

Upstream: [prepare your system](https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html)
and [enable Secure Boot](https://nix-community.github.io/lanzaboote/getting-started/enable-secure-boot.html).

## Noctalia settings

Settings changed from the Noctalia GUI are saved to
`~/.local/state/noctalia/settings.toml`. They are not automatically reflected in
the Home Manager configuration.

After adjusting the settings in the GUI, update the Home Manager snapshot with:

```console
cp ~/.local/state/noctalia/settings.toml \
  ~/nixos-config/modules/home/desktop/noctalia/settings.toml
```

Runtime settings take precedence over the Home Manager defaults, so GUI changes
remain active after rebuilding. The file in this repository serves as the
reproducible initial configuration and should be updated manually when needed.
