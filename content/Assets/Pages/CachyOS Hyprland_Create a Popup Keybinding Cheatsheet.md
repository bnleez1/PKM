---
title: CachyOS Hyprland_Create a Popup Keybinding Cheatsheet
tags:
  - 
  - 
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/cachyos-hyprland-create-a-popup-keybinding-cheatsheet
banner: https://wallpapercave.com/wp/wp2506793.jpg
---
# CachyOS Hyprland: Create a Popup Keybinding Cheatsheet

This tutorial creates a floating **Hyprland keybinding cheatsheet** that you can summon with a keyboard shortcut and dismiss by pressing `q`.

It is based on the CachyOS Hyprland Lua configuration used on your system:

```
~/.config/hypr/
├── hyprland.lua
└── config/
    ├── binds.lua
    ├── inputs.lua
    ├── windowrules.lua
    └── ...
```

The finished setup uses:

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
~/.config/hypr/config/binds.lua
```

to assign the keyboard shortcut.

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

## 2. Create the floating popup launcher

The popup will use Kitty and `less`.

First verify Kitty exists:

```
command -v kitty
```

On this CachyOS setup it should return something similar to:

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

### Why the absolute path matters

Use:

```
/home/ben/.local/bin/hyprkeys
```

rather than simply:

```
hyprkeys
```

This matters because programs launched by Hyprland do not necessarily inherit the same `PATH` as your interactive shell.

A popup that opens but shows only:

```
(END)
```

usually means `less` started successfully but did not receive output from `hyprkeys`.

Using the absolute path fixes that problem.

Test the popup:

```
~/.local/bin/hyprkeys-popup
```

You should now see a Kitty window containing the cheatsheet.

Press:

```
q
```

to close it.

---

## 3. Make the popup float

Your CachyOS setup stores window rules in:

```
~/.config/hypr/config/windowrules.lua
```

Back it up first:

```
cp ~/.config/hypr/config/windowrules.lua \
   ~/.config/hypr/config/windowrules.lua.backup-$(date +%Y%m%d-%H%M%S)
```

Append this rule:

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

The important part is:

```
match = { class = "^hyprkeys-popup$" },
```

This matches the class set by:

```
kitty --class hyprkeys-popup
```

The popup will therefore be:

```
floating
centered
approximately 1100 × 760 pixels
```

---

## 4. Add the keyboard shortcut

Your CachyOS Hyprland bindings live in:

```
~/.config/hypr/config/binds.lua
```

Back it up:

```
cp ~/.config/hypr/config/binds.lua \
   ~/.config/hypr/config/binds.lua.backup-$(date +%Y%m%d-%H%M%S)
```

### Important for Spanish Latin American keyboards

Your keyboard is configured as:

```
kb_layout = "latam",
```

On a Latin American layout, `/` is normally produced with:

```
Shift + 7
```

Therefore, instead of assuming a US physical slash keycode, bind:

```
SUPER + SHIFT + 7
```

which effectively gives you:

```
SUPER + /
```

Append:

```
cat >> ~/.config/hypr/config/binds.lua <<'EOF'

-- ============================================================
-- Hyprland keybinding cheatsheet
-- ============================================================

-- Spanish Latin American keyboard:
-- "/" is produced with SHIFT + 7
hl.bind(mainMod .. " + SHIFT + 7",
    hl.dsp.exec_cmd("/home/ben/.local/bin/hyprkeys-popup"),
    { description = "Show Hyprland keybindings cheatsheet" })
EOF
```

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

There is no need to log out or reboot.

---

## 6. Test the shortcut

Physically press:

```
Super + Shift + 7
```

With your Latin American Spanish layout, this corresponds to:

```
Super + /
```

The floating cheatsheet should appear.

Press:

```
q
```

to close it.

---

## 7. Verify that Hyprland registered the binding

If the shortcut does nothing, check the loaded bindings:

```
hyprctl binds | grep -i -A6 -B3 cheatsheet
```

You should see the description:

```
Show Hyprland keybindings cheatsheet
```

You can also search for the launcher:

```
hyprctl binds | grep -i -A5 -B5 hyprkeys
```

---

## 8. Verify the popup window class

If the popup launches manually but does not float correctly, open it:

```
~/.local/bin/hyprkeys-popup
```

Then, from another terminal, run:

```
hyprctl clients | grep -i -A10 -B5 hyprkeys
```

You should see something resembling:

```
class: hyprkeys-popup
title: Hyprland Keybindings
```

That confirms the window rule has the correct class.

---

## 9. Troubleshooting

### Popup opens but is completely blank

If you see only:

```
(END)
```

the popup itself is working, but `less` received no cheatsheet text.

Test:

```
~/.local/bin/hyprkeys
```

If that displays the text, make sure `hyprkeys-popup` uses the **absolute path**:

```
bash -c '/home/ben/.local/bin/hyprkeys | less -R'
```

Do not rely on:

```
bash -c 'hyprkeys | less -R'
```

because `.local/bin` may not be available in the environment Hyprland gives the process.

### The popup works manually but the keyboard shortcut does nothing

First test:

```
~/.local/bin/hyprkeys-popup
```

If that works, the problem is only the binding.

Check:

```
hyprctl binds | grep -i -A6 -B3 hyprkeys
```

Then check that your binding appears at the bottom of:

```
tail -30 ~/.config/hypr/config/binds.lua
```

For the Latin American keyboard layout, prefer:

```
mainMod .. " + SHIFT + 7"
```

instead of assuming a US-layout slash key.

### `hyprctl reload` reports an error

Inspect the files you just edited:

```
tail -30 ~/.config/hypr/config/binds.lua
```

and:

```
tail -30 ~/.config/hypr/config/windowrules.lua
```

If necessary, restore the backups created earlier.

---

## 10. Updating the cheatsheet later

Whenever you add a new Hyprland shortcut, edit:

```
nano ~/.local/bin/hyprkeys
```

or use your preferred editor.

For example, if you later add shortcuts for Codex or Grok, you could add:

```
AI / AGENTS
------------------------------------------------------------
SUPER + ...                 Open Codex
SUPER + ...                 Open Grok
```

You do **not** need to reload Hyprland when changing only the contents of `hyprkeys`.

Hyprland only needs to be reloaded when you modify:

```
~/.config/hypr/config/binds.lua
```

or:

```
~/.config/hypr/config/windowrules.lua
```

---

## Final configuration

The finished arrangement is:

```
SUPER + SHIFT + 7
        │
        │  Latin American layout → SUPER + /
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

The four important files are:

```
~/.local/bin/hyprkeys
~/.local/bin/hyprkeys-popup
~/.config/hypr/config/binds.lua
~/.config/hypr/config/windowrules.lua
```

This approach is preferable to relying on `hyprctl binds` alone because the popup gives you a curated, human-readable reference while `hyprctl binds` remains available for diagnosing the actual configuration.