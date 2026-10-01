---
title: pCloud Setup on Omarchy
tags:
  - Linux
  - Omarchy
  - Guide
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/setting-up-pcloud-in-omarchy
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Omarchy - pCloud First-Time Setup

This is the tested procedure for installing **pCloud Drive on Omarchy** using the official pCloud AppImage.

It addresses:

- pCloud not mounting in Files/Nautilus
- missing FUSE 2 support
- oversized pCloud windows
- pCloud Drive not appearing in the file manager
- automatic startup after login
- distinguishing the AppImage mount from the real pCloud Drive mount

> [!important]
> On Omarchy, install `fuse2` **before first launching pCloud**.  
> Omarchy already includes FUSE 3, but pCloud may also require the FUSE 2 compatibility library.

---

## 1. Install FUSE support

Open a terminal and run:

```bash
sudo pacman -S --needed fuse2
```

Verify:

```bash
pacman -Q fuse2 fuse3
```

Expected result should include both:

```text
fuse2 ...
fuse3 ...
```

Also verify:

```bash
command -v fusermount
ldconfig -p | grep 'libfuse.so.2'
ls -l /dev/fuse
```

The important requirements are:

```text
/usr/bin/fusermount
libfuse.so.2
/dev/fuse
```

---

## 2. Download pCloud

Download the **official pCloud Linux AppImage** from the pCloud website.

Create an applications directory:

```bash
mkdir -p "$HOME/Applications"
```

Move the downloaded AppImage there and rename it:

```text
~/Applications/pCloud.AppImage
```

Then make it executable:

```bash
chmod +x "$HOME/Applications/pCloud.AppImage"
```

Verify:

```bash
ls -lh "$HOME/Applications/pCloud.AppImage"
```

---

## 3. Fix oversized pCloud window

On Omarchy/Hyprland, pCloud may initially open at an excessively large UI scale.

Create a permanent launcher wrapper:

```bash
mkdir -p "$HOME/.local/bin"

printf '%s\n' \
'#!/usr/bin/env bash' \
'exec "$HOME/Applications/pCloud.AppImage" --force-device-scale-factor=1 "$@"' \
> "$HOME/.local/bin/pcloud"

chmod +x "$HOME/.local/bin/pcloud"
```

From now on, launch pCloud with:

```bash
pcloud
```

or:

```bash
"$HOME/.local/bin/pcloud"
```

The important option is:

```text
--force-device-scale-factor=1
```

This prevents the oversized pCloud window experienced under Omarchy.

---

## 4. First launch

Run:

```bash
pcloud
```

Sign in to the pCloud account.

Allow pCloud several seconds to initialize after login.

> [!important]
> Logging in is required before the virtual pCloud Drive can be mounted.

Do **not** manually create a fake `~/pCloudDrive` bookmark before pCloud has successfully mounted the drive.

---

## 5. Verify that pCloud Drive mounted

Run:

```bash
findmnt "$HOME/pCloudDrive"
```

A successful mount should resemble:

```text
/home/USERNAME/pCloudDrive pCloud.fs fuse rw,...
```

Another useful check is:

```bash
findmnt | grep -i pcloud
```

There may be **two different types of pCloud-related mounts**.

### AppImage mount

Something resembling:

```text
/tmp/.mount_pCloudXXXXXX
```

is merely the temporary mount used to execute the AppImage.

It is **not** the pCloud virtual drive.

### Real pCloud Drive

The important mount is:

```text
/home/USERNAME/pCloudDrive
```

with something resembling:

```text
pCloud.fs fuse
```

That is the actual cloud filesystem.

---

## 6. If pCloud is running but pCloudDrive is missing

Check whether pCloud is running:

```bash
pgrep -af 'p[Cc]loud'
```

Then check the drive:

```bash
findmnt "$HOME/pCloudDrive"
```

If the process exists but the drive is not mounted, restart pCloud once:

```bash
pkill -f '[p]cloud' 2>/dev/null || true
sleep 3
pcloud
```

Wait approximately 10 seconds after logging in and check again:

```bash
findmnt "$HOME/pCloudDrive"
```

During the tested Omarchy installation, pCloud initially reported:

```text
Failed to start filesystem
Filesystem mount failed
```

but subsequently retried and successfully mounted:

```text
/home/ben/pCloudDrive pCloud.fs fuse
```

Therefore, an initial FUSE failure does not necessarily mean the installation is broken.

---

## 7. Open pCloud Drive in Files

Omarchy uses Nautilus/Files.

After confirming that the mount exists:

```bash
nautilus "$HOME/pCloudDrive"
```

The pCloud folders should now be visible.

Examples may include:

```text
Automatic Upload
Backups
Crypto Folder
Public Folder
pCloud Backup
pCloudSync
```

---

## 8. Add pCloud Drive to the Files sidebar

Only do this **after the real pCloud Drive is mounted**.

Open:

```bash
nautilus "$HOME/pCloudDrive"
```

Then press:

```text
Ctrl+D
```

This creates a Nautilus bookmark for pCloud Drive.

> [!warning]
> If the bookmark is created before pCloud Drive exists, Files may display:
>
> **Unable to find the requested file**
>
> because the bookmark points to a mount that has not yet been created.

---

## 9. Start pCloud automatically with Omarchy

Use Omarchy's native session autostart configuration.

Open:

```text
~/.config/hypr/autostart.lua
```

Add:

```lua
o.launch_on_start("pcloud")
```

For example, edit it with:

```bash
nano "$HOME/.config/hypr/autostart.lua"
```

Save with:

```text
Ctrl+O
Enter
Ctrl+X
```

Verify:

```bash
grep -n pcloud "$HOME/.config/hypr/autostart.lua"
```

You should see:

```lua
o.launch_on_start("pcloud")
```

pCloud will now start through the corrected launcher whenever an Omarchy session begins.

### Avoid duplicate autostart

Use **one startup mechanism only**.

If an older setup created:

```text
~/.config/autostart/pcloud.desktop
```

remove it:

```bash
rm -f "$HOME/.config/autostart/pcloud.desktop"
```

Also avoid enabling a second startup mechanism inside pCloud itself if Omarchy is already launching it.

---

## 10. Verify the complete setup

Run:

```bash
echo "===== PCLOUD EXECUTABLE ====="
ls -lh "$HOME/Applications/pCloud.AppImage"

echo
echo "===== LAUNCHER ====="
ls -lh "$HOME/.local/bin/pcloud"

echo
echo "===== FUSE ====="
pacman -Q fuse2 fuse3

echo
echo "===== PROCESS ====="
pgrep -af 'p[Cc]loud' || echo "pCloud not running"

echo
echo "===== REAL PCLOUD MOUNT ====="
findmnt "$HOME/pCloudDrive" || echo "pCloud Drive not mounted"

echo
echo "===== AUTOSTART ====="
grep -n pcloud "$HOME/.config/hypr/autostart.lua" || echo "pCloud not configured for Omarchy autostart"
```

A healthy setup has:

```text
pCloud AppImage        ✓
fuse2                  ✓
fuse3                  ✓
pCloud process         ✓
~/pCloudDrive mount    ✓
Omarchy autostart      ✓
UI scale = 1           ✓
```

---

# Troubleshooting

## pCloud window is enormous

Confirm that pCloud is being launched through:

```bash
pcloud
```

Check the wrapper:

```bash
cat "$HOME/.local/bin/pcloud"
```

It should contain:

```bash
#!/usr/bin/env bash
exec "$HOME/Applications/pCloud.AppImage" --force-device-scale-factor=1 "$@"
```

---

## pCloud runs but Files cannot find pCloudDrive

Check:

```bash
findmnt "$HOME/pCloudDrive"
```

If nothing appears:

```bash
pkill -f '[p]cloud' 2>/dev/null || true
sleep 3
pcloud
```

Then wait and check again:

```bash
findmnt "$HOME/pCloudDrive"
```

---

## Check pCloud logs

The main log is normally:

```text
~/.config/pcloud/logs/main.log
```

View recent filesystem/FUSE messages:

```bash
grep -niE \
'mount|fuse|filesystem|failed|failure|error|login' \
"$HOME/.config/pcloud/logs/main.log" \
| tail -50
```

Useful messages include:

```text
Login Required
No valid token found
Failed to start filesystem
Filesystem mount failed
```

`Login Required` or `No valid token found` means the account must be authenticated before pCloud Drive can mount.

---

## GNOME SessionManager warning

Under Omarchy, the pCloud log may contain something similar to:

```text
Could not register with GNOME SessionManager
```

This did not prevent pCloud Drive from mounting in the tested Omarchy configuration.

The important test is:

```bash
findmnt "$HOME/pCloudDrive"
```

not the presence of that warning.

---

# File manager integration

Recent versions of pCloud support Nautilus integration.

In pCloud:

**Settings → General → Show context menu**

After enabling it, restart Files:

```bash
nautilus -q
```

Then reopen Files with:

```text
Super+Shift+F
```

---

# Recommended configuration summary

Use:

```text
Application:
~/Applications/pCloud.AppImage

Launcher:
~/.local/bin/pcloud

UI scaling:
--force-device-scale-factor=1

Virtual drive:
~/pCloudDrive

Required compatibility package:
fuse2

Omarchy startup configuration:
~/.config/hypr/autostart.lua

Startup command:
o.launch_on_start("pcloud")
```

This provides a clean pCloud installation on Omarchy with the correct window size, FUSE support, Files/Nautilus access, and automatic startup.