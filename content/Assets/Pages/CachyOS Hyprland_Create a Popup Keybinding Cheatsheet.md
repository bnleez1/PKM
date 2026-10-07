---
title: CachyOS Hyprland_Create a Popup Keybinding Cheatsheet
tags:
  - Linux
  - CachyOS
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/cachyos-hyprland-create-a-popup-keybinding-cheatsheet
banner: https://wallpapercave.com/wp/wp2506793.jpg
---
# CachyOS Hyprland: Create a Floating Keybinding Cheatsheet

This tutorial creates a floating **Hyprland keybinding cheatsheet** that you can open with a keyboard shortcut and close with `q`.

It is based on a CachyOS Hyprland setup using Lua configuration files under:

```
~/.config/hypr/
├── hyprland.lua
└── config/
    ├── binds.lua
    ├── inputs.lua
    ├── windowrules.lua
    └── ...
```

The final setup uses:

```
~/.local/bin/hyprkeys
```

to generate the cheatsheet,

```
~/.local/bin/hyprkeys-popup
```

to open it in a floating Kitty window,

and:

```
SUPER + F12
```

to display it.

Using `Super + F12` proved more reliable than trying to bind `Super + /`, especially with a Spanish (Latin America) keyboard layout.

---

## 1. Create the cheatsheet command

First make sure your personal binary directory exists:

```
mkdir -p ~/.local/bin
```

Create the cheatsheet:

```
cat > ~/.local/bin/hyprkeys <<'EOF'
#!/usr/bin/env bash

cat <<'CHEATSHEET'

============================================================
                 CACHYOS HYPRLAND KEYBINDINGS
============================================================

APPLICATIONS
------------------------------------------------------------
SUPER + Return              Terminal
SUPER + E                   File manager
SUPER + W                   Browser
SUPER + T                   Text editor
SUPER + C                   Calculator
SUPER + Space               App launcher

WINDOWS
------------------------------------------------------------
SUPER + Q                   Close active window
SUPER + ALT + Space         Toggle floating
SUPER + F                   Fullscreen
SUPER + D                   Maximize/fullscreen mode
SUPER + J                   Toggle split direction
ALT + Tab                   Cycle windows
SUPER + Tab                 Window switcher

FOCUS
------------------------------------------------------------
SUPER + Left                Focus left
SUPER + Right               Focus right
SUPER + Up                  Focus up
SUPER + Down                Focus down

MOVE WINDOWS
------------------------------------------------------------
SUPER + SHIFT + Left        Move window left
SUPER + SHIFT + Right       Move window right
SUPER + SHIFT + Up          Move window up
SUPER + SHIFT + Down        Move window down

WORKSPACES
------------------------------------------------------------
SUPER + CTRL + Left         Previous workspace
SUPER + CTRL + Right        Next workspace
SUPER + CTRL + Down         Next empty workspace

SUPER + S                   Toggle special workspace
SUPER + SHIFT + S           Move window to special workspace

NOCTALIA
------------------------------------------------------------
SUPER + Z                   Noctalia settings
SUPER + X                   Control center
SUPER + Space               Launcher
SUPER + V                   Clipboard
SUPER + A                   Notifications
SUPER + SHIFT + W           Wallpaper selector
SUPER + ALT + C             Session menu

SCREENSHOTS
------------------------------------------------------------
Print                       Region screenshot
SUPER + Print               Fullscreen screenshot

COLOR PICKER
------------------------------------------------------------
SUPER + P                   Pick screen color

MEDIA
------------------------------------------------------------
Media Play/Pause            Play / pause
Media Next                  Next track
Media Previous              Previous track
Volume Up                   Increase volume
Volume Down                 Decrease volume
Volume Mute                 Mute audio

OBSIDIAN / GITHUB
------------------------------------------------------------
SUPER + SHIFT + O           Pull vault + open Obsidian
SUPER + SHIFT + ALT + O     Close Obsidian + push vault
                            + publish Quartz website

SYSTEM
------------------------------------------------------------
SUPER + L                   Lock session
SUPER + Escape              Kill application

CHEATSHEET
------------------------------------------------------------
SUPER + F12                 Show this popup cheatsheet

============================================================
Actual configuration:
~/.config/hypr/config/binds.lua

Press q to close this cheatsheet.
============================================================

CHEATSHEET
EOF

chmod +x ~/.local/bin/hyprkeys
```

Test it:

```
~/.local/bin/hyprkeys
```

You should see the cheatsheet printed directly in the terminal.

---

## 2. Create the popup launcher

The popup will use Kitty and `less`.

First verify Kitty exists:

```
command -v kitty
```

You should get something similar to:

```
/usr/bin/kitty
```

Now create the popup launcher:

```
cat > ~/.local/bin/hyprkeys-popup <<'EOF'
#!/usr/bin/env bash

exec kitty \
  --class hyprkeys-popup \
  --title "Hyprland Keybindings" \
  bash -c '/home/ben/.local/bin/hyprkeys | less -R'
EOF

chmod +x ~/.local/bin/hyprkeys-popup
```

Test it manually:

```
~/.local/bin/hyprkeys-popup
```

A Kitty window should open showing the cheatsheet.

Press:

```
q
```

to close it.

### Why the absolute path matters

Use:

```
/home/ben/.local/bin/hyprkeys
```

inside the popup launcher instead of simply:

```
hyprkeys
```

Hyprland-launched processes may not inherit the same `PATH` as your interactive shell.

If the popup opens but only shows:

```
(END)
```

then `less` started but did not receive any text. Using the absolute path fixes that problem.

---

## 3. Make the popup float

Back up your Hyprland window-rules file:

```
cp ~/.config/hypr/config/windowrules.lua \
   ~/.config/hypr/config/windowrules.lua.backup-$(date +%Y%m%d-%H%M%S)
```

Append a rule for the popup:

```
cat >> ~/.config/hypr/config/windowrules.lua <<'EOF'

-- ============================================================
-- Hyprland keybinding cheatsheet popup
-- ============================================================

hl.window_rule({
    name = "hyprkeys-popup",
    match = { class = "^hyprkeys-popup$" },
    float = true,
    center = true,
    size = { 1100, 760 },
})
EOF
```

The class matches the one set by:

```
kitty --class hyprkeys-popup
```

So the cheatsheet window should appear floating and centered.

---

## 4. Add the reliable keybinding

Back up your bindings file:

```
cp ~/.config/hypr/config/binds.lua \
   ~/.config/hypr/config/binds.lua.backup-$(date +%Y%m%d-%H%M%S)
```

Add:

```
cat >> ~/.config/hypr/config/binds.lua <<'EOF'

-- ============================================================
-- Hyprland keybinding cheatsheet
-- ============================================================

hl.bind(mainMod .. " + F12",
    hl.dsp.exec_cmd("/home/ben/.local/bin/hyprkeys-popup"))
EOF
```

The final shortcut is:

```
SUPER + F12
```

This avoids keyboard-layout-specific problems.

---

## 5. Reload Hyprland

Run:

```
hyprctl reload
```

You should get:

```
ok
```

No logout or reboot is required.

---

## 6. Test the popup

Press:

```
Super + F12
```

The floating cheatsheet should appear.

Press:

```
q
```

to close it.

---

## 7. Verify that Hyprland loaded the binding

Run:

```
hyprctl binds | grep -i -A8 -B5 hyprkeys
```

If nothing appears, you can also inspect the end of the Lua file:

```
tail -20 ~/.config/hypr/config/binds.lua
```

You should see:

```
-- Hyprland keybinding cheatsheet
hl.bind(mainMod .. " + F12",
    hl.dsp.exec_cmd("/home/ben/.local/bin/hyprkeys-popup"))
```

---

## 8. Verify the popup window class

If the popup opens manually but does not float correctly, launch it:

```
~/.local/bin/hyprkeys-popup
```

Then from another terminal run:

```
hyprctl clients | grep -i -A10 -B5 hyprkeys
```

You should see something resembling:

```
class: hyprkeys-popup
title: Hyprland Keybindings
```

That confirms the window rule is matching the correct class.

---

## 9. Troubleshooting

### Popup opens but is blank

Test the underlying cheatsheet:

```
~/.local/bin/hyprkeys
```

If that works, make sure `hyprkeys-popup` contains:

```
bash -c '/home/ben/.local/bin/hyprkeys | less -R'
```

and not:

```
bash -c 'hyprkeys | less -R'
```

---

### Manual popup works, but the shortcut does nothing

First confirm:

```
~/.local/bin/hyprkeys-popup
```

If that works, the launcher is fine and the problem is only the binding.

Check:

```
tail -20 ~/.config/hypr/config/binds.lua
```

Then reload:

```
hyprctl reload
```

and test:

```
Super + F12
```

---

### Why not use Super + /?

With a Spanish (Latin America) layout, `/` is typically produced with another key combination such as `Shift + 7`.

Attempts to bind:

```
Super + /
```

or:

```
Super + Shift + 7
```

can become dependent on layout interpretation and keycode handling.

Even though the popup itself worked perfectly, those bindings were not reliably registered.

Using:

```
Super + F12
```

proved reliable and avoids that entire class of keyboard-layout problems.

---

## 10. Updating the cheatsheet later

Edit:

```
nano ~/.local/bin/hyprkeys
```

or use your preferred editor.

You can add new sections as your setup grows, for example:

```
AI / AGENTS
------------------------------------------------------------
SUPER + ...                 Open Codex
SUPER + ...                 Open Grok
```

You do **not** need to reload Hyprland when changing only the cheatsheet text.

You only need:

```
hyprctl reload
```

after modifying:

```
~/.config/hypr/config/binds.lua
```

or:

```
~/.config/hypr/config/windowrules.lua
```

---

## Final configuration

The finished workflow is:

```
SUPER + F12
      │
      ▼
~/.local/bin/hyprkeys-popup
      │
      ▼
Kitty
class = hyprkeys-popup
      │
      ▼
/home/ben/.local/bin/hyprkeys
      │
      ▼
less -R
      │
      ▼
Floating Hyprland cheatsheet
      │
      └── q → close
```

The important files are:

```
~/.local/bin/hyprkeys
~/.local/bin/hyprkeys-popup
~/.config/hypr/config/binds.lua
~/.config/hypr/config/windowrules.lua
```

The reliable shortcut is:

```
SUPER + F12
```

This gives you a simple, persistent, and keyboard-layout-independent way to view your CachyOS Hyprland shortcuts at any time.