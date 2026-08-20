{ config, pkgs, lib, ... }:

let
    custom-sddm-astronaut = pkgs.sddm-astronaut.override {
        themeConfig = {
            Background = toString ../../../assets/wallpapers/nix-catppuccin-latte.png;
            Blur = 0.4;
            ParticalBlur = true;
            Font = "Noto Sans CJK JP";
        };
    };

	# Weston paints its own surface before the Qt greeter is ready.  Use the
	# Plymouth image for that intermediate surface instead of kiosk-shell's
	# black background.
	sddmWestonConfig = (pkgs.formats.ini { }).generate "sddm-weston.ini" {
		keyboard = {
			keymap_layout = config.services.xserver.xkb.layout;
			keymap_model = config.services.xserver.xkb.model;
			keymap_options = config.services.xserver.xkb.options;
			keymap_variant = config.services.xserver.xkb.variant;
		};
		libinput = {
			enable-tap = config.services.libinput.mouse.tapping;
			left-handed = config.services.libinput.mouse.leftHanded;
		};
		shell = {
			background-image = toString ../../../assets/wallpapers/nix-catppuccin-latte.png;
			background-type = "scale-crop";
			locking = false;
			panel-position = "none";
			startup-animation = "none";
		};
	};

	sddmWestonHandoff = pkgs.writeShellScript "sddm-weston-handoff" ''
		handoffDir=/run/plymouth-sddm

		if [[ -d "$handoffDir" && -e /run/plymouth/pid ]]; then
			touch "$handoffDir/request"

			# The root handoff service quits Plymouth and creates this file only
			# after the DRM device has been released.
			for attempt in $(seq 1 600); do
				if [[ -e "$handoffDir/ready" ]]; then
					break
				fi
				sleep 0.02
			done
		fi

		exec ${pkgs.weston}/bin/weston --shell=desktop -c ${sddmWestonConfig}
	'';

in {
	services.displayManager.sddm = {
		enable = true;
		wayland = {
			enable = true;
			compositorCommand = toString sddmWestonHandoff;
		};
		extraPackages = with pkgs; [
			custom-sddm-astronaut
			kdePackages.qtmultimedia
		];

		theme = "${custom-sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
		settings = {
			Theme = {
				Current = "sddm-astronaut-theme";
			};
		};
	};

	environment.systemPackages = with pkgs; [
		custom-sddm-astronaut
		kdePackages.qtmultimedia
	];

	# The stock Plymouth unit exits before SDDM has even initialized.  Instead,
	# coordinate with the Weston wrapper so Plymouth releases DRM immediately
	# before Weston requests it.
	systemd.services = {
		plymouth-quit.wantedBy = lib.mkForce [ ];

		plymouth-sddm-handoff = {
			description = "Hand Plymouth over to the SDDM compositor";
			wantedBy = [ "display-manager.service" ];
			before = [ "display-manager.service" ];
			after = [ "plymouth-start.service" ];
			unitConfig.ConditionPathExists = "/run/plymouth/pid";
			path = [ pkgs.coreutils ];
			serviceConfig = {
				Group = "sddm";
				RuntimeDirectory = "plymouth-sddm";
				RuntimeDirectoryMode = "0770";
				RuntimeDirectoryPreserve = "yes";
			};
			script = ''
				rm -f /run/plymouth-sddm/request /run/plymouth-sddm/ready

				quit_plymouth() {
					local plymouth_pid=
					if [[ -r /run/plymouth/pid ]]; then
						read -r plymouth_pid < /run/plymouth/pid || true
					fi

					${config.boot.plymouth.package}/bin/plymouth quit --retain-splash || true

					# The Plymouth client is acknowledged before the daemon has
					# closed its DRM file descriptors.  Do not let Weston race that
					# shutdown: process disappearance guarantees the descriptors
					# have been closed and DRM master has been released.
					if [[ "$plymouth_pid" =~ ^[0-9]+$ ]]; then
						for attempt in $(seq 1 500); do
							[[ ! -e "/proc/$plymouth_pid" ]] && break
							sleep 0.01
						done
					fi
				}

				for attempt in $(seq 1 500); do
					if [[ -e /run/plymouth-sddm/request ]]; then
						quit_plymouth
						touch /run/plymouth-sddm/ready
						exit 0
					fi
					sleep 0.02
				done

				# Do not leave Plymouth running indefinitely if SDDM fails before
				# launching its compositor.
				quit_plymouth
				touch /run/plymouth-sddm/ready
			'';
		};
	};
}
