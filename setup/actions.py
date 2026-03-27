"""Step types for the interactive setup.

Each step type knows how to check whether it's already done and how to
execute itself (either automatically or by prompting the user).
"""

import os
import subprocess
from pathlib import Path
from typing import Callable, Optional


# ---------------------------------------------------------------------------
# Check helpers — used in steps.py as expect=[("desc", check), ...]
# ---------------------------------------------------------------------------

def path_exists(path: str) -> Callable[[], bool]:
    """True if the (~ expanded) path exists."""
    def check():
        return Path(path).expanduser().exists()
    return check


def any_path_exists(*paths: str) -> Callable[[], bool]:
    """True if any of the (~ expanded) paths exist."""
    def check():
        return any(Path(p).expanduser().exists() for p in paths)
    return check


def is_symlink_to(link: str, target: str) -> Callable[[], bool]:
    """True if link is a symlink pointing at target."""
    def check():
        lp = Path(link).expanduser()
        tp = Path(target).expanduser()
        try:
            return lp.is_symlink() and lp.resolve() == tp.resolve()
        except OSError:
            return False
    return check


def dir_not_empty(path: str) -> Callable[[], bool]:
    """True if the (~ expanded) directory exists and has contents."""
    def check():
        p = Path(path).expanduser()
        return p.is_dir() and any(p.iterdir())
    return check


def cmd_succeeds(*args: str) -> Callable[[], bool]:
    """True if the command exits 0."""
    def check():
        try:
            return subprocess.run(
                args, capture_output=True, timeout=10,
            ).returncode == 0
        except (OSError, subprocess.TimeoutExpired):
            return False
    return check


# Convenience for building expect lists
def expect_path(path: str, label: str = ""):
    """Single (label, check) tuple for use in expect=[]."""
    return (label or f"{path} exists", path_exists(path))


def expect_dir(path: str, label: str = ""):
    return (label or f"{path} is non-empty", dir_not_empty(path))


def dir_contains_copies(src: str, dest: str) -> Callable[[], bool]:
    """True if every file in src exists in dest with identical content."""
    import filecmp
    def check():
        sp = Path(src).expanduser()
        dp = Path(dest).expanduser()
        if not sp.is_dir() or not dp.is_dir():
            return False
        src_files = [f for f in sp.iterdir() if f.is_file()]
        if not src_files:
            return False
        return all(
            (dp / f.name).exists() and filecmp.cmp(f, dp / f.name, shallow=False)
            for f in src_files
        )
    return check


# ---------------------------------------------------------------------------
# Step types
# ---------------------------------------------------------------------------

Expectation = tuple[str, Callable[[], bool]]

class Section:
    """Visual grouping header — not a step, just structure."""
    def __init__(self, title: str):
        self.title = title


class Step:
    """Base class. Subclasses implement is_done() and execute().

    expect: list of (description, callable) assertions.
      - All pass  → is_done() returns True
      - Some pass → is_done() returns None, report() yields warnings
      - None pass → is_done() returns None
    """

    def __init__(self, description: str, detail: str = "",
                 done: Optional[Callable[[], bool]] = None,
                 expect: Optional[list[Expectation]] = None):
        self.description = description
        self.detail = detail
        self._done_check = done
        self._expect = expect or []

    def _eval_expectations(self) -> tuple[list[str], list[str]]:
        """Returns (passed, failed) description lists."""
        passed, failed = [], []
        for label, check in self._expect:
            (passed if check() else failed).append(label)
        return passed, failed

    def is_done(self) -> Optional[bool]:
        """True = skip, False = needs work, None = can't tell."""
        if self._done_check:
            return self._done_check()
        if self._expect:
            _, failed = self._eval_expectations()
            if not failed:
                return True
        return None

    def report(self, ui) -> None:
        """If expectations are partially met, warn about the failures."""
        if not self._expect:
            return
        passed, failed = self._eval_expectations()
        if passed and failed:
            for f in failed:
                ui.warn(f"Expected: {f}")

    def execute(self, ui: "Runner") -> bool:
        raise NotImplementedError


class Prompt(Step):
    """Requires the user to do something outside the terminal."""

    def execute(self, ui) -> bool:
        self.report(ui)
        while True:
            result = ui.prompt_user(self.description, self.detail,
                                    allow_retry=bool(self._expect))
            if result == "retry":
                # Re-check and re-report before prompting again
                self.report(ui)
                continue
            if not result:
                return False
            # User said done — verify expectations
            if not self._expect:
                return True
            _, failed = self._eval_expectations()
            if not failed:
                return True
            for f in failed:
                ui.warn(f"Still not met: {f}")
            ui.warn("Fix the issue above, then retry — or skip for now.")


class Symlink(Step):
    """Ensure a symlink exists. Automatic when the target is present."""

    def __init__(self, link: str, target: str, description: str = ""):
        self.link = link
        self.target = target
        desc = description or f"Link {link} -> {target}"
        super().__init__(desc, done=is_symlink_to(link, target))

    def execute(self, ui) -> bool:
        lp = Path(self.link).expanduser()
        tp = Path(self.target).expanduser()

        while not tp.exists():
            ui.warn(f"Target not found: {self.target}")
            result = ui.prompt_user(
                f"Make {self.target} available, then retry",
                "This may require syncing from Google Drive or copying from another machine.",
                allow_retry=True,
            )
            if result != "retry":
                return bool(result)

        while lp.exists() and not lp.is_symlink():
            ui.warn(f"{self.link} exists and is not a symlink")
            result = ui.prompt_user(
                f"Back up and remove {self.link}, then retry",
                allow_retry=True,
            )
            if result != "retry":
                return bool(result)

        if lp.is_symlink():
            old = os.readlink(lp)
            ui.warn(f"Replacing symlink {lp} (was -> {old})")
            lp.unlink()

        lp.parent.mkdir(parents=True, exist_ok=True)
        lp.symlink_to(tp)
        ui.done(f"Linked {lp} -> {tp}")
        return True


class EnsureDir(Step):
    """Create a directory if it doesn't exist."""

    def __init__(self, path: str, description: str = ""):
        self.path = path
        desc = description or f"Create {path}"
        super().__init__(desc, done=path_exists(path))

    def execute(self, ui) -> bool:
        p = Path(self.path).expanduser()
        p.mkdir(parents=True, exist_ok=True)
        ui.done(f"Created {p}")
        return True


class Run(Step):
    """Run a shell command (shown to user first)."""

    def __init__(self, description: str, command: list[str], **kwargs):
        self.command = command
        super().__init__(description, **kwargs)

    def execute(self, ui) -> bool:
        ui.info(f"Running: {' '.join(self.command)}")
        result = subprocess.run(self.command, cwd=Path.home())
        if result.returncode == 0:
            ui.done(self.description)
            return True
        else:
            ui.warn(f"Command exited with code {result.returncode}")
            return False


# ---------------------------------------------------------------------------
# Convenience constructors — keep steps.py readable
# ---------------------------------------------------------------------------

def section(title):          return Section(title)
def prompt(desc, detail="", *, done=None, expect=None):
    return Prompt(desc, detail, done=done, expect=expect)
def symlink(link, target):   return Symlink(link, target)
def ensure_dir(path):        return EnsureDir(path)
def run(desc, command, **kw): return Run(desc, command, **kw)
