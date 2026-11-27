{ pkgs, ... }:
let
  configureEthernetLeds = pkgs.writeShellApplication {
    name = "rock3b-configure-ethernet-leds";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.phytool
    ];
    text = ''
      iface="$1"
      attempt=1

      while [ "$attempt" -le 30 ]; do
        echo "configuring RTL8211F LEDs on $iface ($attempt/30)"

        if phytool write "$iface/1/31" 0x0d04 &&
           phytool write "$iface/1/16" 0x617f &&
           phytool write "$iface/1/31" 0x0000; then
          echo "configured RTL8211F LEDs on $iface"
          exit 0
        fi

        phytool write "$iface/1/31" 0x0000 || true
        sleep 1
        attempt=$((attempt + 1))
      done

      echo "Failed to configure LEDs on $iface" >&2
      exit 1
    '';
  };
in
{
  # Enslaving an interface to a bond may reset its PHY after the boot-time
  # oneshot has run. Reapply the LED registers whenever a physical port is up.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "rock3b-ethernet-leds-dispatcher" ''
        iface="$1"
        action="$2"

        case "$iface:$action" in
          end0:up|end1:up)
            exec ${configureEthernetLeds}/bin/rock3b-configure-ethernet-leds "$iface"
            ;;
        esac
      '';
      type = "basic";
    }
  ];

  systemd.services = {
    rock3b-ethernet-leds = {
      description = "Configure ROCK 3B RTL8211F Ethernet LEDs";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];

      after = [
        "network-online.target"
        "sys-subsystem-net-devices-end0.device"
        "sys-subsystem-net-devices-end1.device"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${configureEthernetLeds}/bin/rock3b-configure-ethernet-leds end0
        ${configureEthernetLeds}/bin/rock3b-configure-ethernet-leds end1
      '';
    };
  };
}
