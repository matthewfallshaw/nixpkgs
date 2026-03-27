"""Step execution engine with skip/done/abort interaction."""

import sys
from pathlib import Path
from .actions import Step, Section


# ANSI escapes
BOLD  = "\033[1m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED   = "\033[31m"
CYAN  = "\033[36m"
DIM   = "\033[2m"
RESET = "\033[0m"

PROGRESS_FILE = Path(__file__).resolve().parent.parent / ".setup-progress"


class Runner:
    def __init__(self, steps):
        self.steps = steps
        self.completed = 0
        self.skipped = 0
        self.total = sum(1 for s in steps if isinstance(s, Step))
        self._done_descs = self._load_progress()

    # -- Progress persistence --

    def _load_progress(self):
        """Load set of step descriptions previously marked done."""
        if not PROGRESS_FILE.exists():
            return set()
        return set(line.strip() for line in PROGRESS_FILE.read_text().splitlines()
                   if line.strip())

    def _save_done(self, description):
        """Append a step description to the progress file."""
        self._done_descs.add(description)
        with PROGRESS_FILE.open("a") as f:
            f.write(description + "\n")

    # -- Output helpers (used by step.execute()) --

    def done(self, msg):
        print(f"  {GREEN}+{RESET} {msg}")

    def info(self, msg):
        print(f"  {DIM}{msg}{RESET}")

    def warn(self, msg):
        print(f"  {YELLOW}!{RESET} {msg}")

    def error(self, msg):
        print(f"  {RED}x{RESET} {msg}", file=sys.stderr)

    def prompt_user(self, description, detail="", *, allow_retry=False):
        """Ask the user to perform a manual action.

        Returns True (done), False (skip), or "retry" if allow_retry is set.
        """
        if detail:
            for line in detail.strip().split("\n"):
                print(f"    {DIM}{line}{RESET}")
        retry_opt = f" / [{CYAN}r{RESET}]etry" if allow_retry else ""
        while True:
            try:
                choice = input(
                    f"    [{GREEN}d{RESET}]one"
                    f" / [{YELLOW}s{RESET}]kip"
                    f"{retry_opt}"
                    f" / [{RED}a{RESET}]bort? "
                ).strip().lower()
            except (EOFError, KeyboardInterrupt):
                print()
                raise SystemExit(1)

            if choice in ("d", "done"):
                return True
            if choice in ("s", "skip"):
                return False
            if choice in ("a", "abort"):
                raise SystemExit(1)
            if allow_retry and choice in ("r", "retry"):
                return "retry"

    # -- Main loop --

    def run(self):
        step_num = 0

        for item in self.steps:
            if isinstance(item, Section):
                print(f"\n{BOLD}{CYAN}-- {item.title} --{RESET}\n")
                continue

            step_num += 1
            prefix = f"  [{step_num}/{self.total}]"

            # Check programmatic done first, then progress file
            status = item.is_done()
            if status is True or item.description in self._done_descs:
                print(f"{prefix} {GREEN}v{RESET} {DIM}{item.description}{RESET}")
                self.completed += 1
                continue

            print(f"{prefix} {BOLD}{item.description}{RESET}")
            if item.execute(self):
                self.completed += 1
                self._save_done(item.description)
            else:
                self.skipped += 1

        pending = self.total - self.completed - self.skipped
        parts = [f"{self.completed} completed", f"{self.skipped} skipped"]
        if pending:
            parts.append(f"{pending} pending")
        print(f"\n{BOLD}Summary:{RESET} {', '.join(parts)}")
        if self.skipped:
            print(f"{DIM}Re-run to retry skipped steps.{RESET}")
