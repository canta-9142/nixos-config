# nixos-config

NixOS and Home Manager configuration for the `nixos` host.

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
