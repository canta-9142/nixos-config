# nixos-config
NixOS and Home Manager configuration for the `inspiron5425` laptop.
Ryzen, ROCK 3B and Cubie A5E configurations are also included.
See [server operations](docs/servers.md) for deployment, images and recovery.
All four hosts use the same pinned `nixpkgs` input.

## Desktop

![Desktop image](./assets/images/desktop-rice.png)

Niri and Umbriel are available as separate SDDM sessions. After activating the
configuration, log out and select **Umbriel** in SDDM to try it; select **Niri**
to return. Both sessions use the same Noctalia settings and Hyprlock/Hypridle.

Umbriel starts with a scrolling layout and mirrors Niri's main shortcuts,
monitor positions, keyboard and touchpad settings. Its additional shortcuts are:

- `Super+L`: cycle scrolling, dwindle, master and stacking layouts.
- `Super+Shift+Space`: move the focused window to the scratchpad.
- `Super+Ctrl+Space`: show or hide the scratchpad.
- `Super+Ctrl+Shift+Space`: restore a scratchpad window to its workspace.

`Super+Alt+L` locks the session, `Super+Shift+E` asks to log out, and `Print`
uses Noctalia's region screenshot tool. Umbriel's configuration lives in
`modules/home/desktop/umbriel/default.nix`. GUI behavior, input methods, remote
access and suspend/resume should be checked in the actual Umbriel session.

## Layout

```plain
hosts/
  inspiron5425/           # inspiron5425 (x86_64-linux): boot, disk, network and packages
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

Directory names do not change hostnames or flake selectors: use `.#inspiron5425`
for the laptop.

Validation:

```console
nix fmt
nix develop -c statix check .
nix develop -c deadnix --fail .
nix flake check
```

## OBS to Discord

The desktop configuration installs OBS with the `OBS Cam` virtual camera and a
PipeWire audio cable from the `OBS Audio` output to the `OBS Microphone` input.
After activating the configuration, reboot to load the configured virtual camera
module and restart the audio session.

1. In OBS, add the video and audio sources you want to send.
2. In Settings → Audio → Advanced, select `OBS Audio` as the Monitoring Device.
3. In Advanced Audio Properties, set each audio source you want to send to
   **Monitor and Output** (or **Monitor Only** if it should not also be recorded
   or streamed by OBS). Leave Discord's received audio out of this mix to avoid
   sending other participants' voices back to them.
4. Click **Start Virtual Camera** in OBS before selecting the camera in Discord.
5. In Discord's Voice & Video settings, select `OBS Cam` as the camera and
   `OBS Microphone` as the input device. Enable your camera in the call.

Video is sent as a camera feed; audio is sent through the call's microphone
input. If music or game audio is suppressed, disable Discord's noise suppression
and automatic gain control and adjust its input sensitivity.

## Remote evaluation and builds

In Fish, `nsr` and `nbr` sync `~/nixos-config` to
`~/.cache/nixos-remote-rebuild/inspiron5425/source` on `jinji@ryzen.home.arpa`,
evaluate and build `nixosConfigurations.inspiron5425` there, and copy the result back
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
   sudo nixos-rebuild boot --flake .#inspiron5425
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

## Kernel compilation cache

Inspiron 5425, ROCK 3B and Cubie A5E share the kernel ccache setup in
`lib/kernel-ccache/`. The ARM kernels are cross-compiled on x86_64 using their
cross toolchain; the installed systems remain aarch64.

Ryzen exposes `/srv/kernel/ccache` to its Nix build sandbox through
`modules/system/nix/ccache.nix`. The three kernels share a 50 GB cache.
A local build of these kernels also needs this module on its build machine.
The source path and generated Kconfig C heading are kept stable to allow reuse
across derivations without ignoring changes to configuration definitions.
