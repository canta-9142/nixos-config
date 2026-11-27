set -eu
export PATH=/bin

# Temporary diagnostic destination; never mount another disk as a fallback.
mountpoint=/run/cubiea5e-debug-usb
device=/dev/disk/by-uuid/9F30-F9CD
for module in uas nls_cp437 nls_iso8859-1; do
  modprobe "$module"
done
for ((attempt = 0; attempt < 30; attempt++)); do
  # Do not scan other disks: an unresponsive NVMe can block blkid itself.
  if [ -b "$device" ]; then
    break
  fi
  sleep 1
done
[ -b "$device" ] || exit 0
mkdir -p "$mountpoint"
mount -t vfat -o rw,noatime "$device" "$mountpoint"
trap 'sync; umount "$mountpoint"' EXIT
output=$(mktemp -d "$mountpoint/cubiea5e-boot-XXXXXXXX")

# pcie_aspm=off leaves firmware settings intact, so clear those for this trial.
case " $(cat /proc/cmdline) " in
  *" pcie_aspm=off "*)
    if [ -r /proc/device-tree/model ] &&
      [ "$(tr -d '\000' < /proc/device-tree/model)" = 'Radxa Cubie A5E' ]; then
      for pci_device in 0000:01:00.0 0000:00:00.0; do
        printf '%s Link Control before: ' "$pci_device"
        setpci -s "$pci_device" CAP_EXP+10.w
        setpci -s "$pci_device" CAP_EXP+10.w=0:3
        printf '%s Link Control after: ' "$pci_device"
        setpci -s "$pci_device" CAP_EXP+10.w
      done > "$output/aspm.txt" 2>&1
    fi
    ;;
esac

snapshot_pcie() {
  {
    cat /proc/uptime
    cat /proc/interrupts
    # These physical addresses belong to this board's PCIe controller only.
    if [ -r /proc/device-tree/model ] &&
      [ "$(tr -d '\000' < /proc/device-tree/model)" = 'Radxa Cubie A5E' ]; then
      for address in 0x04800820 0x04800824 0x04c00e00 0x04c00e08; do
        printf '%s: ' "$address"
        timeout -k 1 2 devmem "$address" 32 || true
      done
      for ((bank = 0; bank < 8; bank++)); do
        for ((reg = 0; reg < 3; reg++)); do
          address=$((0x04800828 + bank * 12 + reg * 4))
          printf '0x%08x: ' "$address"
          timeout -k 1 2 devmem "$address" 32 || true
        done
      done
    fi
    timeout -k 1 5 lspci -vv -s 01:00.0 || true
  } > "$output/pcie.txt.new" 2>&1
  mv "$output/pcie.txt.new" "$output/pcie.txt"
}

cat /proc/cmdline > "$output/cmdline.txt"
cat /proc/sys/kernel/random/boot_id > "$output/boot-id.txt"
dmesg > "$output/dmesg.txt"
snapshot_pcie
cp "$output/pcie.txt" "$output/pcie-initial.txt"
sync -f "$output"

while true; do
  dmesg > "$output/dmesg.txt.new"
  mv "$output/dmesg.txt.new" "$output/dmesg.txt"
  {
    cat /proc/uptime
    timeout -k 1 5 ip -details link || true
    timeout -k 1 5 ip -br address || true
    timeout -k 1 5 lsblk -f || true
    cat /proc/modules
    for file in /sys/class/net/*/operstate /sys/class/net/*/carrier; do
      printf '\n%s\n' "$file"
      timeout -k 1 5 cat "$file" || true
    done
    if [ -r /sys/kernel/debug/devices_deferred ]; then
      cat /sys/kernel/debug/devices_deferred
    fi
    timeout 5 systemctl --no-pager --full status \
      systemd-modules-load systemd-udevd systemd-networkd sshd sysroot.mount || true
    timeout 5 systemctl --no-pager --failed || true
  } > "$output/status.txt.new" 2>&1
  mv "$output/status.txt.new" "$output/status.txt"
  timeout 5 journalctl -b --no-pager -o short-monotonic \
    > "$output/journal.txt.new" 2>&1 || true
  mv "$output/journal.txt.new" "$output/journal.txt"
  snapshot_pcie
  sync -f "$output"
  sleep 5
done
