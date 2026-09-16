# nixos-config

NixOS and Home Manager configuration for the `nixos` host.

## Desktop

![Desktop image](./assets/images/desktop-rice.png)

## Layout

```plain
.
├── assets                             # Wallpapers and some images
│   └── wallpapers
├── flake.lock
├── flake.nix                          # NixOS Flakes
├── hosts
│   └── nixos
│       ├── default.nix                # host-specific configuration
│       └── hardware-configuration.nix # generated hardware settings
├── modules
│   ├── home                           # reusable Home Manager modules
│   │   ├── desktop
│   │   │   └── niri                   # Niri Home Manager module
│   │   │       └── default.nix
│   │   ├── programs
│   │   │   ├── codex.nix              # Codex remote-control daemon (but not used now)
│   │   │   ├── fastfetch              # Fastfetch settings and presets
│   │   │   │   ├── default.nix
│   │   │   │   ├── fastfetch.jsonc
│   │   │   │   └── narrow.jsonc
│   │   │   ├── fish                   # Fish shell settings and oh-my-posh theme
│   │   │   │   ├── config.omp.json
│   │   │   │   └── default.nix
│   │   │   ├── ghostty.nix            # Ghostty theme 
│   │   │   ├── git.nix                # Git config
│   │   │   ├── noctalia               # Noctalia settings
│   │   │   │   ├── default.nix
│   │   │   │   └── settings.toml
│   │   │   └── ssh.nix                # SSH settings
│   │   └── services
│   │       └── activitywatch.nix      # Activity Watch (not used now)
│   └── nixos                          # reusable NixOS system module 
│       ├── audio.nix
│       ├── boot.nix
│       ├── core.nix
│       ├── desktop
│       │   ├── default.nix            # desktop environment entry point
│       │   ├── fonts.nix
│       │   ├── input-method.nix
│       │   ├── niri.nix               # niri (window manager)
│       │   ├── sddm.nix               # sddm (display manager)
│       │   └── stylix.nix
│       ├── networking.nix
│       ├── packages.nix               # system packages
│       ├── security
│       │   ├── sops.nix               # sops-nix settings
│       │   └── sudo.nix
│       └── users.nix
├── overlays                           # nixpkgs overlays
│   └── default.nix
├── secrets
│   └── ssh.yaml                       # ssh private key (encrypted by sops)
└── users
    └── jinji                          # Home Manager entry point for the user
        └── default.nix
```

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
  ~/nixos-config/modules/home/programs/noctalia/settings.toml
```

Runtime settings take precedence over the Home Manager defaults, so GUI changes
remain active after rebuilding. The file in this repository serves as the
reproducible initial configuration and should be updated manually when needed.
