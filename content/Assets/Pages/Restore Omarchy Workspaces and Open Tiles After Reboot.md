---
title: |-
  Restore Omarchy Workspaces and Open Tiles After Reboot

  ## Goal
tags:
  - Linux
  - Omarchy
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/restore-omarchy-workspaces-and-open-tiles-after-reboot
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Restore Omarchy Workspaces and Open Tiles After Reboot

## Goal

Configure Omarchy so that after rebooting, Hyprland recreates the applications and tiled layouts that were open across your workspaces.

This setup uses **Omarchy Reanimate**.

Reanimate saves information such as:

- open applications
- workspace assignments
- monitor assignments
- tiled window arrangement
- split ratios
- floating-window geometry
- terminal working directories
- previously focused workspace

It does **not** hibernate applications or preserve unsaved data. Applications are closed and relaunched during the next session.

---
## Example Setup

In this example, the system has two monitors:

```
HDMI-A-1
  Workspace 1
  Workspace 2
  Workspace 3

HDMI-A-2
  Workspace 11
  Workspace 12
  Workspace 13
```

A typical session might look like:

```
Workspace 1  → Microsoft Edge

Workspace 2  → Teams | Terminal
                         50/50 split

Workspace 3  → Thunderbird

Workspace 11 → Obsidian

Workspace 12 → ChatGPT web app

Workspace 13 → Microsoft Edge
```

The goal is to recreate this arrangement automatically after reboot.

---
# 1. Install Reanimate

Run:

```
omarchy plugin add https://github.com/scottharvey/omarchy-reanimate.git --enable
```

Then run its installer:

```
~/.config/omarchy/plugins/io.github.scottharvey.reanimate/install.sh
```

A successful installation should report something similar to:

```
Installed post-boot hook:
~/.config/omarchy/hooks/post-boot.d/11-reanimate

Installed. Periodic saves every 2 minutes are now running.
```

The installation also creates and enables:

```
omarchy-reanimate-save.timer
```

---
# 2. Verify the Reanimate Timer

Run:

```
echo "===== REANIMATE TIMER ====="
systemctl --user is-active omarchy-reanimate-save.timer
```

Expected result:

```
active
```

This means Reanimate is periodically saving the current desktop session.

---

# 3. Save the Current Workspace Layout Manually

Run:

```
omarchy-reanimate-save
```

Example result:

```
Saved 7 window(s) across 6 workspace(s)
```

Then inspect the saved state:

```
omarchy-reanimate-show
```

Example:

```
dwindle layout · 7 windows · 6 workspaces

workspace 1 on HDMI-A-1
  microsoft-edge

workspace 2 on HDMI-A-1
  teams-for-linux
  foot

  layout
    └─ side by side 50/50

workspace 3 on HDMI-A-1
  org.mozilla.Thunderbird

workspace 11 on HDMI-A-2
  md.obsidian.Obsidian

workspace 12 on HDMI-A-2
  msedge-chatgpt.com__-Default

workspace 13 on HDMI-A-2
  microsoft-edge
```

This confirms that Reanimate can see the applications, monitors, workspaces, and tile geometry.

---

# 4. Test Restoration Without Changing Anything

Before rebooting, run a dry-run:

```
omarchy-reanimate-restore --dry-run
echo "Exit status: $?"
```

A successful result is:

```
Exit status: 0
```

This indicates that Reanimate considers the stored session restorable.

---

# 5. Add Reanimate to the Omarchy System Menu

Reanimate can modify the normal Omarchy **Reboot** and **Shutdown** actions so that a fresh session snapshot is taken immediately before powering off.

This is preferable to relying only on the automatic two-minute timer.

First inspect the supplied menu configuration:

```
cat ~/.config/omarchy/plugins/io.github.scottharvey.reanimate/extensions/omarchy-menu-snippet.jsonc
```

Also inspect the current Omarchy extension file:

```
cat ~/.config/omarchy/extensions/omarchy-menu.jsonc
```

---

# 6. Back Up the Existing Menu Configuration

Before modifying it:

```
MENU="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
STAMP="$(date +%Y%m%d-%H%M%S)"

cp -a "$MENU" "$MENU.backup-$STAMP"

echo "Backup: $MENU.backup-$STAMP"
```

Example:

```
Backup:
/home/ben/.config/omarchy/extensions/omarchy-menu.jsonc.backup-20261001-100132
```

---

# 7. Add the Reanimate Menu Entries

Run:

```
MENU="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

python3 <<'PY'
from pathlib import Path

p = Path.home() / ".config/omarchy/extensions/omarchy-menu.jsonc"
text = p.read_text()

if '"system.session-save"' in text:
    print("Reanimate entries already present. No changes made.")
    raise SystemExit

entries = '''  "system.session-save": {
    "icon": "󰆓",
    "label": "Save Session",
    "description": "Save windows, workspaces and tiling for the next boot",
    "action": "~/.config/omarchy/plugins/io.github.scottharvey.reanimate/bin/omarchy-reanimate-save --quiet && notify-send 'Session saved' 'Windows and layout will be restored on next boot'"
  },
  "system.reboot": {
    "icon": "󰜉",
    "label": "Reboot",
    "action": "~/.config/omarchy/plugins/io.github.scottharvey.reanimate/bin/omarchy-reanimate-save --quiet --quit-browsers; omarchy-system-reboot"
  },
  "system.shutdown": {
    "icon": "󰐥",
    "label": "Shutdown",
    "action": "~/.config/omarchy/plugins/io.github.scottharvey.reanimate/bin/omarchy-reanimate-save --quiet --quit-browsers; omarchy-system-shutdown"
  }
'''

pos = text.rfind("}")

if pos == -1:
    raise SystemExit("ERROR: Could not find closing } in omarchy-menu.jsonc")

text = text[:pos].rstrip() + "\n\n" + entries + "}\n"
p.write_text(text)

print(f"Updated: {p}")
PY
```

Refresh the Omarchy menu:

```
omarchy menu refresh
```

Expected result:

```
ok
```

---

# 8. Verify the Menu Entries

Run:

```
grep -A5 -B1 -n \
'system.session-save\|system.reboot\|system.shutdown' \
"$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
```

You should see:

```
system.session-save
system.reboot
system.shutdown
```

The Omarchy **System** menu should now contain:

```
Save Session
Reboot
Shutdown
```

---

# 9. How the New Reboot Process Works

When selecting:

```
Omarchy Menu
→ System
→ Reboot
```

Reanimate first runs:

```
omarchy-reanimate-save --quiet --quit-browsers
```

Then Omarchy performs the reboot.

Conceptually:

```
Current desktop
      ↓
Save session
      ↓
Cleanly close browsers
      ↓
Reboot
      ↓
Hyprland starts
      ↓
Reanimate post-boot hook runs
      ↓
Applications relaunched
      ↓
Windows moved to saved workspaces
      ↓
Tile layout reconstructed
```

Use the Omarchy menu's **Reboot** or **Shutdown** commands rather than issuing a plain `reboot` command when you want the freshest possible snapshot.

---

# 10. Test the Restore

Before rebooting, save any unsaved documents.

Then use:

```
Omarchy Menu
→ System
→ Reboot
```

After logging back in, inspect the windows:

```
hyprctl clients
```

For a more concise view:

```
hyprctl clients -j | jq -r \
'.[] | "workspace \(.workspace.id): \(.class) — \(.title)"' \
| sort -n
```

A successful restore may look like:

```
workspace 1: microsoft-edge
workspace 2: foot
workspace 2: teams-for-linux
workspace 3: org.mozilla.Thunderbird
workspace 11: md.obsidian.Obsidian
workspace 12: msedge-chatgpt.com__-Default
workspace 13: microsoft-edge
```

---

# 11. Verify the Saved Session

Run:

```
omarchy-reanimate-show
```

Example:

```
dwindle layout · 7 windows · 6 workspaces

workspace 1 on HDMI-A-1
  microsoft-edge

workspace 2 on HDMI-A-1
  teams-for-linux
  foot

  layout
    └─ side by side 50/50

workspace 3 on HDMI-A-1
  org.mozilla.Thunderbird

workspace 11 on HDMI-A-2
  md.obsidian.Obsidian

workspace 12 on HDMI-A-2
  msedge-chatgpt.com__-Default

workspace 13 on HDMI-A-2
  microsoft-edge
```

A particularly useful test is a workspace containing multiple tiles.

For example, workspace 2:

```
┌────────────────────┬────────────────────┐
│                    │                    │
│       Teams        │      Terminal      │
│                    │                    │
│                    │                    │
└────────────────────┴────────────────────┘
              50 / 50
```

If both applications return to workspace 2 with the same split, the layout reconstruction is working.

---

# 12. Check for Restore Differences

Reanimate includes a comparison command:

```
omarchy-reanimate-diff
echo "Exit status: $?"
```

This can identify differences between the saved session and the restored desktop.

This is useful when an application launches an additional window during startup.

---

# 13. Browser Caveat

Chromium-based browsers such as Microsoft Edge can occasionally open an additional window when restoring their own internal browser session.

For example, after one reboot the restored desktop contained:

```
workspace 3:
  Thunderbird
  Microsoft Edge — New tab
```

even though only Thunderbird had originally been saved there.

This occurs because two restoration systems are interacting:

```
Reanimate
    +
Edge's own session restoration
```

If an unwanted Edge window appears, close it normally or use:

```
hyprctl dispatch closewindow 'class:microsoft-edge,title:New tab'
```

Then save a fresh session:

```
omarchy-reanimate-save
```

Confirm:

```
omarchy-reanimate-show
```

---

# 14. Manual Session Save

At any time, use:

```
omarchy-reanimate-save
```

or select:

```
Omarchy Menu
→ System
→ Save Session
```

The menu command also displays a notification confirming that the session was saved.

---

# 15. Useful Diagnostic Commands

## Check timer

```
systemctl --user is-active omarchy-reanimate-save.timer
```

Expected:

```
active
```

## Save session

```
omarchy-reanimate-save
```

## Show saved session

```
omarchy-reanimate-show
```

## Dry-run restoration

```
omarchy-reanimate-restore --dry-run
echo $?
```

Expected:

```
0
```

## Compare restored and saved sessions

```
omarchy-reanimate-diff
```

## List windows by workspace

```
hyprctl clients -j | jq -r \
'.[] | "workspace \(.workspace.id): \(.class) — \(.title)"' \
| sort -n
```

## Refresh Omarchy menu

```
omarchy menu refresh
```

---

# 16. Important Limitations

Reanimate restores the **desktop layout**, not the actual suspended operating-system session.

It can recreate:

```
✓ applications
✓ workspace assignments
✓ monitor assignments
✓ tiled layouts
✓ split ratios
✓ floating windows
✓ terminal working directories
```

It does not guarantee restoration of:

```
✗ unsaved document changes
✗ unsent messages
✗ partially completed forms
✗ exact application memory state
✗ terminal process state
```

Applications such as Edge, Thunderbird, Teams, and Obsidian are restarted normally.

Always save important work before rebooting.

---

# Final Result

With this configuration, Omarchy can reboot and reconstruct a multi-monitor Hyprland session such as:

```
HDMI-A-1                         HDMI-A-2

Workspace 1                     Workspace 11
┌──────────────────┐            ┌──────────────────┐
│       Edge       │            │     Obsidian     │
└──────────────────┘            └──────────────────┘

Workspace 2                     Workspace 12
┌─────────┬────────┐            ┌──────────────────┐
│  Teams  │  foot  │            │     ChatGPT      │
│         │        │            │     Web App      │
└─────────┴────────┘            └──────────────────┘

Workspace 3                     Workspace 13
┌──────────────────┐            ┌──────────────────┐
│   Thunderbird    │            │       Edge       │
└──────────────────┘            └──────────────────┘
```

The most important confirmation is that a multi-window workspace such as **Teams + terminal in a 50/50 split** returns correctly after reboot.

At that point, Reanimate is successfully preserving the practical workspace experience across Omarchy restarts.