set -euo pipefail

[ "$(cat /proc/device-tree/model 2>/dev/null | tr -d '\000')" = 'Radxa Cubie A5E' ] || exit 0
endpoint=/sys/bus/pci/devices/0000:01:00.0
[ "$(cat "$endpoint/vendor" 2>/dev/null)" = 0x1e95 ] || exit 0
[ "$(cat "$endpoint/device" 2>/dev/null)" = 0x1007 ] || exit 0

command=$(setpci -s 0000:00:00.0 COMMAND.w)
buses=$(setpci -s 0000:00:00.0 18.l)
bar0=$(setpci -s 0000:01:00.0 10.l)
bar1=$(setpci -s 0000:01:00.0 14.l)
if [[ $command != 0507 || $buses != 00ff0100 || $bar0 != 22000004 || $bar1 != 00000000 ]]; then
  echo 'Skipping Gen1 retraining: PCI configuration differs; retain the existing recovery path'
  exit 0
fi

status=$(setpci -s 0000:00:00.0 CAP_EXP+12.w)
(( (16#$status & 15) != 1 )) || exit 0
if driver=$(readlink "$endpoint/driver" 2>/dev/null); then
  echo "Refusing to retrain an already bound device: $driver" >&2
  exit 1
fi

echo 'Retraining Cubie A5E NVMe PCIe link to Gen1'
setpci -s 0000:00:00.0 CAP_EXP+30.w=0001:000f CAP_EXP+10.w=0020:0020
for ((attempt = 0; attempt < 40; attempt++)); do
  status=$(setpci -s 0000:00:00.0 CAP_EXP+12.w)
  if (( (16#$status & 15) == 1 && (16#$status & 0x2800) == 0x2000 )); then
    [ "$(setpci -s 0000:00:00.0 COMMAND.w)" = "$command" ]
    [ "$(setpci -s 0000:00:00.0 18.l)" = "$buses" ]
    [ "$(setpci -s 0000:01:00.0 10.l)" = "$bar0" ]
    [ "$(setpci -s 0000:01:00.0 14.l)" = "$bar1" ]
    echo 'Gen1 link ready; PCI command, bus numbers and NVMe BAR preserved'
    exit 0
  fi
  sleep 0.05
done
echo 'Timed out waiting for a trained Gen1 link' >&2
exit 1
