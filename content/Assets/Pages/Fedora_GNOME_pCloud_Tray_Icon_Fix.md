---
title: Fedora GNOME pCloud Tray Icon Fix
type: note
status: seed
tags:
  - fedora
  - gnome
  - pcloud
  - linux
  - troubleshooting
banner: https://wallpapercave.com/wp/wp2471726.jpg
---
# Fedora GNOME pCloud Tray Icon Fix

## Problem

After reinstalling Fedora GNOME, pCloud may run correctly and mount `~/pCloudDrive`, but the **small pCloud status/tray icon** may not appear in the GNOME panel.

This note documents the working fix for pCloud installed as an AppImage at:

```bash
/home/ben/Applications/pCloud.AppImage
```

The key fix was:

1. Install and enable GNOME AppIndicator support.
2. Run pCloud under **XWayland/X11** instead of native Wayland by setting:

```bash
ELECTRON_OZONE_PLATFORM_HINT=x11
```

---

## 1. Confirm pCloud is installed

Expected AppImage location:

```bash
ls -l "$HOME/Applications/pCloud.AppImage"
```

Make it executable:

```bash
chmod +x "$HOME/Applications/pCloud.AppImage"
```

---

## 2. Install GNOME tray/AppIndicator support

Fedora GNOME does not show traditional tray icons by default.

Install the required extension and library:

```bash
sudo dnf install -y   gnome-shell-extension-appindicator   libappindicator-gtk3
```

Confirm installation:

```bash
rpm -q gnome-shell-extension-appindicator libappindicator-gtk3
```

Confirm the extension directory exists:

```bash
ls -ld /usr/share/gnome-shell/extensions/appindicatorsupport@rgcjonas.gmail.com
```

---

## 3. Log out and back in

On GNOME/Wayland, log out completely and log back in after installing the extension.

Then verify the extension:

```bash
gnome-extensions info appindicatorsupport@rgcjonas.gmail.com
```

Expected result:

```text
Enabled: Yes
State: ACTIVE
```

If it is installed but not enabled:

```bash
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
```

---

## 4. Restart pCloud using XWayland

First stop the currently running pCloud processes:

```bash
pkill -f pCloud.AppImage
pkill -f '/tmp/.mount_pCloud.*/pcloud.bin'
sleep 3
```

Then launch pCloud with X11/XWayland forced:

```bash
ELECTRON_OZONE_PLATFORM_HINT=x11 "$HOME/Applications/pCloud.AppImage" >/tmp/pcloud.log 2>&1 &
```

After several seconds, the **small pCloud status icon should appear in the GNOME panel**.

This was the step that solved the missing tray icon.

---

## 5. Make the fix permanent at login

pCloud already creates an autostart file here:

```bash
~/.config/autostart/pcloud.desktop
```

Inspect it first:

```bash
cat "$HOME/.config/autostart/pcloud.desktop"
```

Edit it:

```bash
nano "$HOME/.config/autostart/pcloud.desktop"
```

Change the `Exec=` line so pCloud always starts with X11/XWayland forced.

Example:

```ini
Exec=env ELECTRON_OZONE_PLATFORM_HINT=x11 /home/ben/Applications/pCloud.AppImage
```

Save and exit Nano:

- `Ctrl+O`
- `Enter`
- `Ctrl+X`

Then log out and back in to test.

---

## 6. Verify after reboot/login

Check that pCloud is running:

```bash
pgrep -af -i pcloud
```

Check that the pCloud drive is mounted:

```bash
mount | grep -i pcloud
```

or:

```bash
ls "$HOME/pCloudDrive"
```

Check that AppIndicator support is active:

```bash
gnome-extensions info appindicatorsupport@rgcjonas.gmail.com
```

Expected:

```text
Enabled: Yes
State: ACTIVE
```

---

## 7. Important distinction: tray icon vs launcher

The desired icon is the **small pCloud status icon in the GNOME panel**, not a pinned launcher in the dock.

If pCloud was accidentally added as a GNOME favorite, remove it from favorites with:

```bash
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'org.mozilla.thunderbird.desktop']"
```

Do not remove the AppImage itself.

---

## Quick reinstall checklist

```bash
chmod +x "$HOME/Applications/pCloud.AppImage"

sudo dnf install -y   gnome-shell-extension-appindicator   libappindicator-gtk3
```

Then **log out and back in**.

Enable AppIndicator support if needed:

```bash
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
```

Restart pCloud with XWayland:

```bash
pkill -f pCloud.AppImage
pkill -f '/tmp/.mount_pCloud.*/pcloud.bin'
sleep 3

ELECTRON_OZONE_PLATFORM_HINT=x11 "$HOME/Applications/pCloud.AppImage" >/tmp/pcloud.log 2>&1 &
```

If the tray icon appears, make this permanent in:

```bash
~/.config/autostart/pcloud.desktop
```

with:

```ini
Exec=env ELECTRON_OZONE_PLATFORM_HINT=x11 /home/ben/Applications/pCloud.AppImage
```

---

## Working configuration summary

- OS: Fedora GNOME
- Session: Wayland
- pCloud package type: AppImage
- pCloud AppImage: `/home/ben/Applications/pCloud.AppImage`
- pCloud mount: `/home/ben/pCloudDrive`
- GNOME extension: `appindicatorsupport@rgcjonas.gmail.com`
- Critical workaround: `ELECTRON_OZONE_PLATFORM_HINT=x11`
- Result: pCloud status/tray icon visible in GNOME panel
