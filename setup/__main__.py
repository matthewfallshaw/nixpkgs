"""Interactive setup for a new macOS machine.

Run after bootstrap.sh:  python3 -m setup
"""

from pathlib import Path

from .runner import Runner
from .steps import all_steps

STATE_DIR = Path(__file__).resolve().parent.parent
OLD_MACHINE_FILE = STATE_DIR / ".setup-old-machine"


def get_old_machine() -> str:
    """Read or ask for the hostname of the machine we're migrating from."""
    if OLD_MACHINE_FILE.exists():
        name = OLD_MACHINE_FILE.read_text().strip()
        if name:
            return name

    print("What machine are you migrating from?")
    print("(This is saved to .setup-old-machine for future runs.)")
    while True:
        try:
            name = input("  Hostname: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            raise SystemExit(1)
        if name:
            OLD_MACHINE_FILE.write_text(name + "\n")
            return name
        print("  Please enter a hostname.")


def main() -> None:
    print("\n\033[1mInteractive macOS setup\033[0m")
    print("Each step can be [d]one, [s]kipped, or [a]borted.")
    print("Already-completed steps are detected and skipped automatically.\n")

    old_machine = get_old_machine()
    runner = Runner(all_steps(old_machine=old_machine))
    runner.run()


if __name__ == "__main__":
    main()
