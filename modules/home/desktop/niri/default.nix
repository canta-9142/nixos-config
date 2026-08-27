{ pkgs, ... }:

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
  programs.niri.settings = {
    input = {
      keyboard = {
        xkb = {
          layout = "us";
          model = "";
          rules = "";
          variant = "";
        };
        repeat-delay = 600;
        repeat-rate = 25;
        track-layout = "global";
      };
      touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
        accel-speed = 0.1;
      };
    };

    outputs = {
      "HDMI-A-1" = {
        scale = 1.0;
        transform = {
          rotation = 0;
          flipped = false;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
      "eDP-1" = {
        scale = 1.0;
        transform = {
          rotation = 0;
          flipped = false;
        };
        position = {
          x = 1920;
          y = 0;
        };
        mode = {
          width = 1920;
          height = 1080;
          refresh = 48.001;
        };
      };
    };

    screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y%m%d-%H%M%S.png";
    layout = {
      background-color = "transparent";
      gaps = 10;
      struts = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };
      focus-ring.enable = false;
      border = {
        enable = true;
        width = 4;
        active.color = "#89b4fa";
        inactive.color = "#6c7086";
      };
      default-column-width.proportion = 0.5;
      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 0.5; }
        { proportion = 2.0 / 3.0; }
      ];
      center-focused-column = "never";
    };
    cursor = {
      theme = "Bibata-Modern-Ice";
      size = 24;
    };

    binds = {
      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+S".action.move-window-down = [ ];
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+A".action.move-column-left = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+D".action.move-column-right = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+W".action.move-window-up = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+S".action.focus-window-down = [ ];
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+A".action.focus-column-left = [ ];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+O" = {
        repeat = false;
        action.toggle-overview = [ ];
      };
      "Mod+Q" = {
        repeat = false;
        action.close-window = [ ];
      };
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+D".action.focus-column-right = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-workspace-down = [ ];
      "Mod+Shift+Ctrl+S".action.move-column-to-workspace-down = [ ];
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+A".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+D".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-workspace-up = [ ];
      "Mod+Shift+Ctrl+W".action.move-column-to-workspace-up = [ ];
      "Mod+Shift+Down".action.focus-workspace-down = [ ];
      "Mod+Shift+S".action.focus-workspace-down = [ ];
      "Mod+Shift+E".action.quit = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+A".action.focus-monitor-left = [ ];
      "Mod+Shift+P".action.power-off-monitors = [ ];
      "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+D".action.focus-monitor-right = [ ];
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      "Mod+Shift+Up".action.focus-workspace-up = [ ];
      "Mod+Shift+W".action.focus-workspace-up = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
      "Mod+T" = {
        hotkey-overlay.title = "Open a Terminal: ghostty";
        action.spawn = "ghostty";
      };
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+W".action.focus-window-up = [ ];
      "Mod+V".action.toggle-window-floating = [ ];
      "Print".action.screenshot = [ ];
      "Super+Alt+L" = {
        hotkey-overlay.title = "Lock the Screen: swaylock";
        action.spawn = "swaylock";
      };
      "Super+Alt+Space" = {
        hotkey-overlay.title = "Open Look";
        action.spawn = "lookapp";
      };
      "Super+Space" = {
        hotkey-overlay.title = "Open a Launcher: fuzzel";
        action.spawn-sh = "pkill fuzell || fuzzel";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl next";
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl play-pause";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl previous";
      };
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-volume @DEFALUT_AUDIO_SINK@ 0.1+ -l 1.0";
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl stop";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn-sh = "brightnessctl --class=backlight set 10%-";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn-sh = "brightnessctl --class=backlight set +10%";
      };
    };

    spawn-at-startup = [
      { argv = [ "mako" ]; }
      {
        argv = [
          "fcitx5"
          "-d"
        ];
      }
    ];
    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 12.0;
          top-right = 12.0;
          bottom-right = 12.0;
          bottom-left = 12.0;
        };
        clip-to-geometry = true;
        draw-border-with-background = false;
      }
      {
        matches = [ { app-id = "^com.mitchellh.ghostty$"; } ];
        background-effect = {
          blur = true;
          xray = false;
        };
      }
    ];
    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-wallpaper$"; } ];
        place-within-backdrop = true;
      }
    ];
    blur = {
      enable = true;
      passes = 3;
      offset = 3.0;
      saturation = 1.0;
    };
  };
}
