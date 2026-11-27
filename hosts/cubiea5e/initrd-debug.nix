{ config, pkgs, ... }:
{
  # Diagnose firmware-enabled clocks or power domains being disabled during boot.
  boot.kernelParams = [
    "clk_ignore_unused"
    "pd_ignore_unused"
    # Preserve the arguments used by the working NVMe diagnostic boot.
    "iomem=relaxed"
    "pcie_aspm=off"
    # Diagnostic comparison: disable CPUFreq-driven frequency/voltage changes.
    "cpufreq.off=1"
    # Preserve the power-management settings used by the successful Gen1 boots.
    "nvme_core.default_ps_max_latency_us=0"
    # Use the existing kernel's boot tracing to correlate configuration loss.
    "trace_clock=mono"
    "trace_buf_size=1M"
    "trace_event=initcall:initcall_start,initcall:initcall_finish,module:module_load,clk:clk_enable,clk:clk_disable,clk:clk_set_rate,pci:pcie_link_event"
  ];

  boot.initrd = {
    availableKernelModules = [
      "uas"
      "nls_cp437"
      "nls_iso8859-1"
    ];
    # Both onboard Ethernet controllers must work before the NVMe root is mounted.
    kernelModules = [
      "motorcomm" # Earlier PHY diagnostic; this board currently uses Generic PHY.
      "dwmac-sun8i"
      "dwmac-sun55i"
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users.jinji.openssh.authorizedKeys.keys;
        # Generate an ephemeral host key in RAM, never in the published image.
        hostKeys = [ ];
        ignoreEmptyHostKeys = true;
        extraConfig = ''
          HostKey /run/initrd-ssh-host-key
          AllowUsers root
          PermitRootLogin prohibit-password
        '';
      };
    };
    systemd = {
      shell.enable = true;
      network = {
        enable = true;
        networks."10-ethernet" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "ipv4";
          dhcpV4Config = {
            ClientIdentifier = "mac";
            Hostname = "cubiea5e-initrd";
          };
          linkConfig.RequiredForOnline = "no";
        };
      };
      extraBin = {
        blkid = "${pkgs.util-linux}/bin/blkid";
        devmem = "${pkgs.busybox}/bin/devmem";
        dmesg = "${pkgs.util-linux}/bin/dmesg";
        ip = "${pkgs.iproute2}/bin/ip";
        lspci = "${pkgs.pciutils}/bin/lspci";
        setpci = "${pkgs.pciutils}/bin/setpci";
        lsblk = "${pkgs.util-linux}/bin/lsblk";
        ssh-keygen = "${pkgs.openssh}/bin/ssh-keygen";
      };
      services = {
        initrd-pcie-gen1 = {
          description = "Retrain the Cubie A5E NVMe link to Gen1 before coldplug";
          wantedBy = [ "initrd.target" ];
          after = [ "initrd-pcie-watch.service" ];
          before = [
            "systemd-modules-load.service"
            "systemd-udev-trigger.service"
            "sysroot.mount"
          ];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "oneshot";
            TimeoutStartSec = 10;
          };
          script = builtins.readFile ./initrd-pcie-gen1.sh;
        };
        initrd-pcie-watch = {
          description = "Observe PCIe configuration before and during coldplug";
          wantedBy = [ "initrd.target" ];
          before = [
            "systemd-modules-load.service"
            "systemd-udev-trigger.service"
            "initrd-usb-debug.service"
            "initrd-switch-root.target"
          ];
          conflicts = [ "initrd-switch-root.target" ];
          unitConfig = {
            DefaultDependencies = false;
            IgnoreOnIsolate = true;
          };
          serviceConfig = {
            Type = "notify";
            NotifyAccess = "all";
            TimeoutStartSec = 5;
            TimeoutStopSec = 3;
            KillMode = "mixed";
          };
          preStart = ''
            if [ "$(stat -f -c %T /sys/kernel/tracing)" != tracefs ]; then
              mount -t tracefs tracefs /sys/kernel/tracing || true
            fi
          '';
          script = builtins.readFile ./initrd-pcie-watch.sh;
          postStop = ''
            if [ -r /sys/kernel/tracing/trace ]; then
              echo 0 > /sys/kernel/tracing/tracing_on
              cat /sys/kernel/tracing/trace > /run/cubiea5e-pcie-trace.txt
              chmod 644 /run/cubiea5e-pcie-trace.txt
            fi
          '';
        };
        initrd-pcie-recover = {
          description = "Restore the observed lost PCIe configuration for diagnosis";
          wantedBy = [ "initrd.target" ];
          after = [
            "systemd-modules-load.service"
            "systemd-udev-trigger.service"
          ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          script = ''
            set -eu
            export PATH=/bin
            [ "$(tr -d '\000' < /proc/device-tree/model)" = 'Radxa Cubie A5E' ] || exit 0
            udevadm settle --timeout=30
            endpoint=/sys/bus/pci/devices/0000:01:00.0
            [ -d "$endpoint" ] || exit 0
            [ "$(cat "$endpoint/vendor")" = 0x1e95 ] || exit 0
            [ "$(cat "$endpoint/device")" = 0x1007 ] || exit 0
            read -r start end _ < "$endpoint/resource"
            [ "$start" = 0x0000000022000000 ] || exit 0
            [ "$end" = 0x0000000022003fff ] || exit 0
            [ "$(setpci -s 0000:00:00.0 18.l)" = 00000000 ] || exit 0
            [ "$(setpci -s 0000:00:00.0 COMMAND.w)" = 0000 ] || exit 0
            [ "$(setpci -s 0000:01:00.0 10.l)" = 00000004 ] || exit 0
            [ "$(setpci -s 0000:01:00.0 14.l)" = 00000000 ] || exit 0
            if [ -L "$endpoint/driver" ]; then
              [[ "$(readlink "$endpoint/driver")" = */nvme ]] || exit 0
              echo 'Detaching NVMe after verified PCIe configuration loss'
              echo 0000:01:00.0 > /sys/bus/pci/drivers/nvme/unbind
            fi
            echo 'Restoring lost bridge bus numbers, command bits and NVMe BAR'
            setpci -s 0000:00:00.0 18.l=00ff0100:00ffffff COMMAND.w=0007:0007
            setpci -s 0000:01:00.0 10.l=22000004 14.l=00000000
            setpci -s 0000:00:00.0 COMMAND.w 18.l
            setpci -s 0000:01:00.0 10.l 14.l
            echo 0000:01:00.0 > /sys/bus/pci/drivers_probe
          '';
        };
        initrd-usb-debug = {
          description = "Save early boot diagnostics to the debug USB stick";
          wantedBy = [ "initrd.target" ];
          after = [ "initrd-led-marker.service" ];
          before = [ "initrd-switch-root.target" ];
          conflicts = [ "initrd-switch-root.target" ];
          unitConfig = {
            DefaultDependencies = false;
            IgnoreOnIsolate = true;
          };
          serviceConfig = {
            Type = "exec";
          };
          script = builtins.readFile ./initrd-usb-debug.sh;
        };
        initrd-led-marker = {
          description = "Show initrd startup on the status LEDs";
          wantedBy = [ "initrd.target" ];
          before = [
            "systemd-modules-load.service"
            "sysroot.mount"
          ];
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          script = ''
            for trigger in /sys/class/leds/*/trigger; do
              if [ -w "$trigger" ]; then
                echo default-on > "$trigger"
              fi
            done
          '';
        };
        sshd = {
          unitConfig.IgnoreOnIsolate = true;
          before = [ "initrd-switch-root.target" ];
          conflicts = [ "initrd-switch-root.target" ];
          preStart = ''
            if [ ! -s /run/initrd-ssh-host-key ]; then
              /bin/ssh-keygen -q -t ed25519 -N "" -f /run/initrd-ssh-host-key
            fi
          '';
        };
        systemd-networkd = {
          unitConfig.IgnoreOnIsolate = true;
          before = [ "initrd-switch-root.target" ];
          conflicts = [ "initrd-switch-root.target" ];
        };
      };
    };
  };
}
