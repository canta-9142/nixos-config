{ config, pkgs, ... }:

{ 			
	home.pointerCursor = {
		enable = true;
		package = pkgs.bibata-cursors;
		name = "Bibata-Modern-Ice";
		size = 24;
		gtk.enable = true;
		x11.enable = true;
	};

	programs.niri.package = pkgs.niri-unstable;

	programs.niri.config = ''
		input {
		    keyboard {
		        xkb {
		            layout "us"
		            model ""
		            rules ""
		            variant ""
		        }
		        repeat-delay 600
		        repeat-rate 25
		        track-layout "global"
		    }
		    touchpad {
		        tap
		        dwt
		        natural-scroll
		        accel-speed 0.100000
		    }
		}
		output "HDMI-A-1" {
		    scale 1.000000
		    transform "normal"
		    position x=0 y=0
		}
		output "eDP-1" {
		    scale 1.000000
		    transform "normal"
		    position x=1920 y=0
		    mode "1920x1080@48.001000"
		}
		screenshot-path "~/Pictures/Screenshots/Screenshot_%Y%m%d-%H%M%S.png"
		layout {
		    background-color "transparent"
		    gaps 10
		    struts {
		        left 0
		        right 0
		        top 0
		        bottom 0
		    }
		    focus-ring { off; }
		    border {
		        width 4
		        active-color "#89b4fa"
		        inactive-color "#6c7086"
		    }
		    default-column-width { proportion 0.500000; }
		    preset-column-widths {
		        proportion 0.333333
		        proportion 0.500000
		        proportion 0.666667
		    }
		    center-focused-column "never"
		}
		cursor {
		    xcursor-theme "Bibata-Modern-Ice"
		    xcursor-size 24
		}
		binds {
		    Mod+C { center-column; }
		    Mod+Ctrl+Down { move-window-down; }
		    Mod+Ctrl+Left { move-column-left; }
		    Mod+Ctrl+Right { move-column-right; }
		    Mod+Ctrl+Up { move-window-up; }
		    Mod+Down { focus-window-down; }
		    Mod+Equal { set-column-width "+10%"; }
		    Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
		    Mod+F { maximize-column; }
		    Mod+Left { focus-column-left; }
		    Mod+Minus { set-column-width "-10%"; }
		    Mod+O repeat=false { toggle-overview; }
		    Mod+Q repeat=false { close-window; }
		    Mod+R { switch-preset-column-width; }
		    Mod+Right { focus-column-right; }
		    Mod+Shift+Ctrl+Down { move-column-to-workspace-down; }
		    Mod+Shift+Ctrl+Left { move-column-to-monitor-left; }
		    Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
		    Mod+Shift+Ctrl+Up { move-column-to-workspace-up; }
		    Mod+Shift+Down { focus-workspace-down; }
		    Mod+Shift+E { quit; }
		    Mod+Shift+F { fullscreen-window; }
		    Mod+Shift+Left { focus-monitor-left; }
		    Mod+Shift+P { power-off-monitors; }
		    Mod+Shift+R { switch-preset-column-width-back; }
		    Mod+Shift+Right { focus-monitor-right; }
		    Mod+Shift+Slash { show-hotkey-overlay; }
		    Mod+Shift+Up { focus-workspace-up; }
		    Mod+Shift+V { switch-focus-between-floating-and-tiling; }
		    Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
		    Mod+Up { focus-window-up; }
		    Mod+V { toggle-window-floating; }
		    Print { screenshot; }
		    Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
		    Super+Space hotkey-overlay-title="Open a Launcher: fuzzel" { spawn-sh "pkill fuzell || fuzzel"; }
		    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
		    XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
		    XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }
		    XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
		    XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
		    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFALUT_AUDIO_SINK@ 0.1+ -l 1.0"; }
		    XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
		    XF86MonBrightnessDown allow-when-locked=true { spawn-sh "brightnessctl --class=backlight set 10%-"; }
		    XF86MonBrightnessUp allow-when-locked=true { spawn-sh "brightnessctl --class=backlight set +10%"; }
		}
		spawn-at-startup "mako"
		spawn-at-startup "fcitx5 -d"
		window-rule {
		    geometry-corner-radius 12.000000 12.000000 12.000000 12.000000
		    clip-to-geometry true
		    draw-border-with-background false
		}
		window-rule {
			match app-id="^com.mitchellh.ghostty$"
			background-effect {
				blur true
				xray false
			}
		}
		layer-rule {
			match namespace="^noctalia-wallpaper$"
			place-within-backdrop true
		}
		blur {
			passes 3
			offset 3.0
			saturation 1.0
		}
	'';
}
