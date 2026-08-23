{ inputs, config, pkgs, lib, ... }:

let
	plymouthWithConsoleOverlay =
		(pkgs.plymouth.override {
			systemd = config.boot.initrd.systemd.package;
		}).overrideAttrs (old: {
			patches = (old.patches or [ ]) ++ [
				./plymouth/console-overlay.patch
			];
		});

	plymouthBootLogTheme = pkgs.runCommand "plymouth-theme-nixos-bootlog" {
		nativeBuildInputs = [ pkgs.oxipng ];
	} ''
		themeDir="$out/share/plymouth/themes/nixos-bootlog"
		mkdir -p "$themeDir"

		cp ${../../assets/wallpapers/nix-catppuccin-latte.png} \
			"$themeDir/background.png"
		chmod u+w "$themeDir/background.png"
		oxipng --opt max --strip safe "$themeDir/background.png"
		for asset in lock entry bullet capslock keyboard keymap-render; do
			cp ${plymouthWithConsoleOverlay}/share/plymouth/themes/spinner/"$asset.png" \
				"$themeDir/$asset.png"
		done

		substitute ${./plymouth/bootlog.plymouth} \
			"$themeDir/nixos-bootlog.plymouth" \
			--replace-fail '@IMAGE_DIR@' "$themeDir"
	'';
in
{
	# Plymouth needs the native AMD KMS driver while it is still running in the
	# initrd.  Loading it later leaves Plymouth on simpledrm until SDDM starts.
	boot.initrd.kernelModules = [ "amdgpu" ];
	boot.initrd.systemd.services.plymouth-start.after = [
		"systemd-modules-load.service"
	];

	boot.plymouth = {
		enable = true;
		package = plymouthWithConsoleOverlay;
		theme = "nixos-bootlog";
		themePackages = [ plymouthBootLogTheme ];
		font = "${pkgs.cascadia-code}/share/fonts/truetype/CascadiaCode-Regular.ttf";
		showDelay = 0;
	};

	boot.kernelParams = [
		"systemd.show_status=true"
		"rd.systemd.show_status=true"
		# Plymouth and SDDM both use tty1.  Keep fbcon off that VT so it
		# cannot repaint Plymouth's retained frame with its black text buffer
		# during the handoff.  Text consoles remain available on tty2 onward.
		"fbcon=vc:2-63"
	];

	boot.consoleLogLevel = 6;

	# Leave Plymouth's last frame on the framebuffer while SDDM takes over.
	# Plymouth still exits and releases DRM, so it does not block the display
	# manager from starting.
	systemd.services.plymouth-quit.serviceConfig.ExecStart = lib.mkForce [
		""
		"${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
	];

	boot.loader = {
		timeout = 10;

		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot";
		};

		systemd-boot = {
			enable = true;
			configurationLimit = 30;
			extraInstallCommands = ''
				${pkgs.python3}/bin/python3 - ${lib.escapeShellArg "${config.boot.loader.efi.efiSysMountPoint}/loader/entries"} <<-'PY'
				import datetime
				import re
				import sys
				from pathlib import Path

				entries_dir = Path(sys.argv[1])
				generation_pattern = re.compile(r"Generation ([0-9]+) ")
				profile_pattern = re.compile(r"^title .* \[([^]]+)]", re.MULTILINE)
				date_pattern = re.compile(
				    r"built on [0-9]{4}-[0-9]{2}-[0-9]{2}(?: [0-9]{2}:[0-9]{2}:[0-9]{2})?"
				)

				for entry in entries_dir.glob("nixos-*.conf"):
				    contents = entry.read_text()
				    generation_match = generation_pattern.search(contents)
				    if generation_match is None:
				        continue

				    profile_match = profile_pattern.search(contents)
				    profile = (
				        Path("/nix/var/nix/profiles/system-profiles") / profile_match.group(1)
				        if profile_match is not None
				        else Path("/nix/var/nix/profiles/system")
				    )
				    generation_link = Path(f"{profile}-{generation_match.group(1)}-link")
				    if not generation_link.exists():
				        continue

				    built_at = datetime.datetime.fromtimestamp(generation_link.stat().st_ctime)
				    updated = date_pattern.sub(
				        f"built on {built_at:%Y-%m-%d %H:%M:%S}", contents
				    )
				    if updated != contents:
				        entry.write_text(updated)
				PY
			'';
		};
		
		#grub = {
		#	enable = true;
		#	efiSupport = true;
		#	devices = [ "nodev" ];
		#	useOSProber = true;
		#	configurationLimit = 5;
		#	extraEntriesBeforeNixOS = false;
		#	extraEntries = ''
		#		menuentry "Reboot" {
		#			reboot
		#		}
		#		menuentry "Poweroff" {
		#			halt
		#		}
		#	'';
		#	theme = lib.mkForce inputs.nixos-grub-themes.packages.${pkgs.system}.hyperfluent;
		#};
	};
	
	nix.gc = {
	  	automatic = true;
	  	dates = "daily";
	  	options = "--delete-older-than 5d";
	};
}
