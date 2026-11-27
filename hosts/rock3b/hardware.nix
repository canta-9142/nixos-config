{ pkgs, ... }:
let
  monitorEdid = pkgs.runCommand "monitor-edid" { } ''
    mkdir -p "$out/lib/firmware/edid"
    cp ${./edid/monitor-rk3568.bin} "$out/lib/firmware/edid/monitor-rk3568.bin"
  '';
in
{
  services.fstrim.enable = true;
  hardware.firmware = [ monitorEdid ];
  boot = {
    kernelModules = [
      "pwm-fan"
      "pwm-gpio"
    ];
    initrd = {
      availableKernelModules = [ "nvme" ];
      extraFirmwarePaths = [ "edid/monitor-rk3568.bin" ];
    };
    kernelParams = [
      "console=ttyS2,1500000n8"
      "console=tty0"
      "drm.edid_firmware=HDMI-A-1:edid/monitor-rk3568.bin"
    ];
  };

  hardware.deviceTree = {
    enable = true;
    name = "rockchip/rk3568-rock-3b.dtb";
    overlays = [
      {
        name = "rock3b-pwm-fan";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "radxa,rock-3b";

            fragment@0 {
              target = <&pwm8>;
              __overlay__ {
                pinctrl-names = "default";
                pinctrl-0 = <&pwm8m0_pins>;
                status = "okay";
              };
            };

            fragment@1 {
              target-path = "/";
              __overlay__ {
                fan: pwm-fan {
                  compatible = "pwm-fan";
                  pwms = <&pwm8 0 40000 0>;
                  cooling-levels = <0 115 179 255>;
                  #cooling-cells = <2>;
                  fan-stop-to-start-percent = <70>;
                  fan-stop-to-start-us = <500000>;
                  fan-shutdown-percent = <100>;
                };
              };
            };
          };
        '';
      }
      {
        name = "rock3b-poe-pwm-fan";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "radxa,rock-3b";

            fragment@0 {
              target-path = "/";
              __overlay__ {
                radxa_poe_pwm: radxa-poe-pwm {
                  compatible = "pwm-gpio";
                  #pwm-cells = <3>;
                  /* GPIO3_C3, GPIO_ACTIVE_HIGH */
                  gpios = <&gpio3 19 0>;
                };

                radxa-poe-fan {
                  compatible = "pwm-fan";
                  /* 25 kHz, PWM_POLARITY_INVERTED */
                  pwms = <&radxa_poe_pwm 0 40000 1>;
                  cooling-levels = <0 115 179 255>;
                  #cooling-cells = <2>;
                  fan-stop-to-start-percent = <70>;
                  fan-stop-to-start-us = <500000>;
                  fan-shutdown-percent = <100>;
                };
              };
            };
          };
        '';
      }
      {
        name = "rock3b-rtl8211f-gmac0";
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "radxa,rock-3b";
            fragment@0 {
              /* gmac0 = fe2a0000 = end0 */
              target-path = "/ethernet@fe2a0000/mdio/ethernet-phy@1";
              __overlay__ {
                compatible = "ethernet-phy-id001c.c916";
                reset-deassert-us = <80000>;
              };
            };
          };
        '';
      }
    ];
  };

}
