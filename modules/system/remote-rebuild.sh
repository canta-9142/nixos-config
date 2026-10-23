# Called by the nsr / nbr Fish functions; additional arguments go to nh.
case "${1:-}" in
  switch|boot) action="$1"; shift ;;
  *) echo "Usage: nixos-remote-rebuild {switch|boot} [nh options...]" >&2; exit 2 ;;
esac

source_dir="$HOME/nixos-config"
host="jinji@ryzen.home.arpa"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-remote-rebuild"
mkdir -p "$cache_dir"
# Both functions share one remote mirror, so serialize their sync/build/copy.
exec 9> "$cache_dir/lock"
flock -n 9 || { echo 'A remote rebuild is already running.' >&2; exit 1; }
local_dir=$(mktemp -d "$cache_dir/run.XXXXXXXXXX")
trap 'rm -rf -- "$local_dir"' EXIT

remote_dir=$(ssh "$host" 'mkdir -p ~/.cache/nixos-remote-rebuild/laptop && realpath ~/.cache/nixos-remote-rebuild/laptop')

# Include uncommitted changes and new files, but omit ignored files and .git.
# Stage with hard links to avoid copying file data on the same filesystem.
# Mirroring the whole snapshot also removes deleted or newly ignored files.
git -C "$source_dir" ls-files --cached --others --exclude-standard -z > "$local_dir/files"
rsync -a --from0 --files-from="$local_dir/files" --ignore-missing-args \
  --link-dest="$source_dir" "$source_dir/" "$local_dir/source/"
rsync -a --delete "$local_dir/source/" "$host:$remote_dir/source/"

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
