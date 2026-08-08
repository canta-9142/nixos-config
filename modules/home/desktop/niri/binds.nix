{ config, ... }:

{
	programs.niri.settings.binds = {
		"Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

		"Mod+T"       = { hotkey-overlay.title = "Open a Terminal: ghostty"; action.spawn = [ "ghostty" ]; };
		"Super+Space" = { hotkey-overlay.title = "Open a Launcher: fuzzel";  action.spawn-sh = [ "pkill fuzell || fuzzel" ]; };
		"Super+Alt+L" = { hotkey-overlay.title = "Lock the Screen: swaylock"; action.spawn = [ "swaylock" ]; };

		"XF86AudioRaiseVolume"  = { allow-when-locked = true; action.spawn-sh =  [ "wpctl set-volume @DEFALUT_AUDIO_SINK@ 0.1+ -l 1.0" ]; };
		"XF86AudioLowerVolume"  = { allow-when-locked = true; action.spawn-sh = [ "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-" ]; };
		"XF86AudioMute"         = { allow-when-locked = true; action.spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ]; };

		"XF86AudioPlay"         = { allow-when-locked = true; action.spawn-sh = [ "playerctl play-pause" ]; };
		"XF86AudioStop"         = { allow-when-locked = true; action.spawn-sh = [ "playerctl stop" ]; };
		"XF86AudioPrev"         = { allow-when-locked = true; action.spawn-sh = [ "playerctl previous" ]; };
		"XF86AudioNext"         = { allow-when-locked = true; action.spawn-sh = [ "playerctl next" ]; };

		"XF86MonBrightnessUp"   = { allow-when-locked = true; action.spawn-sh = [ "brightnessctl --class=backlight set +10%" ]; };
		"XF86MonBrightnessDown" = { allow-when-locked = true; action.spawn-sh = [ "brightnessctl --class=backlight set 10%-" ]; };

		"Mod+O" = { repeat = false; action."toggle-overview" = [ ]; };
		"Mod+Q" = { repeat = false; action."close-window" = [ ]; };

		"Mod+Left".action."focus-column-left" = [ ];
		"Mod+Right".action."focus-column-right" = [ ];
		"Mod+Down".action."focus-window-down" = [ ];
		"Mod+Up".action."focus-window-up" = [ ];

		"Mod+Ctrl+Left".action."move-column-left" = [ ];
		"Mod+Ctrl+Right".action."move-column-right" = [ ];
		"Mod+Ctrl+Down".action."move-window-down" = [ ];
		"Mod+Ctrl+Up".action."move-window-up" = [ ];

		"Mod+Shift+Left".action."focus-monitor-left" = [ ];
		"Mod+Shift+Right".action."focus-monitor-right" = [ ];
		"Mod+Shift+Down".action."focus-workspace-down" = [ ];
		"Mod+Shift+Up".action."focus-workspace-up" = [ ];

		"Mod+Shift+Ctrl+Left".action."move-column-to-monitor-left" = [ ];
		"Mod+Shift+Ctrl+Right".action."move-column-to-monitor-right" = [ ];
		"Mod+Shift+Ctrl+Down".action."move-column-to-workspace-down" = [ ];
		"Mod+Shift+Ctrl+Up".action."move-column-to-workspace-up" = [ ];

		"Mod+R".action."switch-preset-column-width" = [ ];
		"Mod+Shift+R".action."switch-preset-column-width-back" = [ ];

		"Mod+F".action."maximize-column" = [ ];
		"Mod+Shift+F".action."fullscreen-window" = [ ];

		"Mod+C".action."center-column" = [ ];

		"Mod+Minus".action."set-column-width" = [ "-10%" ];
		"Mod+Equal".action."set-column-width" = [ "+10%" ];

		"Mod+V".action."toggle-window-floating" = [ ];
		"Mod+Shift+V".action."switch-focus-between-floating-and-tiling" = [ ];

		"Print".action."screenshot" = [ ];

		"Mod+Escape" = { allow-inhibiting = true; action."toggle-keyboard-shortcuts-inhibit" = [ ]; };

		"Mod+Shift+E".action."quit" = [ ];

		"Mod+Shift+P".action."power-off-monitors" = [ ];
	};
}
