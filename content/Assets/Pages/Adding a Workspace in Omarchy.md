---
title: Adding a Workspace in Omarchy
tags:
  - Linux
  - Omarchy
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/adding-a-workspace-in-omarchy
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---

# Adding a Workspace in Omarchy

This setup automatically detects the current number of linked workspaces in Omarchy/Hyprland and adds **one additional linked workspace pair**.

For example:

- Workspace 1 → `1 + 11`
- Workspace 2 → `2 + 12`
- Workspace 3 → `3 + 13`
- Workspace 4 → `4 + 14`
- Workspace 5 → `5 + 15`
- Workspace 6 → `6 + 16`

Running the script again will automatically add the next pair.

## Add the Next Workspace

Paste the following entire block into the terminal:

```
HYPR="$HOME/.config/hypr"
LINKED="$HYPR/linked-workspaces.lua"
MONITORS="$HYPR/monitors.lua"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "===== CURRENT LINKED WORKSPACES ====="

CURRENT=$(grep -oP 'local PAIRS = \K[0-9]+' "$LINKED")

if [ -z "$CURRENT" ]; then
    echo "ERROR: Could not determine current PAIRS value."
    exit 1
fi

NEXT=$((CURRENT + 1))

echo "Current workspace pairs: $CURRENT"
echo "Adding workspace pair:    $NEXT"
echo "New pair will be:         $NEXT + $((NEXT + 10))"

echo
echo "===== BACKUP CONFIGURATION ====="

cp "$LINKED" "$LINKED.backup-$STAMP"
cp "$MONITORS" "$MONITORS.backup-$STAMP"

echo "Backups created."

echo
echo "===== UPDATE LINKED WORKSPACES ====="

sed -i \
    "s/local PAIRS = $CURRENT/local PAIRS = $NEXT/" \
    "$LINKED"

sed -i \
    "s/for pair = 1, $CURRENT do/for pair = 1, $NEXT do/" \
    "$MONITORS"

echo
echo "===== VERIFY CHANGES ====="

grep -n 'PAIRS' "$LINKED"
grep -n 'for pair' "$MONITORS"

echo
echo "===== RELOAD HYPRLAND ====="

hyprctl reload

echo
echo "===== CONFIGURATION ERRORS ====="

hyprctl configerrors

echo
echo "===== DONE ====="

echo "Added logical workspace $NEXT"
echo "Left monitor:  workspace $NEXT"
echo "Right monitor: workspace $((NEXT + 10))"

echo
echo "Switch to it with:"
echo " 
```