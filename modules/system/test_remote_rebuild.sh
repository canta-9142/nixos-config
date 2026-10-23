#!/usr/bin/env bash
# Run with: bash modules/system/test_remote_rebuild.sh
set -euo pipefail
script=$(realpath "$(dirname "$0")/remote-rebuild.sh")
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
export TEST_ROOT="$test_root" REAL_RSYNC
REAL_RSYNC=$(command -v rsync)
export HOME="$test_root/home"
export XDG_CACHE_HOME="$HOME/.cache"
remote_dir="$test_root/remote-home/.cache/nixos-remote-rebuild/laptop"
mkdir -p "$HOME/nixos-config" "$test_root/bin" "$test_root/system" "$test_root/remote-home"
git -C "$HOME/nixos-config" init -q
printf 'ignored\n' > "$HOME/nixos-config/.gitignore"
touch "$HOME/nixos-config/tracked" "$HOME/nixos-config/deleted"
git -C "$HOME/nixos-config" add .
rm "$HOME/nixos-config/deleted"
printf 'uncommitted\n' > "$HOME/nixos-config/tracked"
touch "$HOME/nixos-config/new" "$HOME/nixos-config/ignored" \
  "$HOME/nixos-config/obsolete-untracked" "$HOME/nixos-config/now-ignored"

cat > "$test_root/bin/record" <<'MOCK'
printf '%s\n' "$1" >> "$TEST_ROOT/log"
if [[ "${TEST_FAIL:-}" == "$1" ]]; then exit 42; fi
MOCK
cat > "$test_root/bin/ssh" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == jinji@ryzen.home.arpa ]]
case "$2" in
  'mkdir -p '*)
    source record connect
    HOME="$TEST_ROOT/remote-home" sh -c "$2"
    ;;
  *) source record build; sh -c "$2" ;;
esac
MOCK
cat > "$test_root/bin/rsync" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
destination="${!#}"
if [[ "$destination" == jinji@ryzen.home.arpa:* ]]; then
  source record sync
  exec "$REAL_RSYNC" --itemize-changes "${@:1:$#-1}" "${destination#*:}" >> "$TEST_ROOT/transfers"
else
  source record snapshot
  exec "$REAL_RSYNC" "$@"
fi
MOCK
cat > "$test_root/bin/nix" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  build)
    installable="${!#}"
    snapshot="${installable%#*}"
    [[ "$installable" == *'#nixosConfigurations.nixos.config.system.build.toplevel' ]]
    [[ "$(cat "$snapshot/tracked")" == "${TEST_CONTENT:-uncommitted}" ]]
    [[ -f "$snapshot/new" && ! -e "$snapshot/ignored" && ! -e "$snapshot/deleted" && ! -e "$snapshot/.git" ]]
    if [[ "${TEST_PRUNED:-}" == 1 ]]; then
      [[ ! -e "$snapshot/obsolete-untracked" && ! -e "$snapshot/now-ignored" ]]
    fi
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
  for TEST_FAIL in '' connect snapshot sync build copy root activate; do
    export TEST_FAIL
    : > "$test_root/log"
    if bash -euo pipefail "$script" "$TEST_ACTION" --ask; then
      [[ -z "$TEST_FAIL" ]]
      [[ "$(cat "$test_root/log")" == $'connect\nsnapshot\nsync\nbuild\ncopy\nroot\nactivate' ]]
    else
      [[ "$?" == 42 && -n "$TEST_FAIL" ]]
      if [[ "$TEST_FAIL" != activate ]]; then
        ! grep -qx activate "$test_root/log"
      fi
    fi
    [[ -z "$(find "$XDG_CACHE_HOME/nixos-remote-rebuild" -maxdepth 1 -name 'run.*' -print)" ]]
    [[ -f "$remote_dir/source/tracked" ]]
  done
done

# An unchanged second run must reuse the mirror without transferring file data.
export TEST_FAIL=''
: > "$test_root/transfers"
bash -euo pipefail "$script" "$TEST_ACTION" --ask
! grep -q '^>f' "$test_root/transfers"

# Changes, deletions, and files that become ignored must update that same mirror.
export TEST_CONTENT='changed uncommitted' TEST_PRUNED=1
printf '%s\n' "$TEST_CONTENT" > "$HOME/nixos-config/tracked"
rm "$HOME/nixos-config/obsolete-untracked"
printf 'now-ignored\n' >> "$HOME/nixos-config/.gitignore"
: > "$test_root/transfers"
bash -euo pipefail "$script" "$TEST_ACTION" --ask
grep -q '^>f.* tracked$' "$test_root/transfers"
[[ -f "$remote_dir/source/tracked" ]]

# A second caller must stop before touching the shared remote mirror.
: > "$test_root/log"
if flock "$XDG_CACHE_HOME/nixos-remote-rebuild/lock" bash -euo pipefail "$script" "$TEST_ACTION" --ask; then
  exit 1
fi
[[ ! -s "$test_root/log" ]]
echo 'Remote rebuild: persistent incremental sync, pruning, locking, and failure handling passed.'
