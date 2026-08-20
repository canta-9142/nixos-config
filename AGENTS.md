# AGENTS.md

## Development environment

This project generally uses a Nix flake and direnv-nix to provide its development environment. Use `nix develop` to make the required tools available on `PATH`.

You may create or edit the root `flake.nix` without asking for confirmation. For tools that are likely to be needed only once, prefer `nix shell` instead of adding them permanently to the development shell.

## Authorization to modify files

Unless the user explicitly asks you to implement, fix, add, update, or otherwise modify something, do not change files. Limit your response to explanations and proposed changes.

## Validation

After changing Nix files, run the following checks when applicable:

- `nix fmt`
- `nix develop -c statix check .`
- `nix develop -c deadnix --fail .`
- `nix flake check`

If a check cannot be run because of time, environment, or another constraint, clearly report which check was skipped and why.

## System activation

Do not run commands that alter the active system state, such as `nh os switch`, `nixos-rebuild switch`, or reboot commands, unless the user explicitly requests system activation. Prefer builds and checks when validating configuration changes.

## Secrets

Never expose decrypted contents from `secrets/`, private keys, tokens, or passwords in command output, responses, or commits. When adding or changing secret material, follow the existing sops-nix configuration and keep secret values encrypted.

## Repository structure

Place configuration according to the existing project layout:

- Host-specific configuration belongs in `hosts/`.
- Reusable NixOS modules belong in `modules/nixos/`.
- Reusable Home Manager modules belong in `modules/home/`.
- User-specific configuration belongs in `users/`.

Do not edit `hosts/nixos/hardware-configuration.nix` unless the user explicitly requests a hardware configuration change.

## Web UI design

When creating a web UI, use a rigorously minimal, monochrome visual style. Avoid rounded card-based interfaces, navy backgrounds in dark mode, and beige backgrounds in light mode.
