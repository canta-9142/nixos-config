"""Run with a patched scripts/kconfig/conf binary; needs gcc and ccache on PATH."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile


def run(*args, cwd, env):
    return subprocess.check_output(args, cwd=cwd, env=env, text=True)


def check(conf):
    with tempfile.TemporaryDirectory(prefix="kconfig-ccache-test-") as directory:
        root = Path(directory)
        (root / "ccache.conf").touch()
        (root / "probe.c").write_text(
            '#include "include/generated/autoconf.h"\n'
            "int probe(void) { return CONFIG_CACHE_TEST_VALUE; }\n"
        )
        env = {
            key: value
            for key, value in os.environ.items()
            if not key.startswith(("CCACHE_", "KCONFIG_"))
        }
        env.update(CCACHE_DIR=str(root / "cache"), CCACHE_CONFIGPATH=str(root / "ccache.conf"))
        previous = None
        for version, value in (("7.3.4", 42), ("7.3.5", 42), ("7.3.5", 43)):
            (root / "Kconfig").write_text(
                f'mainmenu "Linux/x86_64 {version} Kernel Configuration"\n'
                'config CACHE_TEST_VALUE\n\tint "Probe value"\n\tdefault 42\n'
            )
            (root / ".config").write_text(f"CONFIG_CACHE_TEST_VALUE={value}\n")
            run(conf, "--olddefconfig", "Kconfig", cwd=root, env=env)
            run(conf, "--syncconfig", "Kconfig", cwd=root, env=env)
            header = (root / "include/generated/autoconf.h").read_bytes()
            assert b"Linux Kernel Configuration" in header
            assert f"#define CONFIG_CACHE_TEST_VALUE {value}\n".encode() in header
            assert version in (root / ".config").read_text()
            assert version in (root / "include/config/auto.conf").read_text()
            run("ccache", "gcc", "-c", "probe.c", "-o", "probe.o", cwd=root, env=env)
            stats = dict(
                line.split()
                for line in run("ccache", "--print-stats", cwd=root, env=env).splitlines()
            )
            object_bytes = (root / "probe.o").read_bytes()
            if previous:
                old_value, old_header, old_object, old_stats = previous
                if value == old_value:
                    assert header == old_header
                    assert object_bytes == old_object
                    assert int(stats["direct_cache_hit"]) == int(old_stats["direct_cache_hit"]) + 1
                    assert stats["cache_miss"] == old_stats["cache_miss"]
                else:
                    assert header != old_header
                    assert object_bytes != old_object
                    assert int(stats["cache_miss"]) == int(old_stats["cache_miss"]) + 1
            previous = value, header, object_bytes, stats
    print("PASS: stable headings, direct cache reuse, and configuration invalidation")


if __name__ == "__main__":
    check(str(Path(sys.argv[1]).resolve()))
