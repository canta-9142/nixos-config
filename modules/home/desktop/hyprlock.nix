{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Noctalia manages idle timers; hypridle handles logind lock/sleep requests.
  services.hypridle = {
    enable = true;
    settings.general = {
      lock_cmd = "${pkgs.procps}/bin/pgrep -x hyprlock || ${lib.getExe config.programs.hyprlock.package}";
      before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
      inhibit_sleep = 3;
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = false;
        ignore_empty_input = true;
      };
      animations = {
        enabled = true;
        # Niri does not expose the desktop behind transparent lock surfaces.
        animation = [
          "fadeIn, 2000"
          "fadeOut, 3000"
        ];
      };
      background = [
        {
          monitor = "";
          path = "${../../../assets/wallpapers/nix-catppuccin-latte.png}";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          color = "rgb(ffffff)";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "300, 48";
          rounding = 5;
          outline_thickness = 0;

          inner_color = "rgba(00000044)";
          outer_color = "rgb(00000000)";
          font_color = "rgb(ffffff)";

          dots_size = 0.2;
          dots_spacing = 0.3;
          dots_center = true;

          fade_on_empty = false;
          placeholder_text = "Password";

          check_color = "rgb(ffffff66)";
          check_text = "Checking…";
          fail_color = "rgb(aaaaaa)";
          fail_text = "Try again";
        }
      ];
    };
  };
}
