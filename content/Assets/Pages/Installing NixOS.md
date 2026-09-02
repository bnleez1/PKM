---
type: 'Page'
title: Installing NixOS
aliases: null
description: null
icon: ✴️
createdAt: '2026-07-17T16:09:19.672Z'
lastUpdated: '2026-07-17T17:19:16.827Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(284).md)'
---

# Installing NixOS

## Initial Installation Instructions

# Installing NixOS 26.05: Complete Novice Guide

These instructions cover the safest beginner installation:

- A normal 64-bit Intel or AMD desktop/laptop

- UEFI firmware

- One internal drive

- A **clean installation that erases the selected drive**

- KDE Plasma as the desktop

- Installation USB created from Kubuntu

The current stable release is **NixOS 26.05 “Yarara”**, released May 30, 2026 and supported through December 31, 2026. The official graphical installer is recommended for desktop users. (nixos.org)

> **Critical warning:** The “Erase disk” option permanently removes Kubuntu, Windows, personal files, and every partition on the selected drive. Do not follow that partitioning step for dual boot.

---

## Part 1: Understand what is different about NixOS

NixOS is not administered like Kubuntu, Debian, or Fedora.

You normally do **not** use:

```bash
sudo apt install package-name
```

Instead, much of the operating system is described in:

```text
/etc/nixos/configuration.nix
```

After changing that file, you apply the configuration with:

```bash
sudo nixos-rebuild switch
```

NixOS preserves earlier system configurations as “generations,” allowing you to boot or switch back to an earlier working configuration. (nixos.org)

This rollback feature protects system configuration and installed software. It does **not** replace backups of your documents, photos, email, or other personal files.

---

# Part 2: Prepare before installing

## Step 1: Back up your files

Copy everything important to storage that will not be connected during installation:

- Documents

- Pictures and videos

- Downloads

- Browser bookmarks and passwords

- Email archives

- SSH keys

- Capacities, Obsidian, or other local data

- Syncthing configuration

- pCloud files that are not fully synchronized

- Any files stored outside your home directory

Open several files directly from the backup drive to confirm that the backup actually works.

Do not rely only on a synchronization service. A deletion can sometimes synchronize along with everything else.

## Step 2: Identify the internal drive

While still running Kubuntu, open Konsole and run:

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
```

Record the model and capacity of the drive on which you plan to install NixOS.

Examples:

```text
nvme0n1   1.0T   Samsung SSD 990
sda       500G   Crucial MX500
```

The entire device is normally named something like:

```text
/dev/nvme0n1
```

or:

```text
/dev/sda
```

A numbered item such as `/dev/nvme0n1p2` or `/dev/sda2` is a partition, not the entire drive.

## Step 3: Disconnect unnecessary drives

Shut down the computer and disconnect:

- External backup drives

- Extra USB hard drives

- SD cards

- USB thumb drives other than the NixOS installer

- Any internal drive that can easily be disconnected and must not be altered

This greatly reduces the risk of selecting the wrong drive.

## Step 4: Prepare the computer

For a laptop:

- Connect the power adapter.

- Use Ethernet if available.

- Make sure the battery is charged.

- Record the Wi-Fi password.

For an NVIDIA laptop with both Intel/AMD integrated graphics and NVIDIA graphics, expect additional configuration after installation. Hybrid NVIDIA systems require PRIME configuration and should not be configured by blindly copying a generic desktop NVIDIA example. (wiki.nixos.org)

---

# Part 3: Download NixOS

## Step 5: Download the graphical ISO

Use the official NixOS download page and select:

**Graphical ISO image → 64-bit Intel/AMD**

Do not choose the Minimal ISO. The Minimal ISO is intended for command-line installation, while the Graphical ISO includes the live desktop and graphical installer. (nixos.org)

The filename will resemble:

```text
nixos-graphical-26.05.xxxx.xxxxxxxxxxxx-x86_64-linux.iso
```

The exact numbers may change as the stable installation image is refreshed.

## Step 6: Download the SHA-256 file

On the same official download page, select the **SHA-256** link beside the graphical Intel/AMD download.

Place both files in your `Downloads` directory:

```text
nixos-graphical-....iso
nixos-graphical-....iso.sha256
```

The official download page publishes a matching SHA-256 value for the graphical ISO. (channels.nixos.org)

## Step 7: Verify the ISO

Open Konsole and run:

```bash
cd ~/Downloads
ls nixos-graphical-*.iso*
```

Confirm that both the ISO and SHA-256 file appear.

Then run:

```bash
sha256sum -c *.iso.sha256
```

A successful result should end with:

```text
OK
```

Example:

```text
nixos-graphical-26.05.xxxx.xxxxxxxxxxxx-x86_64-linux.iso: OK
```

Do not use the ISO if the result says:

```text
FAILED
```

Delete both downloads and download them again from the official NixOS page.

---

# Part 4: Create the installation USB

Use an empty USB drive large enough to hold the downloaded image. Everything already on the USB will be erased.

## Step 8: Install KDE ISO Image Writer

In Kubuntu:

1. Open **Discover**.

2. Search for **ISO Image Writer**.

3. Install it.

4. Close Discover.

ISO Image Writer is KDE’s application for writing ISO images to USB disks. (KDE Applications)

Alternatively, the NixOS manual recommends graphical tools such as Etcher or USBImager. (nixos.org)

## Step 9: Write the ISO

1. Insert the empty USB drive.

2. Open the Application Launcher.

3. Search for **ISO Image Writer**.

4. Open it.

5. Select the downloaded NixOS `.iso` file.

6. Select the correct USB drive.

7. Recheck the USB drive’s model and capacity.

8. Select **Write**.

9. Enter your Kubuntu password if requested.

10. Wait until the writing operation finishes.

11. Eject the USB safely.

Do not copy the ISO onto the USB as an ordinary file. The image must be written directly to the entire USB device to make it bootable. (wiki.nixos.org)

---

# Part 5: Boot the NixOS USB

## Step 10: Open the computer’s boot menu

1. Shut down the computer completely.

2. Insert the NixOS USB.

3. Turn on the computer.

4. Immediately press the boot-menu key repeatedly.

Common keys include:

- `F12`

- `F9`

- `F10`

- `F11`

- `Esc`

- `Enter`

- `Delete`

The exact key depends on the manufacturer and model. (nixos.org)

## Step 11: Choose the UEFI USB entry

The boot menu may show two entries for the same USB, for example:

```text
UEFI: Kingston DataTraveler
Kingston DataTraveler
```

Choose the entry beginning with:

```text
UEFI:
```

The official manual recommends UEFI when the computer supports it. (nixos.org)

## Step 12: Deal with Secure Boot if necessary

If the computer reports an invalid signature, security violation, or simply refuses to boot the USB:

1. Restart into BIOS/UEFI settings.

2. Find **Secure Boot** under a section such as:

    - Boot

    - Security

    - Authentication

    - Advanced

3. Disable Secure Boot.

4. Save the settings.

5. Restart and select the UEFI USB again.

The standard NixOS installer commonly requires Secure Boot to be disabled. Secure Boot can be configured later using advanced NixOS solutions, but that is not part of a novice installation. (nixos.org)

Do not enable Legacy Boot or CSM unless the computer is too old to support UEFI.

---

# Part 6: Test the live environment

## Step 13: Start the graphical environment

At the NixOS boot menu:

1. Leave the default boot entry selected.

2. Press `Enter`, or allow it to start automatically.

3. Choose the Plasma live environment if a desktop choice appears.

4. Wait for the desktop to load.

The live desktop you choose does not determine the desktop installed on the computer; the installer asks about that separately. (nixos.org)

## Step 14: Connect to the internet

In Plasma:

1. Select the network icon near the lower-right corner.

2. Select your Wi-Fi network.

3. Enter the Wi-Fi password.

4. Open Firefox and confirm that a website loads.

Internet access is needed because the installer may download packages and system components. (nixos.org)

## Step 15: Test essential hardware

Before installing, check:

- Keyboard

- Touchpad or mouse

- Wi-Fi

- Ethernet

- Display brightness

- Speakers

- Headphones

- Bluetooth

- Webcam

- External monitor, if important

- Sleep and wake, if practical

A working live environment is a good indication that the basic hardware is supported, although it does not guarantee that every feature will work perfectly after installation.

---

# Part 7: Run the graphical installer

## Step 16: Open the installer

The graphical installer may open automatically.

Otherwise, double-click the desktop icon named something like:

```text
Install System
```

or:

```text
Install NixOS
```

The official NixOS manual recommends the graphical installer for desktop users. (nixos.org)

---

## Step 17: Welcome and language

Choose the language for the installer and installed system.

For easier troubleshooting, consider:

```text
American English
```

Most NixOS error messages, documentation, and support discussions are in English. The manual specifically notes that American English can make error searching and reporting easier. (nixos.org)

Select **Next**.

---

## Step 18: Location and time zone

Select:

```text
Region: America
Zone: Mexico_City
```

Or click central Mexico on the map.

Confirm that the displayed local time is correct.

Select **Next**.

The location selection configures the system time zone. (nixos.org)

---

## Step 19: Keyboard layout

Choose the keyboard layout that matches the physical keyboard.

Common possibilities:

```text
English (US)
Spanish (Latin American)
```

Use the test box and type:

```text
@ / ? ñ á é í ó ú
```

Confirm that important keys appear where expected.

Select **Next**.

---

## Step 20: Create the user account

Enter:

- Your full/display name

- A lowercase login name

- A computer name

- A strong password

Example:

```text
Full name: Benjamin Stewart
Login name: ben
Computer name: nixos-home
```

Recommendations:

- Use only lowercase letters for the login name.

- Avoid spaces in the login and computer names.

- Do not enable automatic login on a laptop.

- Record the password securely.

- Do not reuse the disk-encryption password unless you deliberately want them to be identical.

The installer uses this page to create the normal user account and password. (nixos.org)

---

## Step 21: Choose KDE Plasma

Select:

```text
Plasma
```

Plasma will feel most familiar to a Kubuntu user.

GNOME and Plasma are both popular and well-tested choices on NixOS. (nixos.org)

Do not choose **No desktop** for this installation.

---

## Step 22: Allow unfree software

Enable:

```text
Allow unfree software
```

This permits packages whose licensing does not satisfy the Nixpkgs free-software criteria. It can be necessary for some proprietary drivers and applications.

This setting permits such software; it does not necessarily install every required proprietary driver automatically. NixOS exposes the same setting as:

```text
nixpkgs.config.allowUnfree = true;
```

(nixos.org)

---

# Part 8: Partition the drive

## Step 23: Confirm that the installer says UEFI

Look near the top-left of the partitioning page.

It should indicate:

```text
UEFI
```

If it says BIOS and the computer supports UEFI:

1. Cancel the installation.

2. Restart.

3. Reopen the boot menu.

4. Choose the USB entry beginning with `UEFI:`.

The NixOS installer specifically warns users to reboot in the correct mode if a UEFI-capable computer was booted as BIOS. (nixos.org)

## Step 24: Select the correct internal drive

At the top of the partitioning screen, identify the drive using:

- Manufacturer

- Model

- Capacity

Compare it with the information recorded earlier using `lsblk`.

Do not proceed merely because the first drive is selected.

## Step 25: Choose Erase disk

For the clean-install path covered by this guide, select:

```text
Erase disk
```

This deletes all partitions and data on the selected drive. The official manual describes this as the easiest partitioning option and explicitly warns users to verify the selected disk. (nixos.org)

## Step 26: Choose swap

In the swap dropdown, select:

```text
Swap with hibernation
```

This is the beginner option recommended in the graphical installation instructions. (nixos.org)

## Step 27: Decide whether to encrypt the drive

For a laptop, enabling full-disk encryption is strongly advisable.

Select the LUKS encryption option and enter a strong passphrase.

Remember:

- You must enter this passphrase when the computer boots.

- It cannot be recovered if forgotten.

- Write down a recovery copy and store it securely.

- Encryption protects data when the computer is powered off.

- It does not replace backups.

The installer supports whole-disk LUKS encryption from the partitioning page. (nixos.org)

## Step 28: Choose a filesystem if asked

For the simplest beginner setup, choose:

```text
ext4
```

Accept the installer’s default partition layout unless you have a specific reason to customize it.

## Step 29: Review the summary

Read every item carefully.

Confirm:

- Correct language

- Correct time zone

- Correct keyboard

- Correct username

- Plasma selected

- Correct internal drive

- Erase disk selected

- Encryption status correct

- Boot mode is UEFI

Pay particular attention to the drive model and size.

## Step 30: Install

Select:

```text
Install
```

Confirm the destructive disk operation when asked.

Do not:

- Shut down the computer

- Remove the USB

- Close the installer

- Disconnect power

- Force a restart

The installer will partition the drive, install the operating system, configure the bootloader, create the account, and install the selected desktop. (nixos.org)

---

# Part 9: Complete the installation

## Step 31: Restart

When the installer reports completion:

1. Select **Restart now**.

2. Wait for the prompt to remove the installation medium.

3. Remove the NixOS USB.

4. Press `Enter` if instructed.

5. Allow the computer to restart.

The installed NixOS boot menu should appear. (nixos.org)

## Step 32: Unlock the encrypted disk

If encryption was enabled, enter the disk-encryption passphrase.

This happens before the graphical login screen.

## Step 33: Log in

At the Plasma login screen:

1. Select your account.

2. Enter the user password.

3. Wait for the Plasma desktop.

---

# Part 10: Perform the first update

## Step 34: Open Konsole

Open the Application Launcher and search for:

```text
Konsole
```

## Step 35: Confirm the installed version

Run:

```bash
nixos-version
```

It should begin with:

```text
26.05
```

## Step 36: Update the system

Run:

```bash
sudo nixos-rebuild switch --upgrade
```

Enter your user password.

This updates the NixOS channel and rebuilds the system using the latest packages available in the selected stable release. (nixos.org)

When it completes successfully, restart:

```bash
systemctl reboot
```

---

# Part 11: Back up the initial NixOS configuration

After logging in again, open Konsole and run:

```bash
sudo cp -a /etc/nixos "/etc/nixos.backup-$(date +%F-%H%M)"
```

Verify the backup:

```bash
sudo ls -ld /etc/nixos*
```

The important files are usually:

```text
/etc/nixos/configuration.nix
/etc/nixos/hardware-configuration.nix
```

Normally:

- Edit `configuration.nix`.

- Do not manually edit `hardware-configuration.nix` unless you know precisely why.

The hardware file is generated from the detected disk and hardware configuration and may be overwritten if the configuration is regenerated. (nixos.org)

---

# Part 12: Learn the safe NixOS editing workflow

## Step 37: Open the configuration file

Run:

```bash
sudo nano /etc/nixos/configuration.nix
```

Useful Nano shortcuts:

```text
Ctrl+W        Search
Ctrl+O        Save
Enter         Confirm filename
Ctrl+X        Exit
```

Nix configuration rules to remember:

- Most lines end with `;`

- Lists use square brackets: `[ ]`

- Attribute sets use braces: `{ }`

- Comments begin with `#`

- Text values use quotation marks

- Do not delete the final closing brace

## Step 38: Test before making a configuration permanent

After editing, first run:

```bash
sudo nixos-rebuild test
```

This activates the configuration temporarily without making it the default boot generation.

If it works correctly, run:

```bash
sudo nixos-rebuild switch
```

The `test` operation allows a reboot to return to the previous default, while `switch` makes the new configuration the default. (nixos.org)

---

# Part 13: Add recommended desktop services

Open the configuration:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add only options that are not already present. Do not create a second copy of an option that already exists in the same file.

Place missing options somewhere inside the outermost `{ ... }`, before the final `}`:

```text
# Permit packages with non-free licenses.
  nixpkgs.config.allowUnfree = true;
  # Enable Flatpak applications.
  services.flatpak.enable = true;
  # Enable supported firmware updates.
  services.fwupd.enable = true;
  # Enable printing.
  services.printing.enable = true;
  # Detect compatible USB printers using IPP-over-USB.
  services.ipp-usb.enable = true;
  # Discover compatible network printers and other local services.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  # Allow AppImage applications to run normally.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
```

These options enable Flatpak, firmware updates, CUPS printing, network-printer discovery, IPP-over-USB, and AppImage execution. (wiki.nixos.org)

Save and exit:

```text
Ctrl+O
Enter
Ctrl+X
```

Test and apply:

```bash
sudo nixos-rebuild test
sudo nixos-rebuild switch
```

Restart:

```bash
systemctl reboot
```

---

# Part 14: Add Flathub

After restarting, open Konsole and run:

```bash
flatpak remote-add --if-not-exists flathub \
https://dl.flathub.org/repo/flathub.flatpakrepo
```

Then update Flatpak metadata:

```bash
flatpak update
```

Search for an application:

```bash
flatpak search flatseal
```

Install an application:

```bash
flatpak install flathub com.github.tchx84.Flatseal
```

Flatpak can also be used through a compatible graphical software application, but terminal commands are useful for confirming that the service and Flathub repository work. (wiki.nixos.org)

---

# Part 15: Install ordinary NixOS packages

## Step 39: Find the package attribute

Use the official NixOS Packages search. The name used in the configuration may differ slightly from the application’s display name. The official search covers more than 140,000 packages. (search.nixos.org)

## Step 40: Find the existing package list

Open:

```bash
sudo nano /etc/nixos/configuration.nix
```

Search with `Ctrl+W` for:

```text
environment.systemPackages
```

It may resemble:

```text
environment.systemPackages = with pkgs; [
    wget
  ];
```

Add package attributes inside the existing brackets:

```text
environment.systemPackages = with pkgs; [
    wget
    curl
    git
    unzip
    usbutils
    pciutils
    vlc
  ];
```

Do not add commas between package names.

Save, test, and apply:

```bash
sudo nixos-rebuild test
sudo nixos-rebuild switch
```

To uninstall an application, remove its name from the list and rebuild the system. This is the declarative package-management method documented by NixOS. (nixos.org)

---

# Part 16: Update device firmware

After enabling `services.fwupd.enable`, run:

```bash
fwupdmgr get-devices
```

Refresh firmware metadata:

```bash
fwupdmgr refresh
```

Check for updates:

```bash
fwupdmgr get-updates
```

Apply available updates:

```bash
sudo fwupdmgr update
```

Some firmware updates are applied during the next reboot. Not every device supports updates through fwupd. (wiki.nixos.org)

---

# Part 17: Add a printer

After enabling the printing options:

1. Open **System Settings**.

2. Select **Printers**.

3. Select **Add Printer**.

4. Wait for network or USB printer discovery.

5. Prefer a driverless IPP or IPP Everywhere entry when available.

6. Print a test page.

NixOS uses CUPS through `services.printing`, while Avahi and IPP-over-USB assist with compatible network and USB printer discovery. (wiki.nixos.org)

For your Epson L3560, first try the detected IPP/AirPrint-compatible entry rather than manually choosing an old model-specific driver.

---

# Part 18: Run AppImages such as pCloud

NixOS does not normally run many AppImages out of the box because they expect libraries at conventional filesystem locations. Enabling:

```text
programs.appimage = {
  enable = true;
  binfmt = true;
};
```

registers AppImages so they can be invoked through `appimage-run`. (wiki.nixos.org)

After rebuilding, download the AppImage and make it executable:

```bash
chmod +x ~/Downloads/application.AppImage
```

Run it:

```bash
~/Downloads/application.AppImage
```

For pCloud or another AppImage that still fails, test it explicitly with:

```bash
appimage-run ~/Downloads/application.AppImage
```

---

# Part 19: Keep the system updated

For routine stable-release updates, run:

```bash
sudo nixos-rebuild switch --upgrade
```

Restart when the update includes a new kernel or when hardware-related packages were updated:

```bash
systemctl reboot
```

A sensible frequency for a desktop is once a week.

Do not switch to the `nixos-unstable` channel during the initial learning period.

---

# Part 20: Manage old system generations

NixOS does not upgrade packages in place. New package versions occupy new locations in `/nix/store`, so storage use can grow over time. The official manual recommends periodic garbage collection. (nixos.org)

## Safe cleanup that preserves rollback generations

Run:

```bash
sudo nix-collect-garbage
```

This removes unreferenced store objects but preserves old system generations used for rollback.

## Aggressive cleanup

The following command also removes old generations:

```bash
sudo nix-collect-garbage -d
```

Do not run it immediately after installation or immediately after a major update. It removes old rollback generations. (nixos.org)

---

# Part 21: Recover from a bad configuration

## If `nixos-rebuild` reports an error

Do not reboot.

Read the error message carefully. It often identifies:

- A missing semicolon

- An unknown package

- An invalid option

- Duplicate attributes

- An unmatched brace or bracket

Reopen the file:

```bash
sudo nano /etc/nixos/configuration.nix
```

Correct the problem and run:

```bash
sudo nixos-rebuild test
```

## If the system boots but the new configuration is bad

Roll back to the immediately preceding generation:

```bash
sudo nixos-rebuild switch --rollback
```

## If the system will not boot

1. Restart.

2. Open the NixOS boot menu.

3. Select an earlier generation.

4. Boot it.

5. Correct `/etc/nixos/configuration.nix`.

6. Run:

```bash
sudo nixos-rebuild switch
```

Previous configurations appear in the boot menu unless they have been removed through garbage collection. (nixos.org)

---

# Part 22: NVIDIA warning

For a desktop with a recent dedicated NVIDIA card, proprietary-driver configuration commonly includes options such as:

```text
hardware.graphics.enable = true;
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia.open = true;
```

However, this example is **not sufficient for every NVIDIA computer**.

Do not paste it without checking:

- Exact NVIDIA model

- Whether the GPU is Turing or newer

- Whether the computer has Intel/NVIDIA or AMD/NVIDIA hybrid graphics

- Required PRIME mode

- PCI bus IDs

Recent NVIDIA cards can use NVIDIA’s open kernel modules, while older models may require a legacy branch. Hybrid laptops require additional PRIME configuration. (wiki.nixos.org)

---

# Part 23: Dual-boot warning

Do not choose **Erase disk** if you intend to preserve Windows, Kubuntu, or another operating system.

A dual-boot installation generally requires:

1. A verified backup

2. Shrinking the existing partition from its own operating system

3. Leaving the new space unallocated

4. Booting the NixOS USB in the same UEFI mode

5. Selecting manual partitioning

6. Reusing the existing EFI System Partition without formatting it

7. Creating a separate NixOS root partition in the unallocated space

8. Carefully configuring the bootloader

Those steps depend on the actual partition table, encryption status, BitLocker status, number of disks, and existing EFI layout. For a novice, the partition instructions should be based on an `lsblk` or KDE Partition Manager screenshot rather than a generic dual-boot recipe.

---

# Installation completion checklist

The installation can be considered complete when all of the following work:

- NixOS boots without the USB

- Disk encryption unlocks correctly, if enabled

- Plasma login works

- Wi-Fi or Ethernet works

- Audio works

- Bluetooth works

- Display brightness and sleep work

- `nixos-version` shows 26.05

- `sudo nixos-rebuild switch --upgrade` succeeds

- `/etc/nixos` has been backed up

- Flatpak and Flathub work

- AppImages work if required

- Firmware has been checked

- Printing works if required

- Personal files have been restored from backup

- A separate continuing backup system has been configured

The most important NixOS habit is:

```text
Edit configuration.nix → test → switch → keep a backup
```

[1]: https://nixos.org/download/ "Download | Nix & NixOS"

[2]: https://nixos.org/manual/nixos/stable/ "NixOS Manual"

[3]: https://wiki.nixos.org/wiki/NVIDIA "NVIDIA - Official NixOS Wiki"

[4]: https://channels.nixos.org/nixos-26.05/latest-nixos-graphical-x86_64-linux.iso.sha256 "releases.nixos.org"

[5]: https://apps.kde.org/isoimagewriter/?utm_source=chatgpt.com "ISO Image Writer"

[6]: https://wiki.nixos.org/wiki/NixOS_Installation_Guide "NixOS Installation Guide - Official NixOS Wiki"

[7]: https://wiki.nixos.org/wiki/Flatpak "Flatpak - Official NixOS Wiki"

[8]: https://search.nixos.org/?utm_source=chatgpt.com "NixOS Search - Packages"

[9]: https://wiki.nixos.org/wiki/Fwupd "Fwupd - Official NixOS Wiki"

[10]: https://wiki.nixos.org/wiki/Printing "Printing - Official NixOS Wiki"

[11]: https://wiki.nixos.org/wiki/Appimage "Appimage - Official NixOS Wiki"

## Personal Configuration

The configuration has been updated and repackaged.

### Download

- Complete updated NixOS configuration (sandbox:/mnt/data/benjamin-nixos-26.05-config.zip)

- configuration.nix (sandbox:/mnt/data/nixos-benjamin/configuration.nix)

- home.nix (sandbox:/mnt/data/nixos-benjamin/home.nix)

- flake.nix (sandbox:/mnt/data/nixos-benjamin/flake.nix)

- Installation and usage guide (sandbox:/mnt/data/nixos-benjamin/README.md)

## Main changes

### Flatpak applications

The configuration now installs these versions declaratively from Flathub:

- OBS Studio

- Kdenlive

- GIMP

- VLC

- PSPP

- PDF Arranger

- Okular

- LibreOffice

- Thunderbird

- Teams for Linux

- Whatsie

- Czkawka

- Ark

- Filelight

- Kate

- Flatseal

Flathub is configured automatically, Flatpaks update weekly, and applications installed manually through Discover are preserved. (GitHub)

System-integrated utilities such as GNOME Disks, KDE Partition Manager, Konsole, Spectacle, Syncthing Tray, and command-line programs remain native NixOS packages.

### Firefox Progressive Web Apps

Firefox remains a **native NixOS package**, because FirefoxPWA’s native-messaging connector is not compatible with Flatpak Firefox. (PWAsForFirefox)

The configuration installs:

- `firefoxpwa`

- its native-messaging registration

- the Progressive Web Apps for Firefox extension automatically

- KDE file-picker integration

### Syncthing

Syncthing now:

- starts automatically as user `ben`

- preserves devices and folders configured through its web interface

- opens its standard discovery and transfer ports

- keeps the management interface local at `http://127.0.0.1:8384`

- launches Syncthing Tray when Plasma starts (MyNixOS)

### Plasma panel

The panel is managed declaratively through Plasma Manager and automatically contains:

- Weather Report

- Total CPU Use

- Memory Usage

- Network Speed

- System Tray

- Digital Clock

- Show Desktop

The clock defaults to:

- **Long date**

- **12-hour time**

- no seconds

- date below the time

- Sunday as the first day of the calendar week

These clock and system-monitor settings use Plasma Manager’s supported configuration options. (GitHub)

The Weather Report widget is inserted automatically, but you must select its location once after logging in. The configuration permits that choice to persist rather than overwriting it during each rebuild. (GitHub)

## Applying the files

Copy all three Nix files:

```bash
sudo cp configuration.nix flake.nix home.nix /etc/nixos/
```

Then update and test:

```bash
sudo nix flake update /etc/nixos
sudo nixos-rebuild test --flake /etc/nixos#nixos
```

If the test succeeds:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
systemctl reboot
```

The files passed static structure, required-entry, preload-removal, and ZIP-integrity checks. I could not perform a complete `nixos-rebuild` evaluation in this environment, so the `test` command remains important before making the configuration permanent.

[1]: https://github.com/gmodena/nix-flatpak?utm_source=chatgpt.com "gmodena/nix-flatpak: Install flatpaks declaratively"

[2]: https://pwasforfirefox.filips.si/help/faq/?utm_source=chatgpt.com "Frequently Asked Questions - PWAsForFirefox"

[3]: https://mynixos.com/options/services.syncthing?utm_source=chatgpt.com "services.syncthing"

[4]: https://github.com/nix-community/plasma-manager/blob/trunk/modules/widgets/digital-clock.nix?utm_source=chatgpt.com "plasma-manager/modules/widgets/digital-clock.nix at trunk"

[5]: https://github.com/nix-community/plasma-manager/issues/455?utm_source=chatgpt.com "How do I configure weather panel widget geographical ..."

## NixOS Upgrades

## No—not by default

A standard NixOS installation **does not automatically download and install system or package updates**. You normally update a channel-based installation manually with:

```bash
sudo nixos-rebuild switch --upgrade
```

This downloads the latest packages from your currently selected NixOS channel, builds a new system generation, and activates it. (nixos.org)

## Enabling automatic updates

Add the following inside the main `{ ... }` section of `/etc/nixos/configuration.nix`:

```text
system.autoUpgrade = {
  enable = true;
  dates = "weekly";
  allowReboot = false;
};
```

Then apply the change:

```bash
sudo nixos-rebuild switch
```

NixOS will subsequently run its `nixos-upgrade` systemd service according to that schedule. Keeping `allowReboot = false` prevents unexpected automatic restarts. (nixos.org)

You can check the schedule with:

```bash
systemctl list-timers nixos-upgrade.timer
```

And inspect the latest update attempt with:

```bash
systemctl status nixos-upgrade.service
```

Automatic updating follows your **current channel**—for example, NixOS 26.05. It does not normally move you automatically to the next major NixOS release; changing release channels remains a deliberate administrative step. For a new NixOS user, I recommend running manual updates weekly for the first few weeks before enabling unattended upgrades.

[1]: https://nixos.org/manual/nixos/stable/ "NixOS Manual"

