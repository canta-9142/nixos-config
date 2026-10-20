# Called by the ns / nb Fish functions; additional arguments go to nh.
case "${1:-}" in
  switch|boot) action="$1"; shift ;;
  *) echo "Usage: nixos-remote-rebuild {switch|boot} [nh options...]" >&2; exit 2 ;;
esac

source_dir="$HOME/nixos-config"
host="jinji@ryzen.home.arpa"
local_dir=$(mktemp -d)
remote_dir=""
cleanup() {
  if [[ -n "$remote_dir" ]]; then
    # Expand the directory returned by the remote mktemp on this client.
    # shellcheck disable=SC2029
    ssh "$host" "rm -rf -- '$remote_dir'" || true
  fi
  rm -rf -- "$local_dir"
}
trap cleanup EXIT

remote_dir=$(ssh "$host" 'mktemp -d /tmp/nixos-config.XXXXXXXXXX')

# Include uncommitted changes and new files, but omit ignored files and .git.
# Deleted tracked files are absent from this fresh snapshot.
git -C "$source_dir" ls-files --cached --others --exclude-standard -z > "$local_dir/files"
rsync -a --from0 --files-from="$local_dir/files" --ignore-missing-args \
  "$source_dir/" "$host:$remote_dir/source/"

# shellcheck disable=SC2029
result=$(ssh "$host" "sh -s -- '$remote_dir'" <<'REMOTE'
set -eu
nix build --accept-flake-config --no-update-lock-file \
  --out-link "$1/result" --print-out-paths \
  "$1/source#nixosConfigurations.nixos.config.system.build.toplevel"
REMOTE
)

# Interactive builds are unsigned; trust the pinned SSH identity of Ryzen.
nix copy --from "ssh-ng://$host" --no-check-sigs "$result"
# Keep the copied system GC-rooted while nh applies it. Lix's nix copy does
# not support --out-link, so register the local root separately.
nix-store --realise "$result" --add-root "$local_dir/result" --indirect > /dev/null
nh os "$action" "$local_dir/result" "$@"
