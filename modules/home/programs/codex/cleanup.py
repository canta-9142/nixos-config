"""Retain two stable standalone releases, plus current and running releases."""

import fcntl
import os
from pathlib import Path
import re
import shutil


def cleanup(standalone, proc=Path("/proc")):
    releases = standalone / "releases"
    if not releases.is_dir():
        return

    with (standalone / "install.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return

        # Fail closed if the active installation cannot be resolved.
        current = (standalone / "current").resolve(strict=True)
        protected = {current}
        for process in proc.glob("[0-9]*"):
            try:
                if process.stat().st_uid != os.getuid():
                    continue
                try:
                    executable = (process / "exe").resolve(strict=True)
                except PermissionError:
                    # Non-dumpable processes such as systemd deny exe access.
                    # Still fail closed for an unreadable Codex process.
                    if (process / "comm").read_text().strip().startswith("codex"):
                        raise
                    continue
            except (FileNotFoundError, ProcessLookupError):
                continue
            protected.update(executable.parents)

        versions = []
        for release in releases.iterdir():
            match = re.fullmatch(
                r"(\d+)\.(\d+)\.(\d+)-(?:x86_64|aarch64)-unknown-linux-(?:musl|gnu)",
                release.name,
            )
            if match and not release.is_symlink() and release.is_dir():
                versions.append((tuple(map(int, match.groups())), release))

        for _, release in sorted(versions, reverse=True)[2:]:
            if release.resolve() not in protected:
                print(f"Removing {release}", flush=True)
                shutil.rmtree(release)


if __name__ == "__main__":
    cleanup(Path.home() / ".codex/packages/standalone")
