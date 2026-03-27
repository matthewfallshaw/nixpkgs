"""
Interactive setup steps for a new macOS machine.

Run after bootstrap.sh has installed Nix, Homebrew, and applied the
nix-darwin configuration.  Each step is idempotent — safe to re-run.

This file is the single source of truth for post-bootstrap setup.
Read it as a checklist; run it as a script.
"""

from .actions import (section, prompt, symlink, ensure_dir, run,
                      path_exists, any_path_exists, is_symlink_to,
                      dir_not_empty, dir_contains_copies, cmd_succeeds,
                      expect_path, expect_dir)


def all_steps(old_machine: str = "notnux6") -> list:
    old = old_machine  # short alias for interpolation
    return [

        # {{{ Services and cloud sync
        section("Services and cloud sync"),

        prompt("Sign into 1Password; enable SSH agent",
               "1Password -> Settings -> Developer -> Use the SSH agent",
               done=path_exists(
                   "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock")),

        prompt("Sign into Google Drive; enable offline sync",
               "Set offline: My Drive/system -> Right-click -> Available offline",
               expect=[
                   expect_path("~/matthew.fallshaw@gmail.com - Google Drive/My Drive",
                               "Google Drive mounted"),
                   expect_path("~/matthew.fallshaw@gmail.com - Google Drive/My Drive/system",
                               "system/ folder synced"),
               ]),

        # Google Drive for Desktop creates ~/email - Google Drive/My Drive/.
        # This symlink gives everything a stable ~/Google Drive/My Drive/ path.
        symlink("~/Google Drive",
                "~/matthew.fallshaw@gmail.com - Google Drive"),

        prompt("Enable iCloud Drive document and desktop sync",
               "System Settings -> iCloud -> iCloud Drive -> Sync this Mac\n"
               "This brings ~/Documents/system/ which has Quicksilver config, etc.\n"
               "WAIT for iCloud sync to fully complete before marking done —\n"
               "~/Documents/system/ must be populated (check Finder for download progress).",
               expect=[
                   expect_path("~/Documents/system", "~/Documents/system/ synced"),
               ]),

        prompt("Sign into Dropbox",
               expect=[
                   ("Dropbox folder exists",
                    any_path_exists("~/Dropbox", "~/Dropbox (Personal)",
                                    "~/Library/CloudStorage/Dropbox")),
               ]),
        prompt("Sign into Slack",
               "Preferences -> Themes -> Sync with OS settings",
               expect=[
                   expect_path("~/Library/Containers/com.tinyspeck.slackmacgap",
                               "Slack app data exists"),
               ]),
        prompt("Sign into Signal",
               "Link to phone; Appearance -> System; Notifications -> Neither name nor message",
               expect=[
                   expect_path("~/Library/Application Support/Signal", "Signal app data exists"),
               ]),
        prompt("Configure Messages",
               "iMessage: enable iCloud, send read receipts, start from m@fallshaw.me"),
        prompt("Set up Chrome profiles",
               "Tampermonkey: Advanced mode, Debug scripts, Script sync -> Google Drive\n"
               "Install chrome-tabs-finder (see ~/code/chrome-tabs-finder/README.md)\n"
               "Install themes from ~/code/chrome-theme-visible and ~/code/chrome-theme-red"),
        prompt("Sign into Keybase (add new device)",
               expect=[
                   expect_path("~/Library/Application Support/Keybase", "Keybase app data exists"),
               ]),
        # }}}

        # {{{ Dotfiles and configuration linking
        section("Dotfiles and configuration linking"),

        symlink("~/.hammerspoon",
                "~/code/hammerspoon-config"),

        symlink("~/Library/Application Support/Quicksilver",
                "~/Documents/system/Library/Application Support/Quicksilver"),

        symlink("~/Library/Application Support/Typinator",
                "~/Documents/system/Library/Application Support/Typinator"),

        symlink("~/Library/Application Support/Keycue",
                "~/Documents/system/Library/Application Support/Keycue"),

        symlink("~/Library/Application Support/SuperSlicer",
                "~/Google Drive/My Drive/system/Library/Application Support/SuperSlicer"),

        symlink("~/Library/Application Support/Dash",
                "~/Documents/system/Library/Application Support/Dash"),

        symlink("~/Library/Application Support/Cursor/User",
                "~/Documents/system/Library/Application Support/Cursor/User"),

        symlink("~/.claude",
                "~/Documents/system/.claude"),

        symlink("~/.claude.json",
                "~/Documents/system/.claude.json"),

        symlink("~/CAD",
                "~/Documents/CAD"),

        prompt("Configure Obsidian vault location",
               "Launch Obsidian and open your vault.\n"
               "Per-vault config lives in .obsidian/ inside the vault folder."),

        prompt("Configure iTerm2 preferences sync",
               "Settings -> General -> Settings -> Load from custom folder:\n"
               "~/Documents/system/Library/Application Support/iTerm2",
               expect=[
                   ("iTerm2 PrefsCustomFolder set",
                    cmd_succeeds("defaults", "read", "com.googlecode.iterm2",
                                 "PrefsCustomFolder")),
               ]),

        prompt("Copy managed LaunchAgents from iCloud",
               "cp ~/Documents/system/Library/LaunchAgents/com.matthewfallshaw.* "
               "~/Library/LaunchAgents/\n"
               "Then review in LaunchControl",
               expect=[
                   ("Managed LaunchAgents from iCloud present in ~/Library/LaunchAgents/",
                    dir_contains_copies(
                        "~/Documents/system/Library/LaunchAgents",
                        "~/Library/LaunchAgents")),
               ]),
        # }}}

        prompt(f"Audit {old} for unmanaged app config",
               f"Compare ~/Library/Application Support/ on {old} vs this machine.\n"
               "For each app config that isn't managed yet, run:\n"
               "  adopt-config ~/Library/Application\\ Support/<app>\n"
               "Also check ~/.config/ and ~/.<app> directories."),

        # }}}

        # {{{ Migration from old machine
        section("Migration from old machine"),

        prompt(f"rsync ~/code/ and ~/source/ from {old}",
               f"rsync -avP matt@{old}.local:~/code/ ~/code/\n"
               f"rsync -avP matt@{old}.local:~/source/ ~/source/\n"
               "These are git repos with possible uncommitted WIP.",
               expect=[
                   expect_dir("~/code", "~/code/ is non-empty"),
                   expect_dir("~/source", "~/source/ is non-empty"),
               ]),

        prompt(f"rsync ~/Pictures/ from {old}",
               f"rsync -avP --exclude='.DS_Store' matt@{old}.local:~/Pictures/ ~/Pictures/",
               expect=[
                   expect_dir("~/Pictures", "~/Pictures/ is non-empty"),
               ]),

        prompt(f"Review ~/ on {old} for anything else to bring over",
               f"ssh matt@{old}.local ls ~/\n"
               "Copy anything important not already covered by iCloud or the steps above.\n"
               "~/Documents/ and ~/Desktop/ are synced by iCloud."),

        # }}}

        # {{{ App permissions
        section("App permissions"),

        prompt("Grant Hammerspoon Accessibility permission",
               "System Settings -> Privacy & Security -> Accessibility"),
        prompt("Grant Karabiner Input Monitoring permission",
               "System Settings -> Privacy & Security -> Input Monitoring -> karabiner_grabber"),
        prompt("Grant iTerm2 Full Disk Access",
               "System Settings -> Privacy & Security -> Full Disk Access"),
        # }}}

        # {{{ Development tools
        section("Development tools"),

        prompt("Install lua-utf8 for Hammerspoon",
               "Hammerspoon bundles its own Lua — check where it looks for rocks\n"
               "and install lua-utf8 to the correct tree."),
               # FIXME: Not sure this is actually necessary, or how to do it.

        run("Install clipboard-scripts Ruby gems",
            ["bash", "-c", "cd ~/code/clipboard-scripts && bundle install"],
            done=path_exists("~/code/clipboard-scripts/vendor/bundle")),

        prompt("Set up chrome-tabs-finder",
               "Follow ~/code/chrome-tabs-finder/README.md:\n"
               "  1. chrome://extensions/ -> Developer mode -> Load unpacked\n"
               "  2. Note the extension ID\n"
               "  3. Update native-messaging-host JSON with the ID\n"
               "  4. Symlink the native messaging host and client",
               expect=[
                   expect_path("~/Library/Application Support/Google/Chrome/"
                               "NativeMessagingHosts/"
                               "com.matthewfallshaw.chrometabsfinder.json",
                               "Native messaging host registered"),
               ]),
        # }}}

        # {{{ App configuration
        section("App configuration"),

        prompt("Set up GPG keys",
               f"Export from {old}: gpg --export-secret-keys --armor > ~/keys.asc\n"
               "Transfer securely, then: gpg --import ~/keys.asc\n"
               "Delete the export file when done.",
               expect=[
                   ("GPG secret key present",
                    cmd_succeeds("gpg", "--list-secret-keys", "--batch")),
               ]),
               # FIXME: This does not ensure that **the right** GPG keys are actually present. This one must be manually confirmed.

        prompt("Set up Calibre library location",
               expect=[
                   expect_path("~/Library/Preferences/calibre", "Calibre prefs exist"),
               ]),
        prompt("Copy PrusaSlicer prefs from backup (prefs can't be symlinked)",
               expect=[
                   expect_dir("~/Library/Application Support/PrusaSlicer",
                              "PrusaSlicer prefs exist"),
               ]),
        prompt("Set up ScanSnap Home for scanner"),
        prompt("Configure Ubersicht",
               "Launch at login; widgets folder from Google Drive"),
        prompt("Configure Unison sync profiles"),
        prompt("Set up Logitech peripherals (Options, Camera Settings)"),
        prompt("Install Setapp apps",
               "https://my.setapp.com/subscription\n"
               "Set up Dash syncing; configure Bartender"),
        prompt("Launch Typinator and verify config loaded from Google Drive"),
        prompt(f"Copy ~/Library/Scripts and ~/Library/Services from {old}",
               expect=[
                   expect_dir("~/Library/Scripts", "~/Library/Scripts/ is non-empty"),
                   expect_dir("~/Library/Services", "~/Library/Services/ is non-empty"),
               ]),
        prompt("Run: parallel --citation",
               expect=[
                   expect_path("~/.parallel/will-cite", "parallel citation accepted"),
               ]),
        # }}}

        # {{{ System preferences not yet managed by nix
        section("System preferences (not yet in nix)"),

        prompt("Accessibility -> Speech -> Speaking Rate: Fast"),
        prompt("Keyboard -> Shortcuts -> Mission Control",
               "^1-6 for Desktops 1-6; F9-11 to shift-F9-11"),
        prompt("Keyboard -> Shortcuts -> Launchpad & Dock",
               "Disable 'Turn Dock Hiding On/Off'"),
        prompt("Keyboard -> Use keyboard navigation to move focus between controls"),
        prompt("Bluetooth -> Show in menu bar"),
        prompt("Security & Privacy -> Require password immediately after sleep"),
        prompt("Finder -> Sidebar",
               "home [x], machine name [x], hard disks [ ], recent tags [ ]"),
        prompt("Finder -> View: Show Preview, Show Status Bar"),
        prompt("Finder -> CMD+J: Show extra columns"),

        prompt("Set up Time Machine",
               "System Settings -> General -> Time Machine\n"
               "Select backup disk; wait for first backup to complete.\n"
               "Exclude /nix/store from backups:\n"
               "  sudo tmutil addexclusion -p /nix/store\n"
               "  sudo tmutil addexclusion -p /nix/var",
               expect=[
                   ("Time Machine has a backup destination",
                    cmd_succeeds("tmutil", "destinationinfo")),
               ]),
        # }}}
    ]
