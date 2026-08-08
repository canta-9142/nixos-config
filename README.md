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
│       │   ├── default.nix
│       │   ├── fonts.nix
│       │   ├── input-method.nix
│       │   ├── niri.nix
│       │   ├── sddm.nix
│       │   └── stylix.nix
│       ├── networking.nix
│       ├── packages.nix
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
