# Bootstrap and setup

## Quick start

1. Clone this repo to `~/.config/nixpkgs`
2. Run `./bootstrap.sh` — installs Nix, Homebrew, applies nix-darwin config, creates ~/bin
3. Bootstrap hands off to `python3 -m setup` for interactive post-bootstrap steps (app sign-ins, config linking, permissions)

Both scripts are idempotent — safe to re-run at any point.

## What lives where

- **nix config** (`darwin/`, `home/`, `modules/`): Packages, system defaults, shell config, services — anything declarative and machine-independent
- **bootstrap.sh**: Automated first-run setup (Nix, Homebrew, darwin-rebuild, Claude Code install, ~/bin creation)
- **setup/** (`python3 -m setup`): Interactive post-bootstrap steps that need a human (sign into services, grant permissions, link config from cloud drives). Read `setup/steps.py` for the full list.
- **adopt-config** (`~/.local/bin/adopt-config`): Put an app's config under iCloud management. See `README.md` for details.

----

Below this line: work-in-progress for the notnux6 → notnux7 migration.

Rules:
- Avoid snowflakes — automate in nix, bootstrap.sh, or setup/ instead of running one-off commands
- Public repo — no secrets
- Keep this file current so we can clear conversation context and resume from here
- Use subagents for exploration that consumes lots of context
- SSH to notnux6.local is available for investigating the old system's setup

## Current work: LaunchAgents management overhaul

### Problem

The LaunchAgent backup system has been silently failing/drifting:
- The live plist on notnux6 backs up to **iCloud Documents** (`~/Documents/system/Library/LaunchAgents/`), not GDrive
- The GDrive copy (`~/Google Drive/My Drive/system/Library/LaunchAgents/`) is stale and should be cleaned up
- The old `rsync -a --delete` mirrors ALL agents (Dropbox, Setapp, Huion, etc.) — we only want to manage `com.matthewfallshaw.*` agents
- `steps.py` references GDrive and its check passes incorrectly when unrelated agents populate the directory

### Design: two agents sharing a namespace

**`com.matthewfallshaw.sync.launchagents`** (building now):
- Bidirectional sync of managed agents via `~/Documents/system/Library/LaunchAgents/` (iCloud)
- The cloud directory is the manifest — every file in it is managed
- New `com.matthewfallshaw.*` files in `~/Library/LaunchAgents/` are auto-enrolled (copied to cloud)
- Files in cloud dir not matching `com.matthewfallshaw.*` are an error → logged to stderr
- Newest file (by mtime) wins for content
- On sync: rewrite `StandardErrorPath`/`StandardOutPath` to `~/.local/state/launchagents/logs/<label>.err` (and `.out`)
- Load/unload logic respects the `Disabled` plist key and the launchctl override database:
  - New file synced down, not disabled → `launchctl load`
  - New file synced down, `Disabled` is true → copy only, don't load
  - Updated file, agent was loaded → `launchctl unload` + `load` to pick up changes
  - Never touch the override database — user's `launchctl disable` decisions are respected
- Triggered by WatchPaths on both `~/Library/LaunchAgents` and `~/Documents/system/Library/LaunchAgents`

**`com.matthewfallshaw.healthcheck.launchagents`** (future work):
- Byte-offset tracking per `.err` file — only alerts on new content since last check
- Scans all managed LaunchAgents to ensure they write stderr to `~/.local/state/launchagents/logs/`
- Emails alerts (depends on postfix being configured — see postfix item below)
- Falls back to macOS notifications only if email delivery fails
- Triggered by WatchPaths on the logs directory and/or periodic schedule

### File locations (following XDG/FHS conventions, already in use on this system)

```
~/.local/
├── libexec/
│   └── launchagents/
│       ├── sync.sh                # sync agent script
│       └── healthcheck.sh         # future: healthcheck script
└── state/
    └── launchagents/
        ├── logs/                  # all managed agents log here
        │   ├── <label>.err
        │   └── <label>.out
        └── healthcheck/           # future: byte-offset state
            └── offsets
```

### Path strategy

Cloud provider paths change and we don't control them. For each cloud location:
- **iCloud**: use `~/Documents/system/` — macOS handles iCloud sync behind this stable path
- **GDrive**: `~/Google Drive` symlink (created in `setup/steps.py`) points to `~/matthew.fallshaw@gmail.com - Google Drive`
- Never reference raw `~/Library/CloudStorage/...` paths in scripts

Known issue: `~/Google Drive` symlink disappears on reboot (cause TBD). Consider managing via home-manager activation script. Not blocking since LaunchAgents are moving to iCloud.

### Implementation status

- [x] SSH access to notnux6 configured (`home/ssh.nix` — `IdentitiesOnly yes` + `IdentityFile`)
- [ ] **Write sync script** to `~/.local/libexec/launchagents/sync.sh`
- [ ] **Write sync agent plist** — calls sync.sh, watches both dirs, logs to `~/.local/state/launchagents/logs/`
  - Note: the old plist used `fdautil exec` for Full Disk Access. Need to determine if fdautil is still needed (it failed with the new script due to allowlist mismatch — may need `fdautil set` or may not need FDA at all for these paths)
- [ ] **Deploy to notnux6** — install new plist + script, reload via LaunchControl.
  - Current state: the old `rsync --delete` agent has been unloaded and replaced with a WIP plist at `notnux6:~/Library/LaunchAgents/com.matthewfallshaw.backup.launchagents.plist`. It is currently non-functional (fdautil rejects the inline script). No backup agent is running on notnux6 — acceptable since we're migrating off it.
  - `fdautil` is a LaunchControl tool (`com.soma-zone.LaunchControl.fdautil`). Its allowlist is managed by LaunchControl. Extracting the script to a file (`~/.local/libexec/launchagents/sync.sh`) and updating the plist to call that should fix the allowlist issue — then confirm the new command in LaunchControl.
  - notnux6 uses `~/GoogleDrive` (no space, from 2022) not `~/Google Drive` — path conventions differ from notnux7.
- [ ] **Clean up iCloud sync dir on notnux6** — remove non-`com.matthewfallshaw.*` files from `~/Documents/system/Library/LaunchAgents/` (they remain in `~/Library/LaunchAgents/`)
- [ ] **Clean up stale GDrive copy** — remove contents of `~/Google Drive/My Drive/system/Library/LaunchAgents/` on notnux7
- [ ] **Update `setup/steps.py`** — LaunchAgents step references iCloud Documents, uses `dir_contains_copies` check
- [ ] **Deploy to notnux7** — copy sync plist + script, load agent, verify managed agents sync down
- [ ] Future: healthcheck agent (see design above)
- [ ] Future: postfix email delivery (needed by healthcheck and cron jobs)

## Pending investigation

- [x] SSH `IdentitiesOnly` config — done for notnux6/notnux7 in `home/ssh.nix`. Other hosts (homeassistant, octopixl, bear, leadcnc) don't have it yet. Consider `~/.config/1Password/ssh/agent.toml` for coarse-grained filtering.
- [ ] SSHFS replacement: macfuse.github.io or FUSE-T
- [ ] Self-updating apps vs Homebrew cask read-only installs
- [ ] Keychain migration: `SecKeychainSearchCopyNext` errors on notnux6. Also causing `security:` error on every SSH command from notnux7 — likely fish config calling `security` for a credential in notnux6's login keychain.
- [ ] PATH for GUI apps (QS, Obsidian): QS sees only `/usr/bin:/bin:/usr/sbin:/sbin`. This also causes QS "command line tool not found" warning and Ruby/clipboard-scripts failures when triggered from QS.
  - Fix: `sudo launchctl config user path "$PATH"` (run from zsh, not fish, so `$PATH` is colon-separated). This writes to `/private/var/db/com.apple.xpc.launchd/config/user.plist` and persists across reboots. Requires reboot to take effect.
  - Confirmed working on notnux6 — `launchctl getenv PATH` shows the full nix PATH there. notnux7 doesn't have it yet (no `user.plist` exists).
  - Ideally should run on every `darwin-rebuild switch` so GUI PATH stays in sync with nix PATH. Best candidate: nix-darwin activation script (runs with sudo, has access to the full PATH at activation time). Fallback: `bootstrap.sh`.
  - Caveat: the PATH is a snapshot at the time the command runs. If nix adds new paths later, they won't appear in the launchctl config until re-run. Acceptable since the important paths (`~/.nix-profile/bin`, `/run/current-system/sw/bin`) are stable.
- [ ] Overpass font: https://github.com/RedHatOfficial/Overpass — install via nix?
- [ ] Hammerspoon luarocks: figure out correct install tree for `lua-utf8` (Hammerspoon bundles its own Lua)
- [ ] Tame scattered symlinked config (Google Drive, iCloud Documents) — partially addressed by LaunchAgents move to iCloud

## Migration status — notnux7 (2026-03-27)

### Nix config changes (not yet committed or rebuilt)
- [ ] **Login shell**: Need `users.users.matt.shell = pkgs.fish;`
- [ ] **Chrome defaults**: ExternalProtocolDialogShowAlwaysOpenCheckbox, URLWhitelist for hammerspoon://
- [ ] **Dock**: showhidden = true
- [ ] **~/.forward**: home.file
- [ ] **~/log, ~/tmp**: home.file or similar
- [ ] **Finder**: status bar, search current folder, bin after 30 days, folders on top
- [ ] **Keyboard**: F1-F12 standard, backlight timeout, input source viewer

### Cursor/nvim config
- Cursor config: `~/Library/Application Support/Cursor/User/` → iCloud via `adopt-config` (step added to `steps.py`)
- nvim config: already managed via `mkOutOfStoreSymlink` in `config-files.nix`
- Cursor extensions: reinstall on each machine (platform-compiled, can't sync). Use `cursor --list-extensions` / `cursor --install-extension`.

### Investigate
- Typinator: installed via Homebrew, config migration from notnux6 needed
- 1Password settings: turn off autosubmit — add as a prompt step in `steps.py`
- Unknown app origins: Evernote, `gh` (GitHub CLI) — where are these being installed from?
- Setapp: needs to be added to setup flow — when in the sequence?

### Ruby / clipboard-scripts
- 42/58 scripts use Ruby; needs gems (activesupport, titlecase, humanize, bluecloth)
- Ruby is in nix home.packages; `bundle install` in the repo is sufficient
- No need for rbenv or pyenv

### Unsorted
- Bartender (Setapp) config migration from notnux6
- conf repo (Bellroy email alias config, still recently used)
- Tampermonkey userscripts — still maintaining
- Meshmixer — still need, manual download from Autodesk
- Postfix config — needed for cron job email delivery and future LaunchAgent healthcheck alerts
- Login keychain from notnux6 — should items be moved to iCloud keychain? manually migrated?
- Review remaining items in ~/ on notnux6 and copy if important
- CLAUDE.md from notnux6 — bring over or put under nix management (now that `~/.claude/` is iCloud-managed via `steps.py`)
- `~/.claude/` and `~/.claude.json` — added to steps.py as iCloud symlinks. No Anthropic-provided sync.