set -euo pipefail

[ "$(cat /proc/device-tree/model 2>/dev/null | tr -d '\000')" = 'Radxa Cubie A5E' ] || exit 0

# These logs contain PCI configuration and module names, not credentials.
umask 022
log=${PCIE_WATCH_LOG:-/run/cubiea5e-pcie-watch.log}
: > "$log"
previous=

emit() {
  printf '%s\n' "$1"
  printf '%s\n' "$1" >> "$log"
}

snapshot() {
  local start end _idle root endpoint modules state
  read -r start _idle < /proc/uptime
  root=$(setpci -s 0000:00:00.0 COMMAND.w 18.l CAP_EXP+12.w 2>/dev/null | tr '\n' ',') || root=unreadable
  endpoint=$(setpci -s 0000:01:00.0 10.l 14.l 2>/dev/null | tr '\n' ',') || endpoint=unreadable
  modules=$(cat /proc/modules | cut -d ' ' -f 1 | tr '\n' ',')
  read -r end _idle < /proc/uptime
  state="root=$root endpoint=$endpoint modules=$modules"
  if [ "$state" != "$previous" ]; then
    emit "PCIe watch uptime=$start..$end $state"
    previous=$state
  fi
}

trap 'emit "PCIe watch stopped"' EXIT
trap 'exit 0' TERM INT

# Type=notify keeps coldplug and modules-load behind this first snapshot.
snapshot
systemd-notify --ready
for ((attempt = 0; attempt < 200; attempt++)); do
  sleep 0.1
  snapshot
done
