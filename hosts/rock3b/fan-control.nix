{ pkgs, ... }:
let
  fanctl = pkgs.writeShellApplication {
    name = "fanctl";
    runtimeInputs = [ pkgs.systemd ];
    text = builtins.readFile ./fanctl.sh;
  };
  fanController = pkgs.writeShellApplication {
    name = "rock3b-fan-controller";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      fan_device="$1"
      thermal_zone=""
      pwm_path=""

      for _ in {1..30}; do
        for zone in /sys/class/thermal/thermal_zone*; do
          if [[ -e "$zone/type" ]] && [[ "$(< "$zone/type")" == "cpu-thermal" ]]; then
            thermal_zone="$zone"
            break
          fi
        done

        for hwmon in /sys/devices/platform/"$fan_device"/hwmon/hwmon*; do
          if [[ -e "$hwmon/name" ]] && [[ "$(< "$hwmon/name")" == "pwmfan" ]]; then
            pwm_path="$hwmon/pwm1"
            break
          fi
        done

        if [[ -n "$thermal_zone" && -w "$pwm_path" ]]; then
          break
        fi

        sleep 1
      done

      if [[ -z "$thermal_zone" || ! -w "$pwm_path" ]]; then
        echo "CPU thermal zone or PWM fan $fan_device was not found" >&2
        exit 1
      fi

      full_speed() {
        printf '255\n' > "$pwm_path" || true
      }
      trap full_speed EXIT
      trap 'exit 0' INT TERM HUP

      # Keep the fan at full speed until the first valid temperature reading.
      full_speed

      state=-1
      while true; do
        temperature="$(< "$thermal_zone/temp")"

        if [[ ! "$temperature" =~ ^[0-9]+$ ]]; then
          echo "Invalid CPU temperature: $temperature" >&2
          exit 1
        fi

        case "$state" in
          -1|0)
            if (( temperature >= 70000 )); then
              next_state=3
            elif (( temperature >= 60000 )); then
              next_state=2
            elif (( temperature >= 50000 )); then
              next_state=1
            else
              next_state=0
            fi
            ;;
          1)
            if (( temperature >= 70000 )); then
              next_state=3
            elif (( temperature >= 60000 )); then
              next_state=2
            elif (( temperature < 48000 )); then
              next_state=0
            else
              next_state=1
            fi
            ;;
          2)
            if (( temperature >= 70000 )); then
              next_state=3
            elif (( temperature < 58000 )); then
              next_state=1
            else
              next_state=2
            fi
            ;;
          3)
            if (( temperature < 68000 )); then
              next_state=2
            else
              next_state=3
            fi
            ;;
        esac

        if (( next_state != state )); then
          case "$next_state" in
            0) pwm=0; percent=0 ;;
            1) pwm=115; percent=45 ;;
            2) pwm=179; percent=70 ;;
            3) pwm=255; percent=100 ;;
          esac

          printf '%s\n' "$pwm" > "$pwm_path"
          echo "CPU $((temperature / 1000)) C: fan $percent% (state $next_state)"
          state="$next_state"
        fi

        sleep 2
      done
    '';
  };
in
{
  environment.systemPackages = [ fanctl ];
  systemd.services = {
    rock3b-fan-controller = {
      description = "Control the ROCK 3B fan from CPU temperature";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${fanController}/bin/rock3b-fan-controller pwm-fan";
        Restart = "always";
        RestartSec = 2;
      };
    };

    rock3b-poe-fan-controller = {
      description = "Control the ROCK 3B PoE+ HAT fan from CPU temperature";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${fanController}/bin/rock3b-fan-controller radxa-poe-fan";
        Restart = "always";
        RestartSec = 2;
      };
    };

  };
}
