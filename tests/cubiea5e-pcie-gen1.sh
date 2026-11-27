set -euo pipefail
script=$1
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
cat > "$temporary/fixture.sh" <<'FIXTURE'
cat() {
  case "$1" in
    /proc/device-tree/model) printf '%s' "${GEN1_MODEL:-Radxa Cubie A5E}" ;;
    */vendor) printf '0x1e95\n' ;;
    */device) printf '0x1007\n' ;;
    *) command cat "$@" ;;
  esac
}
readlink() { [ "$GEN1_CASE" = bound ] && printf '/drivers/nvme\n'; }
sleep() { :; }
setpci() {
  case "$*" in
    '-s 0000:00:00.0 COMMAND.w')
      if [ "$GEN1_CASE" = lost ]; then printf '0000\n'; else printf '0507\n'; fi ;;
    '-s 0000:00:00.0 18.l') printf '00ff0100\n' ;;
    '-s 0000:01:00.0 10.l')
      if [ "$GEN1_CASE" = changed ] && [ -e "$GEN1_WRITES" ]; then printf '00000004\n'; else printf '22000004\n'; fi ;;
    '-s 0000:01:00.0 14.l') printf '00000000\n' ;;
    '-s 0000:00:00.0 CAP_EXP+12.w')
      if [ "$GEN1_CASE" = already ]; then printf '3011\n'
      elif [ ! -e "$GEN1_WRITES" ]; then printf '3012\n'
      elif [ "$GEN1_CASE" = timeout ] || [ ! -e "$GEN1_POLLED" ]; then
        touch "$GEN1_POLLED"; printf '3811\n'
      else printf '7011\n'; fi ;;
    '-s 0000:00:00.0 CAP_EXP+30.w=0001:000f CAP_EXP+10.w=0020:0020')
      printf '%s\n' "$*" >> "$GEN1_WRITES" ;;
    *) printf 'Unexpected PCI access: %s\n' "$*" >&2; return 1 ;;
  esac
}
FIXTURE
export BASH_ENV="$temporary/fixture.sh"
export GEN1_WRITES="$temporary/writes"
export GEN1_POLLED="$temporary/polled"
bash -n "$script"
for GEN1_CASE in healthy already lost bound timeout changed; do
  export GEN1_CASE
  rm -f "$GEN1_WRITES" "$GEN1_POLLED"
  status=0
  bash "$script" > "$temporary/output" 2>&1 || status=$?
  case "$GEN1_CASE" in
    healthy)
      test "$status" -eq 0
      test "$(wc -l < "$GEN1_WRITES")" -eq 1
      test -e "$GEN1_POLLED"
      grep -Fq 'Gen1 link ready' "$temporary/output" ;;
    already|lost) test "$status" -eq 0; test ! -e "$GEN1_WRITES" ;;
    bound) test "$status" -ne 0; test ! -e "$GEN1_WRITES" ;;
    timeout|changed) test "$status" -ne 0; test -e "$GEN1_WRITES" ;;
  esac
done
rm -f "$GEN1_WRITES"
export GEN1_MODEL='Another board'
bash "$script"
test ! -e "$GEN1_WRITES"
