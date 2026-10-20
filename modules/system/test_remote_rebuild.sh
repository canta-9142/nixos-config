#!/usr/bin/env bash
# Run with: bash modules/system/test_remote_rebuild.sh
set -euo pipefail
script=$(realpath "$(dirname "$0")/remote-rebuild.sh")
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
export TEST_ROOT="$test_root" REAL_RSYNC
REAL_RSYNC=$(command -v rsync)
export HOME="$test_root/home"
mkdir -p "$HOME/nixos-config" "$test_root/bin" "$test_root/system"
git -C "$HOME/nixos-config" init -q
printf 'ignored\n' > "$HOME/nixos-config/.gitignore"
touch "$HOME/nixos-config/tracked" "$HOME/nixos-config/deleted"
git -C "$HOME/nixos-config" add .
rm "$HOME/nixos-config/deleted"
printf 'uncommitted\n' > "$HOME/nixos-config/tracked"
touch "$HOME/nixos-config/new" "$HOME/nixos-config/ignored"

cat > "$test_root/bin/record" <<'MOCK'
printf '%s\n' "$1" >> "$TEST_ROOT/log"
if [[ "${TEST_FAIL:-}" == "$1" ]]; then exit 42; fi
MOCK
cat > "$test_root/bin/ssh" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == jinji@ryzen.home.arpa ]]
case "$2" in
  'mktemp -d '*)
    source record connect
    mktemp -d "$TEST_ROOT/remote.XXXXXXXXXX"
    ;;
  'rm -rf '*) source record cleanup; sh -c "$2" ;;
  *) source record build; sh -c "$2" ;;
esac
MOCK
cat > "$test_root/bin/rsync" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
source record sync
destination="${!#}"
exec "$REAL_RSYNC" "${@:1:$#-1}" "${destination#*:}"
MOCK
cat > "$test_root/bin/nix" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  build)
    installable="${!#}"
    snapshot="${installable%#*}"
    [[ "$installable" == *'#nixosConfigurations.nixos.config.system.build.toplevel' ]]
    [[ "$(cat "$snapshot/tracked")" == uncommitted ]]
    [[ -f "$snapshot/new" && ! -e "$snapshot/ignored" && ! -e "$snapshot/deleted" && ! -e "$snapshot/.git" ]]
    printf '/nix/store/00000000000000000000000000000000-nixos-system-test\n'
    ;;
  copy)
    source record copy
    [[ "$3" == ssh-ng://jinji@ryzen.home.arpa && "$4" == --no-check-sigs ]]
    [[ "$5" == /nix/store/*-nixos-system-test ]]
    ;;
  *) exit 1 ;;
esac
MOCK
cat > "$test_root/bin/nix-store" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
source record root
[[ "$1" == --realise && "$2" == /nix/store/*-nixos-system-test && "$3" == --add-root && "$5" == --indirect ]]
ln -s "$TEST_ROOT/system" "$4"
MOCK
cat > "$test_root/bin/nh" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
source record activate
[[ "$1" == os && "$2" == "$TEST_ACTION" && -L "$3" && "$4" == --ask ]]
MOCK
chmod +x "$test_root/bin/"{ssh,rsync,nix,nix-store,nh}
export PATH="$test_root/bin:$PATH"

for TEST_ACTION in switch boot; do
  export TEST_ACTION
  for TEST_FAIL in '' connect sync build copy root activate; do
    export TEST_FAIL
    : > "$test_root/log"
    if bash -euo pipefail "$script" "$TEST_ACTION" --ask; then
      [[ -z "$TEST_FAIL" ]]
      [[ "$(cat "$test_root/log")" == $'connect\nsync\nbuild\ncopy\nroot\nactivate\ncleanup' ]]
    else
      [[ "$?" == 42 && -n "$TEST_FAIL" ]]
      if [[ "$TEST_FAIL" != activate ]]; then
        ! grep -qx activate "$test_root/log"
      fi
    fi
    [[ -z "$(find "$test_root" -maxdepth 1 -name 'remote.*' -print)" ]]
  done
done
echo 'Remote rebuild: switch/boot, snapshots, argument forwarding, and failure cleanup passed.'
