---
title: "Omarchy Guide: Visual Overview of Open Apps"
tags:
  - Linux
  - Omarchy
  - Guide
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/setting-up-system-monitor-plugin-in-omarchy
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Omarchy Guide: Visual Overview of Open Apps

````
# Omarchy Guide: View Open Apps with Super + Tab

This setup adds a visual overview of open windows in Omarchy, similar to GNOME Activities or Windows Task View.

## 1. Install Omarchy Overview

Open a terminal and run:

```bash
omarchy plugin add https://github.com/AyushKr2003/omarchy-overview.git --enable
````

## 2. Test the Overview

Run:

```
omarchy-shell shell toggle omarchy-overview
```

If the plugin is working, a visual overview of your open windows/workspaces should appear.

## 3. Assign Overview to Super + Tab

Open your Hyprland bindings file:

```
nano ~/.config/hypr/bindings.lua
```

Add this line near the bottom:

```
o.rebind("SUPER + TAB", "Overview", "omarchy-shell shell toggle omarchy-overview")
```

> Important: this is a Lua configuration line. Do not enter it directly into the terminal.

## 4. Save the File

In Nano:

- Press `Ctrl + O`
- Press `Enter`
- Press `Ctrl + X`

## 5. Reload Hyprland

Run:

```
hyprctl reload
```

No reboot is required.

## 6. Use the Overview

Press:

**Super + Tab**

You should now see a visual overview of your open windows and workspaces.

## Alternative Binding

If `o.rebind()` does not work, use:

```
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Overview", "omarchy-shell shell toggle omarchy-overview")
```

Then reload Hyprland:

```
hyprctl reload
```

## Useful Window Shortcuts

|Shortcut|Action|
|---|---|
|`Super + Tab`|Show visual overview|
|`Alt + Tab`|Cycle through open windows|
|`Alt + Shift + Tab`|Cycle backward|
|`Super + 1`|Go to workspace 1|
|`Super + 2`|Go to workspace 2|
|`Super + 3`|Go to workspace 3|

## Troubleshooting

If you see a Bash syntax error such as:

```
bash: syntax error near unexpected token `"SUPER + TAB"'
```

you entered the Lua line directly into the terminal.

Instead, put it inside:

```
~/.config/hypr/bindings.lua
```

If the overview still does not appear, test it directly:

```
omarchy-shell shell toggle omarchy-overview
```

Then reload Hyprland again:

```
hyprctl reload
```

## Result

After this setup:

**Super + Tab → visually see your open apps → select the window you want**  
```