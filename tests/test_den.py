"""Exercise identity and privilege boundaries without Nix builds or activation."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "den.sh"


class DenTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.home = root / "home with spaces"
        repo = self.home / ".config" / "den"
        repo.mkdir(parents=True)
        (repo / "flake.nix").write_text("{}")
        self.log = root / "calls.jsonl"
        self.bin = root / "bin"
        self.bin.mkdir()
        self.env = dict(os.environ, HOME=str(self.home),
                        PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        TEST_LOG=str(self.log), DEN_USER="stale", DEN_HOME="/stale")
        self.mock("id", 'if [[ "$1" == -u ]]; then echo "${TEST_UID:-501}"; else echo testuser; fi')
        self.mock("uname", 'echo "${TEST_OS:-Darwin}"')
        # These commands record arguments only; sudo never executes anything.
        recorder = '''import json, os, sys
with open(os.environ["TEST_LOG"], "a") as out:
    out.write(json.dumps([sys.argv, os.environ.get("DEN_USER"), os.environ.get("DEN_HOME")]) + "\\n")
if os.path.basename(sys.argv[0]) == "nix" and "build" in sys.argv:
    print("/nix/store/mock-rebuild")
'''
        import sys
        for name in ("nix", "sudo"):
            target = self.bin / name
            target.write_text(f"#!{sys.executable}\n" + recorder)
            target.chmod(0o755)

    def mock(self, name, body):
        target = self.bin / name
        target.write_text("#!/bin/bash\n" + body + "\n")
        target.chmod(0o755)

    def run_den(self, *args):
        return subprocess.run(["/bin/bash", str(SCRIPT), *args], env=self.env,
                              capture_output=True, text=True)

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_switch_captures_identity_before_sudo_and_bootstraps(self):
        result = self.run_den("switch", "macbook")
        self.assertEqual(result.returncode, 0, result.stderr)
        build, sudo = self.calls()
        self.assertIn("--no-update-lock-file", build[0])
        self.assertIn("DEN_USER=testuser", sudo[0])
        self.assertIn("DEN_HOME=" + str(self.home), sudo[0])
        self.assertIn("/nix/store/mock-rebuild/bin/darwin-rebuild", sudo[0])
        self.assertEqual(sudo[0][-1], str(self.home / ".config/den") + "#macbook")

    def test_check_exports_local_identity(self):
        result = self.run_den("check")
        self.assertEqual(result.returncode, 0, result.stderr)
        call, = self.calls()
        self.assertEqual(call[1:], ["testuser", str(self.home)])
        self.assertIn("--no-update-lock-file", call[0])

    def test_root_cannot_switch(self):
        self.env["TEST_UID"] = "0"
        self.assertNotEqual(self.run_den("switch", "macbook").returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_invalid_host_cannot_reach_sudo(self):
        self.assertNotEqual(self.run_den("switch", "bad#host").returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_unsupported_os_cannot_reach_sudo(self):
        self.env["TEST_OS"] = "FreeBSD"
        self.assertNotEqual(self.run_den("switch", "macbook").returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_failed_build_cannot_reach_sudo(self):
        self.mock("nix", "exit 1")
        self.assertNotEqual(self.run_den("switch", "macbook").returncode, 0)
        self.assertEqual(self.calls(), [])


if __name__ == "__main__":
    unittest.main()
