# nixos-config

NixOS and Home Manager configuration for the `nixos` host.

## Desktop

![Desktop image](./assets/images/desktop-rice.png)

## Layout

- `hosts/nixos`: host-specific configuration and generated hardware settings
- `modules/nixos`: reusable system modules
- `modules/home`: reusable Home Manager modules
- `users/jinji`: Home Manager entry point for the user
- `overlays`: nixpkgs overlays
- `assets`: wallpapers and display-manager assets

SOPS support is reserved in `modules/nixos/security/sops.nix`, but is not enabled yet.

## Apply

```console
sudo nixos-rebuild switch --flake .#nixos
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
