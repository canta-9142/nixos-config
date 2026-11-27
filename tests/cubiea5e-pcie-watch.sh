set -euo pipefail
watch_script=$1
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT

cat > "$temporary/fixture.sh" <<'FIXTURE'
stage=0
cat() {
  case "$1" in
    /proc/device-tree/model)
      printf '%s' "${WATCH_TEST_MODEL:-Radxa Cubie A5E}"
      ;;
    /proc/modules)
      if ((stage > 0)); then
        printf 'dwmac_sun8i 32768 0 - Live 0x0\n'
      fi
      ;;
    *) command cat "$@" ;;
  esac
}
setpci() {
  case "$*" in
    '-s 0000:00:00.0 COMMAND.w 18.l CAP_EXP+12.w')
      case "$stage" in
        0) printf '0107\n00ff0100\n3012\n' ;;
        1) printf '0000\n00000000\n3011\n' ;;
        3) return 1 ;;
        *) printf '0007\n00ff0100\n3011\n' ;;
      esac
      ;;
    '-s 0000:01:00.0 10.l 14.l')
      case "$stage" in
        1) printf '00000004\n00000000\n' ;;
        3) return 1 ;;
        *) printf '22000004\n00000000\n' ;;
      esac
      ;;
    *) return 1 ;;
  esac
}
sleep() { stage=$((stage + 1)); }
systemd-notify() {
  # Coldplug must not be released before the initial PCI state is recorded.
  [ "$(wc -l < "$PCIE_WATCH_LOG")" -eq 1 ]
  printf 'ready\n' > "$WATCH_TEST_READY"
}
FIXTURE

export BASH_ENV="$temporary/fixture.sh"
export PCIE_WATCH_LOG="$temporary/watch.log"
export WATCH_TEST_READY="$temporary/ready"
bash -n "$watch_script"
bash "$watch_script"
grep -Fxq ready "$WATCH_TEST_READY"
test "$(grep -c '^PCIe watch uptime=' "$PCIE_WATCH_LOG")" -eq 5
grep -Fq 'root=0107,00ff0100,3012, endpoint=22000004,00000000, modules=' "$PCIE_WATCH_LOG"
grep -Fq 'root=0000,00000000,3011, endpoint=00000004,00000000, modules=dwmac_sun8i,' "$PCIE_WATCH_LOG"
grep -Fq 'root=0007,00ff0100,3011, endpoint=22000004,00000000,' "$PCIE_WATCH_LOG"
grep -Fq 'root=unreadable endpoint=unreadable' "$PCIE_WATCH_LOG"
grep -Fxq 'PCIe watch stopped' "$PCIE_WATCH_LOG"

rm "$WATCH_TEST_READY"
export WATCH_TEST_MODEL='Another board'
export PCIE_WATCH_LOG="$temporary/other-board.log"
bash "$watch_script"
test ! -e "$PCIE_WATCH_LOG"
test ! -e "$WATCH_TEST_READY"
