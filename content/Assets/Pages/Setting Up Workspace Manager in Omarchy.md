---
title: Setting Up Workspace Manager for Paired Dual-Monitor Workspaces in Omarchy
tags:
  - Linux
  - Omarchy
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/set-up-alternative-workspace-plugin
banner: https://wallpapercave.com/wp/wp4700307.jpg
---
# Setting Up Workspace Manager for Paired Dual-Monitor Workspaces in Omarchy

## Goal

Configure Omarchy's **Workspace Manager** so that both monitors visually show the same logical workspaces:

```
Monitor 1:  1  2  3  4  5  6
Monitor 2:  1  2  3  4  5  6
```

Internally, Hyprland still uses separate workspace IDs:

```
Logical workspace 1 = Hyprland 1  + 11
Logical workspace 2 = Hyprland 2  + 12
Logical workspace 3 = Hyprland 3  + 13
Logical workspace 4 = Hyprland 4  + 14
Logical workspace 5 = Hyprland 5  + 15
Logical workspace 6 = Hyprland 6  + 16
```

This works well when `SUPER+1` through `SUPER+6` are already configured to switch the two monitors as linked pairs.

---

## 1. Install Workspace Manager

Run:

```
omarchy plugin add https://github.com/mangoleaf/omarchy-workspace-manager-plugin --enable
```

The plugin will be installed under:

```
~/.config/omarchy/plugins/mangoleaf.workspace-manager
```

---

## 2. Open Workspace Manager

Open the Workspace Manager configuration window.

Initially, the configuration may look approximately like this:

```
No.   Monitor      Hotkey
1     HDMI-A-1     SUPER + code:10
2     HDMI-A-1     SUPER + code:11
3     HDMI-A-1     SUPER + code:12
4     HDMI-A-1     SUPER + code:13
5     HDMI-A-1     SUPER + code:14
6     HDMI-A-1     SUPER + code:15

11    HDMI-A-2     click to set
12    HDMI-A-2     click to set
13    HDMI-A-2     click to set
14    HDMI-A-2     click to set
15    HDMI-A-2     click to set
16    HDMI-A-2     click to set
```

---

## 3. Change the Display Numbers on Monitor 2

The important point is that the **display number does not have to equal the real Hyprland workspace ID**.

Change:

```
11 → 1
12 → 2
13 → 3
14 → 4
15 → 5
16 → 6
```

The finished configuration should appear as:

|Display|Monitor|Hotkey|
|---|---|---|
|1|HDMI-A-1|SUPER + code:10|
|2|HDMI-A-1|SUPER + code:11|
|3|HDMI-A-1|SUPER + code:12|
|4|HDMI-A-1|SUPER + code:13|
|5|HDMI-A-1|SUPER + code:14|
|6|HDMI-A-1|SUPER + code:15|
|1|HDMI-A-2|click to set|
|2|HDMI-A-2|click to set|
|3|HDMI-A-2|click to set|
|4|HDMI-A-2|click to set|
|5|HDMI-A-2|click to set|
|6|HDMI-A-2|click to set|

The real second-monitor workspace IDs remain `11–16`; only their displayed numbers change.

---

## 4. Do Not Assign Separate Hotkeys to Monitor 2

Leave the second monitor entries as:

```
click to set
```

Do **not** assign:

```
SUPER+1
SUPER+2
...
```

to workspaces 11–16.

The existing paired-workspace configuration should remain responsible for switching both monitors together.

For example:

```
SUPER+1 → workspaces 1 + 11
SUPER+2 → workspaces 2 + 12
SUPER+3 → workspaces 3 + 13
SUPER+4 → workspaces 4 + 14
SUPER+5 → workspaces 5 + 15
SUPER+6 → workspaces 6 + 16
```

---

## 5. Do Not Click `Add to Hyprland`

Workspace Manager may display:

> Hyprland is not wired up yet

and offer an:

```
Add to Hyprland
```

button.

For this custom paired-workspace setup, **leave this alone**.

The existing Hyprland configuration already controls workspace switching. Allowing Workspace Manager to install its own workspace bindings could create duplicate or conflicting shortcuts.

Workspace Manager is therefore being used primarily for:

```
✓ displaying workspace numbers
✓ showing which workspace is active
✓ providing clearer workspace indicators
✓ presenting 1–6 consistently on both monitors
```

while the custom Hyprland configuration remains responsible for switching the paired workspaces.

---

## 6. Workspace Manager Configuration File

The plugin stores its workspace configuration here:

```
~/.config/hypr/workspaces.conf
```

A working configuration looks similar to:

```
rename|SUPER + SHIFT + F2
jump|SUPER + SHIFT + F3
editor|SUPER + SHIFT + F4
center|false
icons|3
style|plain
base|1
compact|false
number|true
delim|:
1|code:10|HDMI-A-1|||1
2|code:11|HDMI-A-1|||2
3|code:12|HDMI-A-1|||3
4|code:13|HDMI-A-1|||4
5|code:14|HDMI-A-1|||5
6|code:15|HDMI-A-1|||6
11||HDMI-A-2|||1
12||HDMI-A-2|||2
13||HDMI-A-2|||3
14||HDMI-A-2|||4
15||HDMI-A-2|||5
16||HDMI-A-2|||6
```

Notice the distinction:

```
Real ID     Display number

1           1
2           2
...
6           6

11          1
12          2
...
16          6
```

---

## 7. If a Workspace Hotkey Is Accidentally Changed

For example, Workspace 1 should normally contain:

```
1|code:10|HDMI-A-1|||1
```

The keyboard codes are:

```
1 = code:10
2 = code:11
3 = code:12
4 = code:13
5 = code:14
6 = code:15
```

If `SUPER+1` cannot be entered through the Workspace Manager GUI, Hyprland is probably intercepting the shortcut before the plugin can record it.

Edit the configuration file instead.

First back it up:

```
CONF="$HOME/.config/hypr/workspaces.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"

cp "$CONF" "$CONF.backup-$STAMP"
```

To restore workspace 1 and remove an accidental binding from workspace 11:

```
CONF="$HOME/.config/hypr/workspaces.conf"

python3 <<'PY'
from pathlib import Path

p = Path.home() / ".config/hypr/workspaces.conf"
lines = p.read_text().splitlines()

out = []

for line in lines:
    parts = line.split("|")

    if len(parts) == 6:
        wid = parts[0]

        if wid == "1":
            parts[1] = "code:10"
            line = "|".join(parts)

        elif wid == "11":
            parts[1] = ""
            line = "|".join(parts)

    out.append(line)

p.write_text("\n".join(out) + "\n")
PY
```

Verify:

```
grep -nE '^(1|11)\|' "$HOME/.config/hypr/workspaces.conf"
```

Expected result:

```
1|code:10|HDMI-A-1|||1
11||HDMI-A-2|||1
```

---

## 8. Verify the Complete Configuration

Run:

```
CONF="$HOME/.config/hypr/workspaces.conf"

echo "===== WORKSPACE CONFIG ====="
sed -n '1,30p' "$CONF"
```

The important workspace lines should be:

```
1|code:10|HDMI-A-1|||1
2|code:11|HDMI-A-1|||2
3|code:12|HDMI-A-1|||3
4|code:13|HDMI-A-1|||4
5|code:14|HDMI-A-1|||5
6|code:15|HDMI-A-1|||6

11||HDMI-A-2|||1
12||HDMI-A-2|||2
13||HDMI-A-2|||3
14||HDMI-A-2|||4
15||HDMI-A-2|||5
16||HDMI-A-2|||6
```

---

## Final Architecture

The setup has two separate responsibilities:

```
Workspace Manager
        ↓
Visual workspace display
1 2 3 4 5 6 on both monitors

Custom Hyprland workspace bindings
        ↓
Actual workspace switching
1↔11
2↔12
3↔13
4↔14
5↔15
6↔16
```

This gives the appearance and behavior of **six dual-monitor workspaces**, even though Hyprland internally requires a different workspace ID on each physical monitor.

### Important

Do not click **Add to Hyprland** unless the custom paired-workspace configuration is intentionally being replaced.