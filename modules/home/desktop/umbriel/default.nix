{ config, inputs, ... }:

{
  imports = [ inputs.umbriel.homeModules.default ];

  programs.umbriel = {
    enable = true;
    settings = {
      # Noctalia and Hypridle already follow graphical-session.target.
      general.autostart = [
        "fcitx5 -d"
        "wayvnc 0.0.0.0"
      ];

      input = {
        keyboard = {
          layout = "us";
          repeat_delay = 600;
          repeat_rate = 25;
          track_layout = "global";
        };
        touchpad = {
          tap = true;
          disable_while_typing = true;
          natural_scroll = true;
          sensitivity = 0.1;
        };
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
        };
      };

      # Noctalia's Umbriel Displays plugin writes this file on the first edit.
      include.optional.files = [ "${config.xdg.configHome}/umbriel/outputs.toml" ];

      layout = {
        mode = "scrolling";
        gap = 10;
        extent_presets = [
          (1.0 / 3.0)
          0.5
          (2.0 / 3.0)
        ];
        scrolling = {
          default_extent_fraction = 0.5;
          center_focused = "never";
        };
      };

      appearance = {
        border_width = 4;
        corner_radius = 12;
        blur = {
          enabled = true;
          passes = 3;
          radius = 3;
          saturation = 1.0;
        };
      };
      colors.border = {
        focused = "#a7c080";
        unfocused = "#6c7086";
      };

      window_rule = [
        {
          match.app_id = "^com.mitchellh.ghostty$";
          blur = true;
          blur_optimized = false;
        }
        {
          match.app_id = "^dev.noctalia.Noctalia$";
          default_floating = true;
          default_floating_size_px = {
            width = 1020;
            height = 900;
          };
        }
        {
          match.app_id = "^dev.noctalia.UmbrielSharePicker$";
          default_floating = true;
        }
      ];
      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-.*|notification|dock|panel|attached-panel|osd|desktop-widget-.*)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
        }
      ];

      # Match Niri's keys where actions have an equivalent in Umbriel.
      keybinds = {
        "Mod+C" = "column-center";
        "Mod+Ctrl+Down" = "window-move-down";
        "Mod+Ctrl+S" = "window-move-down";
        "Mod+Ctrl+Left" = "column-move-left";
        "Mod+Ctrl+A" = "column-move-left";
        "Mod+Ctrl+Right" = "column-move-right";
        "Mod+Ctrl+D" = "column-move-right";
        "Mod+Ctrl+Up" = "window-move-up";
        "Mod+Ctrl+W" = "window-move-up";
        "Mod+Down" = "window-focus-down";
        "Mod+S" = "window-focus-down";
        "Mod+Equal" = "window-modify-primary-extent +0.1";
        "Mod+Escape" = {
          action = "shortcuts-inhibit-toggle";
          allow_when_inhibited = true;
          repeat = false;
        };
        "Mod+F" = "window-toggle-maximize";
        "Mod+Left" = "window-focus-left";
        "Mod+A" = "window-focus-left";
        "Mod+Minus" = "window-modify-primary-extent -0.1";
        "Mod+O" = {
          action = "overview-toggle";
          repeat = false;
        };
        "Mod+Q" = {
          action = "window-close";
          repeat = false;
        };
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Right" = "window-focus-right";
        "Mod+D" = "window-focus-right";
        "Mod+Shift+Ctrl+Down" = "column-move-to-workspace-next";
        "Mod+Shift+Ctrl+S" = "column-move-to-workspace-next";
        "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+A" = "column-move-to-output-left";
        "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
        "Mod+Shift+Ctrl+D" = "column-move-to-output-right";
        "Mod+Shift+Ctrl+Up" = "column-move-to-workspace-previous";
        "Mod+Shift+Ctrl+W" = "column-move-to-workspace-previous";
        "Mod+Shift+Down" = "workspace-next";
        "Mod+Shift+S" = "workspace-next";
        "Mod+Shift+E" = {
          action = "session-quit";
          repeat = false;
        };
        "Mod+Shift+F" = "window-toggle-fullscreen";
        "Mod+Shift+Left" = "output-focus-left";
        "Mod+Shift+A" = "output-focus-left";
        "Mod+Shift+P" = "dpms-off";
        "Mod+Shift+R" = "window-cycle-primary-extent-back";
        "Mod+Shift+Right" = "output-focus-right";
        "Mod+Shift+D" = "output-focus-right";
        "Mod+Shift+Slash" = "cheatsheet-toggle";
        "Mod+Shift+Up" = "workspace-previous";
        "Mod+Shift+W" = "workspace-previous";
        "Mod+Shift+V" = "window-focus-switch-floating";
        "Mod+T" = {
          action = "spawn ghostty";
          repeat = false;
        };
        "Mod+Up" = "window-focus-up";
        "Mod+W" = "window-focus-up";
        "Mod+V" = "window-toggle-floating";
        "Print" = {
          action = "spawn noctalia msg screenshot-region";
          repeat = false;
        };
        "Super+Alt+L" = {
          action = "spawn loginctl lock-session";
          repeat = false;
        };
        "Super+Alt+Space" = {
          action = "spawn lookapp";
          repeat = false;
        };
        "Super+Space" = {
          action = "spawn fuzzel";
          repeat = false;
        };

        "XF86AudioLowerVolume" = {
          action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          allow_when_locked = true;
        };
        "XF86AudioMute" = {
          action = "spawn wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioNext" = {
          action = "spawn playerctl next";
          allow_when_locked = true;
        };
        "XF86AudioPlay" = {
          action = "spawn playerctl play-pause";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioPrev" = {
          action = "spawn playerctl previous";
          allow_when_locked = true;
        };
        "XF86AudioRaiseVolume" = {
          action = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          allow_when_locked = true;
        };
        "XF86AudioStop" = {
          action = "spawn playerctl stop";
          allow_when_locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = "spawn brightnessctl --class=backlight set 10%-";
          allow_when_locked = true;
        };
        "XF86MonBrightnessUp" = {
          action = "spawn brightnessctl --class=backlight set +10%";
          allow_when_locked = true;
        };

        # Umbriel-specific features, without replacing existing Niri shortcuts.
        "Mod+L" = {
          action = "workspace-set-layout toggle";
          repeat = false;
        };
        "Mod+Shift+Space" = {
          action = "window-move-to-scratchpad";
          repeat = false;
        };
        "Mod+Ctrl+Space" = "scratchpad-toggle";
        "Mod+Ctrl+Shift+Space" = {
          action = "window-restore-from-scratchpad";
          repeat = false;
        };
      };
    };
  };
}
