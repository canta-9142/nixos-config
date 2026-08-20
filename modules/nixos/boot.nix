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
	];

	boot.consoleLogLevel = 6;

	boot.loader = {
		timeout = 10;

		efi = {
			canTouchEfiVariables = true;
			efiSysMountPoint = "/boot";
		};

		systemd-boot = {
			enable = true;
			configurationLimit = 30;
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
