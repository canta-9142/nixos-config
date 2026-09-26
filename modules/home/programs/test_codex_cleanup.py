"""Run with: python3 -m unittest discover -s modules/home/programs -p 'test_*.py'."""

import fcntl
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "codex_cleanup", Path(__file__).with_name("codex-cleanup.py")
)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class CleanupTest(unittest.TestCase):
    def test_retention_and_protection(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            releases = root / "releases"
            proc = root / "proc"
            proc.mkdir()
            versions = {}
            for version in ("0.9.0", "0.10.0", "0.11.0", "0.12.0", "0.13.0"):
                release = releases / f"{version}-x86_64-unknown-linux-musl"
                (release / "bin").mkdir(parents=True)
                (release / "bin/codex").touch()
                versions[version] = release
            (root / "current").symlink_to(versions["0.10.0"])
            (proc / "123").mkdir()
            (proc / "123/exe").symlink_to(versions["0.11.0"] / "bin/codex")
            unknown = releases / "unfinished-download"
            unknown.mkdir()
            link = releases / "0.1.0-x86_64-unknown-linux-musl"
            link.symlink_to(unknown)

            with (root / "install.lock").open("a") as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                module.cleanup(root, proc)
                self.assertTrue(versions["0.9.0"].exists())

            module.cleanup(root, proc)
            self.assertFalse(versions["0.9.0"].exists())
            for version in ("0.10.0", "0.11.0", "0.12.0", "0.13.0"):
                self.assertTrue(versions[version].exists())
            self.assertTrue(unknown.exists())
            self.assertTrue(link.is_symlink())

            resolve = Path.resolve

            def deny_exe(path, *args, **kwargs):
                if path == proc / "123/exe":
                    raise PermissionError(path)
                return resolve(path, *args, **kwargs)

            (proc / "123/comm").write_text("systemd\n")
            with patch.object(Path, "resolve", deny_exe):
                module.cleanup(root, proc)
                (proc / "123/comm").write_text("codex\n")
                with self.assertRaises(PermissionError):
                    module.cleanup(root, proc)

            (root / "current").unlink()
            (root / "current").symlink_to(versions["0.13.0"])
            (proc / "123/exe").unlink()
            module.cleanup(root, proc)
            self.assertFalse(versions["0.10.0"].exists())
            self.assertFalse(versions["0.11.0"].exists())
            self.assertTrue(versions["0.12.0"].exists())
            self.assertTrue(versions["0.13.0"].exists())

    def test_missing_installation(self):
        with tempfile.TemporaryDirectory() as tmp:
            module.cleanup(Path(tmp))


if __name__ == "__main__":
    unittest.main()
