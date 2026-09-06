---
type: Page
collections: Public Pages
title: Installing EndeavorOS (Arch)
aliases:
description:
icon: 🖥️
createdAt: 2026-06-08T13:46:49.872Z
lastUpdated: 2026-06-28T12:57:41.809Z
tags: []
coverImage: "[Untitled](../Images/Untitled%20(228).md)"
---

# Installing EndeavorOS (Arch)

- System info…

    !Endeavor.png

- Notion views open when recording memory usage above - Notion views tend to eat up memory.

    !Notion.png

# Terminal Considerations

- Setting up rclone like Google Drive App

    - How long it takes to sync across devices and Google Drive with rclone

        In the **“Rclone like Google Drive App”** toggle, your mount command includes:

        - `-poll-interval 15s`

        - `-vfs-write-back 5s`

        So **typical propagation time (Linux Mint → Google Drive)** with *that exact setup* is:

        1. **For small file edits (once the file is saved/closed):**

            Usually **~5–20 seconds**.

            - `-vfs-write-back 5s` means rclone waits about **5 seconds** after the last write before it starts uploading.

            - Upload then depends on your connection + file size.

        2. **For new/renamed/moved files/folders:**

            Typically **within ~a few seconds to ~30 seconds**, but you should expect it to be **“near the poll interval”** for the mount to notice remote-side changes consistently.

            - The `-poll-interval 15s` is your main “freshness” lever for *detecting* Drive changes and staying current.

        3. **For large files (videos, big PDFs, big folders):**

            The delay is mostly **upload time**, so it can be **minutes+** depending on size and upstream bandwidth.

        Practical rule of thumb for your config: **“Expect Google Drive to reflect local changes in ~10–30 seconds for normal small edits, longer for big uploads.”**

    > **Prompt**: *Help me set up rclone from scratch in Linux Mint in a way that closest replicates Google Drive app in terms of effectiveness and efficiencies. It should mount automatically each time system reboots and awakens from sleep mode.*

    Setting up `rclone` on Linux Mint to emulate the Google Drive desktop experience requires a specific combination of **VFS (Virtual File System) caching** and a **Systemd user service**. This setup allows you to browse files on demand without downloading everything, while keeping frequently used files local for speed.

    ### Phase 1: Installation and Basic Config

    First, ensure you have the latest version of `rclone` and the necessary FUSE filesystem support.

    1. **Install rclone + FUSE (EndeavourOS / Arch):**

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed rclone fuse3
    ```

    1. **Configure the Google Drive Remote:**

        Run `rclone config` and follow these specific choices:

        - **n)** New remote

        - **name:** `gdrive` (you can change this, but remember it for later)

        - **Storage type:** Search for `drive` or enter the number for **Google Drive**.

        - **Client ID/Secret:** Leave blank (press Enter) to use rclone's defaults.

        - **Scope:** Choose `1` (Full access).

        - **Service Account:** Leave blank.

        - **Edit advanced config:** No.

        - **Use web browser to authenticate:** Yes. (Follow the browser login process).

        - **Configure this as a Shared Drive?** No (unless you specifically need it).

        - **Keep and save?** Yes.

    ---

    ### Phase 2: Create the Mount Point

    Create the folder where your Google Drive files will appear.

    ```bash
    mkdir -p ~/GoogleDrive
    ```

    ### Phase 3: The "Efficiency" Script (Systemd)

    To make the mount behave like the official app—fast browsing, instant file opening, and background uploading—we use a **Systemd User Service**. This ensures it starts on boot and recovers after the system wakes from sleep.

    1. **Create the service file:**

    ```bash
    mkdir -p ~/.config/systemd/user/
    nano ~/.config/systemd/user/rclone-gdrive.service
    ```

    ```bash
    [Unit]
    Description=Rclone Google Drive Mount
    After=network-online.target
    Wants=network-online.target
    [Service]
    Type=notify
    ExecStart=/usr/bin/rclone mount gdrive: %h/GoogleDrive \
      --config=%h/.config/rclone/rclone.conf \
      --vfs-cache-mode full \
      --vfs-cache-max-age 24h \
      --vfs-cache-max-size 10G \
      --vfs-read-ahead 128M \
      --dir-cache-time 1000h \
      --poll-interval 15s \
      --attr-timeout 1000h \
      --buffer-size 64M \
      --vfs-write-back 5s \
      --log-level INFO \
      --log-file /tmp/rclone-gdrive.log
    # This ensures the mount is cleaned up properly on shutdown/sleep
    ExecStop=/bin/fusermount -uz %h/GoogleDrive
    Restart=on-failure
    RestartSec=5
    [Install]
    WantedBy=default.target
    ```

    ### Phase 4: Why these settings work

    - `-vfs-cache-mode full`: This is the "magic" flag. It makes the mount act like a real disk. Files are cached locally when you open them, allowing apps to read/write without lag.

    - `-poll-interval 15s`: Google Drive tells `rclone` when a file changes on the server. This setting ensures your local folder updates almost instantly if you change a file on your phone or web browser.

    - `-dir-cache-time 1000h`: This keeps the folder structure in memory. Browsing through folders will be instant rather than waiting for the API to load every time.

    - `-vfs-write-back 5s`: When you save a file, it saves locally instantly and then uploads to Google in the background 5 seconds later.

    ### Phase 5: Activation and Automation

    Here are the commands from Phase 5, separated so you can run them one by one.

    Make sure you have already saved the file in `nano` before running these.

    ### 1. Refresh the Systemd configuration

    This tells the system to look for the new `.service` file you just created.

    Bash

    `systemctl --user daemon-reload`

    ### 2. Start the mount immediately

    This actually runs the `rclone mount` command in the background.

    Bash

    `systemctl --user start rclone-gdrive.service`

    ### 3. Enable the mount on startup

    This ensures that every time you log into Linux Mint, the drive mounts automatically.

    Bash

    `systemctl --user enable rclone-gdrive.service`

    ### 4. Verify the status

    Run this to make sure the service is "active (running)" and hasn't encountered any errors.

    Bash

    `systemctl --user status rclone-gdrive.service`

    ---

    ### A quick note on "Sleep Mode"

    Because we used `Restart=on-failure` and `RestartSec=5` in the configuration, if your Wi-Fi drops when the laptop lid closes, the service will "fail" briefly. As soon as the system wakes up and the network is back online, Systemd will automatically attempt to remount it within 5 seconds without you needing to do anything.

    Is the `~/GoogleDrive` folder showing your files now?

- Installing ZRAM

    On EndeavourOS (and other Arch-based systems), the modern and recommended way to set up zram is by using the **zram-generator**. It is lightweight, integrated with systemd, and very efficient.

    Here is the step-by-step process to install and configure it:

    ### 1. Install the Generator

    Open your terminal and run:

    ```bash
    sudo pacman -S zram-generator
    ```

    ### 2. Create the Configuration File

    The package doesn't create a configuration by default, so you need to tell it how much zram you want. Use your preferred text editor (like Nano or Micro) to create the file:

    ```bash
    sudo nano /etc/systemd/zram-generator.conf
    ```

    Paste the following configuration into the file. This setup allocates half of your RAM (up to a certain limit) to zram, which is a common "best practice" for general use:

    ```text
    [zram0]
    zram-size = ram / 2
    compression-algorithm = zstd
    swap-priority = 100
    fs-type = swap
    ```

    - **zram-size:** You can set this to a specific number (e.g., `4096` for 4GB) or a ratio like the example above.

    - **compression-algorithm:** `zstd` offers the best balance between compression ratio and CPU usage.

    ### 3. Apply the Changes

    You don't need to reboot. You can tell systemd to recognize the new configuration and start the device immediately:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start /dev/zram0
    ```

    ### 4. Verify the Installation

    Run the command from earlier to ensure it’s running:

    ```bash
    zramctl
    ```

    ### Pro-Tip: Disabling zswap

    Linux often has **zswap** enabled by default. Since zram and zswap both try to compress memory, they can sometimes step on each other's toes. If you want to rely purely on zram, it's best to disable zswap:

    1. **Check if enabled:** `cat /sys/module/zswap/parameters/enabled`

    2. **Disable it temporarily:** `echo 0 | sudo tee /sys/module/zswap/parameters/enabled`

    3. **Disable it permanently:** Add `zswap.enabled=0` to your kernel parameters in your bootloader configuration (e.g., in `/etc/default/grub` inside the `GRUB_CMDLINE_LINUX_DEFAULT` line, then run `sudo update-grub`).

    ### Alternative: `systemd-zram-generator` vs. `zram-tools`

    While `zram-generator` is the Arch standard, some users prefer **zram-tools** (found in the AUR). However, for a clean EndeavourOS setup, the method above is generally more stable and follows the "Arch way" of using systemd generators.

- Installing [https://www.winboat.app/](https://www.winboat.app/) Dependencies

    ## Install WinBoat (EndeavourOS / Arch)

    ### Option A (recommended): Install from AUR with `yay`

    ```bash
    yay -S winboat
    ```

    Then launch it from your app menu, or run:

    ```bash
    winboat
    ```

    ### Option B: Run the official AppImage (from GitHub Releases)

    1. Download the latest **AppImage** from the WinBoat releases page.

    2. Make it executable and run it:

    ```bash
    chmod +x ~/Downloads/WinBoat-*.AppImage
    ~/Downloads/WinBoat-*.AppImage
    ```

    ### 1. Install Docker + Docker Compose (v2)

    Open your terminal and run:

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed docker docker-compose
    ```

    ### 2. Enable + start Docker

    ```bash
    sudo systemctl enable --now docker
    ```

    ### 3. (Recommended) Add your user to the docker group

    This lets you run `docker` without `sudo`.

    ```bash
    sudo usermod -aG docker $USER
    ```

    Then **log out and log back in** (or reboot) for it to take effect.

    ### 4. Quick verification

    ```bash
    docker --version
    docker compose version
    sudo docker run --rm hello-world
    ```

    ---

    ## Extra prerequisite (often needed): FreeRDP (v3)

    WinBoat uses FreeRDP for RemoteApp window compositing. Install it via pacman:

    ```bash
    sudo pacman -S --needed freerdp
    ```

    (If your system uses binary versioning, the command may be `xfreerdp3` instead of `xfreerdp`.)

- Enabling TRIM

    💡 TRIM is a command that helps optimize SSDs by informing them which data blocks are no longer in use and can be erased, improving performance and extending the drive's lifespan.

    ### Enable periodic TRIM (recommended)

    ```bash
    sudo systemctl enable --now fstrim.timer
    sudo systemctl status fstrim.timer
    ```

    ### Run TRIM once right now (optional)

    ```bash
    sudo fstrim -av
    ```

- Enabling Bluetooth on Fresh Install

    On a fresh EndeavourOS **KDE** install, Bluetooth usually just needs the BlueZ stack installed + the service enabled.

    ### Install the packages

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed bluez bluez-utils bluedevil
    ```

    ### Enable + start the Bluetooth service

    ```bash
    sudo systemctl enable --now bluetooth.service
    ```

    ### (Optional) Verify it’s running

    ```bash
    systemctl status bluetooth.service
    ```

    ### Pair from terminal (optional)

    ```bash
    bluetoothctl
    power on
    agent on
    default-agent
    scan on
    # then: pair <MAC>, trust <MAC>, connect <MAC>
    ```

    After that, KDE’s Bluetooth UI should appear (or you can open **System Settings → Bluetooth**). If the adapter still doesn’t show up, it’s often a missing firmware/kernel driver issue—but the commands above are the standard setup.

- Installing apps

    > EndeavorOS terminal command for installing the following packages: extension manager, preload, kdenlive, obs-studio, Microsoft Teams, Proton mail, Notion electron, pspp, ocs-url, onlyoffice, variety, system monitor-next gnome extension,

    Since you are on EndeavourOS, we can grab most of these from the official repositories using `pacman` and the rest from the AUR (Arch User Repository) using `yay`.

    Copy and paste these two commands to get everything installed:

    ### 1. Official Repository Packages

    This installs the heavy hitters and standard tools directly from the main Arch/Endeavour repos.

    ```bash
    sudo pacman -S kdenlive obs-studio gnome-disk-utility
    ```

    ### 2. AUR Packages (The "Everything Else" List)

    These packages are either proprietary (Teams, Notion) or specifically packaged for Arch by the community. `yay` will handle the build process for you.

    ```bash
    yay -S teams-for-linux prospect-mail notion-app-electron preload ttf-ms-fonts ttf-vista-fonts whatsie scrivener pspp qualcoder-bin pdfarranger-git okular-no-purpose python-unoserver webapp-manager-git ytmdesktop krita-git morgen-git rutorrent wps-office wps-zotero ttf-wps-fonts zotero-bin todoist-appimage
    ```

    ```jsx
    fc-cache -f -v
    ```

    ---

    ### Quick Notes on Specific Apps:

    - **Microsoft Teams:** The official desktop app for Linux was retired by Microsoft. `teams-for-linux` is the most popular and stable community-maintained version (an Electron wrapper).

    - **Notion:** Since there is no official Linux client, `notion-app` is the standard Electron-based version used by the community.

    - **Preload:** Once installed, you’ll want to enable the service so it actually starts working:Bash

        `sudo systemctl enable --now preload`

    - **OCS-URL:** This is usually used for "One-Click Install" buttons on sites like GNOME-look.org. It might ask you to confirm a PGP key during installation; just hit "A" for All or "Y" for Yes.

    ### A Tip for your Vivobook

    Since you are currently compiling that kernel (or just finished), I'd recommend running the `yay` command **after** you are finished with the kernel task. Running too many intensive installs at once can occasionally lead to a "lock" on the package database.

    Are you planning to use **Kdenlive** or **OBS** for your ELT Cast production later today?

- Resolving sync issues with Insync

    - Moving directories with (Selective Sync Conflict)

        Since you are moving folders across two completely different storage mounts (`/mnt` to `/run/media`), a direct visual drag-and-drop search can accidentally flatten your directory structure and overwrite folders with identical names.

        The most precise and safe way to handle this on Ubuntu is using a terminal script that preserves your exact directory hierarchy.

        Here are the two best approaches to get this done.

        ### Method 1: The Bulletproof Terminal Script (Recommended)

        This script searches your Seagate drive, replicates the exact folder structures inside your Backup folder, and safely transfers the conflict directories.

        Open your terminal and paste the following block:

        Bash

        `source_dir="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
        target_dir="/run/media/ben/bada87d8-d6f2-49be-8cd0-4130d3d97d95/Backup"

        cd "$source_dir" && find . -type d -name "*(Selective Sync Conflict)*" -print0 | while IFS= read -r -d '' dir; do
              # Replicate the parent directory path in the backup location
              mkdir -p "$target_dir/$(dirname "$dir")"

        ```text
        # Move the directory over safely
          mv "$dir" "$target_dir/$(dirname "$dir")/"
        ```

        done`

        **Why this is the safest method:**

        - **Handles Mount Crossings:** Because it uses `mv` across distinct filesystems, Linux will automatically copy the data over entirely and verify it before deleting the broken source files.

        - **Preserves Nested Files:** The `print0` and `IFS=` guards ensure that spaces and parentheses in your filenames won't break the command mid-transfer.

        ---

        ### Method 2: The GUI Way (Using Dolphin or Nemo)

        If you prefer to see the files as you move them, you can use your file manager's built-in search. However, **only use this if you are certain you don't have duplicate folder names** (like two different folders both named `Archive (Selective Sync Conflict)` in separate project trees).

        1. Open your file manager and navigate to your Seagate drive: `/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1`

        2. Press `Ctrl + F` to toggle the search bar.

        3. Type `Selective Sync Conflict` into the search field.

        4. Set the search filter type to **Folders** (or Directories) so you don't accidentally grab isolated files.

        5. Select all the matching folders from the search results (`Ctrl + A`) and cut them (`Ctrl + X`).

        6. Open a second window or tab, navigate to `/run/media/ben/bada87d8-d6f2-49be-8cd0-4130d3d97d95/Backup`, and press `Ctrl + V` to paste them.

        > ⚠️ **Warning on the GUI method:** This will pull all those folders out of their original sub-directories and dump them into a single flat list inside your `Backup` folder. If there are any naming collisions, your file manager will ask you to overwrite or rename them. If you need to keep track of *where* those folders originally lived, stick to **Method 1**.

    - Ignore Rules in Insync

        The short answer is: **Insync does not currently have a global, automated setting to automatically execute "cancel and delete local file" when a sync error occurs.**

        Insync’s developers designed it this way intentionally as a safety protocol. If a file is deleted, unshared, or temporarily inaccessible on the cloud provider's side due to an API glitch, automatically executing a local delete without manual confirmation could cause catastrophic data loss across a local system. Therefore, it isolates these issues in the **Errors** queue.

        However, you can prevent these errors from popping up entirely by adjusting your Insync rules and settings so the client stops trying to track these files in the first place.

        ---

        ### Strategy 1: Add a Global Ignore Rule for Conflict Folders

        Instead of letting Insync find a conflict folder and throw an error, you can tell Insync to completely ignore any directory that contains the phrase `Selective Sync Conflict`.

        1. Open the Insync interface.

        2. Click on your profile picture/account icon in the top left and go to **Preferences**.

        3. Select **Ignore Rules** (or Sync Rules depending on your version).

        4. Add a new rule for **Folder Name**.

        5. Set it to ignore any folder matching: `(Selective Sync Conflict)*`

        6. Save the rule.

        Insync will instantly drop those paths from its active sync engine database, clearing the error loop.

        ---

        ### Strategy 2: Adjust Global Conflict Preferences (For True File Conflicts)

        While it won't force-delete an orphaned Google Doc stub error, you can change how Insync acts when two actual files conflict (e.g., local changes vs. cloud changes), saving you from clicking through menus later:

        1. Go to **Preferences** in Insync.

        2. Look for the **Conflicts** setting section.

        3. Change it from "Ask me every time" to either **Cloud copy wins** or **Local copy wins**, depending on which copy you want to treat as the absolute ground truth.

        ---

        ### Strategy 3: Clean Out the Remaining Stubs Globally

        The reason you see so many of these errors specifically with Google Docs is that `.gdoc` or `.gslides` files are not real local documents; they are just tiny tracking links containing a URL to the cloud file. When the file is deleted on the cloud, the local shortcut is permanently broken.

        If you are moving away from cloud-dependent formats toward local-first storage, you can run a quick sweep to get rid of these orphaned pointers on your external drive completely so Insync stops complaining about them:

        Bash

        `find "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1" -type f -name "*.gdoc" -delete`

        *(This will permanently delete the* `.gdoc` *shortcut files from the Seagate drive, which instantly clears them from the Insync error queue).*

- Delete any orphan packages

    ```bash
    # List orphans (safe to run anytime)
    pacman -Qtdq
    # Remove orphans (only if the list above is NOT empty)
    sudo pacman -Rns $(pacman -Qtdq)
    # Safer one-liner: removes orphans only when they exist
    sudo pacman -Rns $(pacman -Qtdq 2>/dev/null) 2>/dev/null || true
    # Quick health checks
    systemctl --failed
    sudo journalctl -p 3 -xb
    ```

- Install extension package

    ```text
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    ---
    yay -S extension-manager
    ```

- Install Microcode - Intel

    ```text
    sudo pacman -S intel-ucode
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ```

- Setting up **Epson EcoTank L3560** printer

    Setting up your **Epson EcoTank L3560** on EndeavourOS is straightforward. Since EndeavourOS is Arch-based, you have quick access to the necessary drivers through the Arch User Repository (AUR) using `yay`.

    Here is the step-by-step process to get both the printer and scanner components working.

    ---

    ## Step 1: Install and Enable CUPS

    CUPS (Common UNIX Printing System) manages printing services on Linux. First, ensure it is installed and running on your system.

    1. Open your terminal and run:Bash

        `sudo pacman -Syu cups ghostscript gutenprint`

    2. Enable and start the CUPS service so it automatically launches on boot:Bash

        `sudo systemctl enable --now cups`

    ---

    ## Step 2: Install Epson Drivers via the AUR

    Most modern Epson EcoTank models utilize the ESC/P-R driver framework. You can build and install this package directly using `yay`.

    1. Install the primary Epson driver package:Bash

        `yay -S epson-inkjet-printer-escpr2`

        *(Note: If your specific network configuration has trouble communicating with the* `escpr2` *package later on, the alternative package* `epson-inkjet-printer-escpr` *can be used instead).*

    2. *(Optional)* If you want a GUI tool to check your ink levels and printer status, install the printer utility:Bash

        `yay -S epson-printer-utility`

    ---

    ## Step 3: Add the Printer to Your System

    Ensure your Epson L3560 is powered on and connected to the same local network (via Wi-Fi) or plugged directly into your PC via a USB cable.

    You can add the printer using either your desktop environment's settings panel or the local CUPS web interface:

    ### Option A: Via the CUPS Web Interface (Recommended)

    1. Open your preferred web browser and navigate to: `http://localhost:631`

    2. Click on the **Administration** tab at the top.

    3. Click **Add Printer** (your browser may prompt you for your Linux system username and password).

    4. Select your **Epson L3560** from the list of discovered network or local printers and follow the prompts to complete the setup.

    ### Option B: Via Desktop System Settings

    - If you are using **KDE Plasma**, open **System Settings** > **Printers** > **Add New Printer**.

    - If you are using **GNOME**, open **Settings** > **Printers** > **Add Printer**.

    - Alternatively, if you prefer a standalone graphical tool, install and launch `system-config-printer`:Bas

        `sudo pacman -S system-config-printer`

    ---

    ## Step 4: Configure the Scanner (Optional)

    The L3560 is a multi-function unit. To unlock scanning capabilities, install the official Epson Scan 2 drivers and non-free plugins from the AUR.

    1. Install the scanning drivers:Bash

        `yay -S epsonscan2 epsonscan2-non-free-plugin`

    2. Once installed, you can scan documents directly using the **Epson Scan 2** graphical application from your app menu, or use default Linux utilities like **Document Scanner** (`simple-scan`).

- Setting up **HP LaserJet P1102w** (Wi‑Fi) on EndeavourOS

    The HP LaserJet P1102w is a driverless-ish model on Linux, but it often works best via **HPLIP** (HP’s Linux imaging/printing stack) + **CUPS**.

    ---

    ## 1) Install + enable printing services (CUPS)

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed cups cups-filters ghostscript system-config-printer
    sudo systemctl enable --now cups
    ```

    ```bash
    yay -S hplip-plugin
    ```

    (Optional) Open the firewall for printing (only if you use one):

    ```bash
    sudo ufw allow 631/tcp
    ```

    ---

    ## 2) Install HP drivers/tools

    Install HPLIP and the Qt GUI (recommended):

    ```bash
    sudo pacman -S --needed hplip hplip-qt
    ```

    ---

    ## 3) Ensure the printer is on your Wi‑Fi (router must be 2.4 GHz)

    The P1102w typically only supports **2.4 GHz** networks. If your router uses a combined SSID, ensure it’s truly offering 2.4 GHz as well.

    ---

    ## 4) Add the printer (two good methods)

    ### Method A (GUI): Printer Settings / system-config-printer

    1. Open **Printer Settings** (or run `system-config-printer`).

    2. Click **Add**.

    3. Look for the HP device on the network (it may show as an HP LaserJet / JetDirect / AppSocket entry).

    4. Choose the recommended driver (often **HP LaserJet Professional P1102w, hpcups**).

    5. Print a test page.

    ---

    ### Method B (HP’s wizard): `hp-setup`

    Run:

    ```bash
    hp-setup
    ```

    - Choose **Network/Ethernet/Wireless network** when prompted.

    - If it doesn’t auto-discover, use **Find manually** and enter the printer’s IP address.

    ---

    ## 5) Helpful troubleshooting (quick checks)

    ### Find the printer’s IP on your LAN

    ```bash
    ip neigh | grep -i hp || true
    ```

    Or check your router’s connected devices list.

    ### CUPS web UI

    Open:

    - `http://localhost:631`

    Then go to **Administration → Add Printer**.

    ### If discovery fails

    - Temporarily disable VPN.

    - Make sure your computer and printer are on the same subnet.

    - Reboot the printer, then retry `hp-setup`.

- Setting up Bluetooth on a fresh EndeavourOS KDE install

    On a fresh EndeavourOS **KDE Plasma** install, Bluetooth usually just needs the BlueZ stack installed + the service enabled.

    ### Install the packages

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed bluez bluez-utils bluedevil
    ```

    ### Enable + start the Bluetooth service

    ```bash
    sudo systemctl enable --now bluetooth.service
    ```

    ### (Optional) Verify it’s running

    ```bash
    systemctl status bluetooth.service
    ```

    ### Pair from terminal (optional)

    ```bash
    bluetoothctl
    power on
    agent on
    default-agent
    scan on
    # then: pair <MAC>, trust <MAC>, connect <MAC>
    ```

    After that, open **System Settings → Bluetooth** to pair/manage devices.

# Fixes…

- **Fix: USB Audio Distortion on EndeavourOS (Arch Linux)**

    **Problem:** Audio through USB devices (e.g., CSCTEK USB Audio) exhibits "robotic" distortion, crackling, or grainy sound despite `pw-top` showing zero software errors or xruns.

    **Cause:** The `power-profiles-daemon` (PPD) defaults to a "Balanced" or "Power Saver" profile. This causes aggressive throttling of the USB controller and CPU clock frequencies to save power, which desynchronizes the steady timing required for a USB audio interface's hardware clock.

    ---

    ### **Immediate Solution**

    Switch the system to the Performance profile to ensure a stable voltage and clock rate for the USB bus:

    ```bash
    powerprofilesctl set performance
    ```

    **Verification:**

    Run `powerprofilesctl` to confirm the asterisk `*` is next to `performance`.

    ---

    ### **Optimization & Maintenance**

    1. **Desktop Integration:** In KDE Plasma or GNOME, this can be toggled via the **Battery/Power** icon in the system tray. For stationary work (podcasting/recording), keeping the profile on **Performance** prevents latency and jitter.

    2. **User Permissions:**

        Ensure the user account has real-time priority permissions by being part of the `audio` group:

        ```bash
        sudo usermod -aG audio $USER
        ```

        *(Requires logout/login to take effect)*.

    3. **Check for Hardware Conflicts:**

        High-bandwidth devices like the **Logitech C922 webcam** can saturate the USB bus. If distortion returns, move the audio interface to a different physical USB hub/port (e.g., switching from USB 3.0 to 2.0 or vice versa).

    ---

    ### **Permanent Kernel Override (Optional)**

    If the issue persists specifically on battery power, disable USB autosuspend at the kernel level:

    - **File:** `/etc/default/grub`

    - **Parameter:** Add `usbcore.autosuspend=-1` to `GRUB_CMDLINE_LINUX_DEFAULT`.

    - **Update:** Run `sudo grub-mkconfig -o /boot/grub/grub.cfg`.

# Currently Not Employing These

- Installing Gemma 4 (Google DeepMind) locally

    💡 Gemma is a family of open models from Google DeepMind. Official model cards / downloads: [https://deepmind.google/models/gemma/gemma-4/](https://deepmind.google/models/gemma/gemma-4/)

    - Start with `gemma2:9b-instruct-q4_K_M` as your default.

    - Keep `llama3.1:8b` installed as your “fast fallback.”

    - Add `mistral-nemo:12b` if long-document work is a frequent need.

    ## Option A (recommended): Run Gemma 4 with Ollama

    ### 1) Install Ollama

    - If you prefer the Arch/AUR route:

        ```bash
        yay -S ollama
        ```

    - Enable + start the service:

        ```bash
        sudo systemctl enable --now ollama
        ```

    ### 2) Pull + run Gemma 4

    - What model to install…

        With **32 GB RAM** (and Intel Iris Xe iGPU), you’ll get the best day-to-day experience with a **mid-size, instruction-tuned** model that’s strong at writing, feedback, and lesson-style explanations—without being sluggish.

        ## Recommended (best default for teacher-trainer work)

        ### **Gemma 2 9B Instruct**

        Why: strong writing tone, clear explanations, great “coach/tutor” vibe, and light enough to run smoothly on CPU/RAM.

        Use:

        ```bash
        ollama pull gemma2:9b-instruct-q4_K_M
        ollama run  gemma2:9b-instruct-q4_K_M
        ```

        Library page: [https://ollama.com/library/gemma2:9b](https://ollama.com/library/gemma2:9b)

        ## If you want “most reliable general assistant”

        ### **Llama 3.1 8B**

        Why: very solid general-purpose instruction following + fast on most machines.

        Use:

        ```bash
        ollama pull llama3.1:8b
        ollama run  llama3.1:8b
        ```

        Library page: [https://ollama.com/library/llama3.1:8b](https://ollama.com/library/llama3.1:8b)

        ## If you routinely paste long documents (syllabi, readings, rubrics)

        ### **Mistral NeMo 12B**

        Why: bigger context window; great when you want to analyze *long* lesson plans, student drafts, or multi-page docs in one go (it may feel a bit slower than the two above).

        Use:

        ```bash
        ollama pull mistral-nemo:12b
        ollama run  mistral-nemo:12b
        ```

        Library page: [https://ollama.com/library/mistral-nemo:12b](https://ollama.com/library/mistral-nemo:12b)

        ### My practical pick for you

        - Start with `gemma2:9b-instruct-q4_K_M` as your default.

        - Keep `llama3.1:8b` installed as your “fast fallback.”

        - Add `mistral-nemo:12b` if long-document work is a frequent need.

        If you tell me your *most common tasks* (e.g., “feedback on paragraphs,” “generate activities,” “rewrite for CEFR,” “summarize readings,” etc.), I’ll pick **one** and give you a ready-to-copy “system prompt” tailored for teacher-trainer use.

    - How to uninstall a model

        To remove an Ollama model you’ve already installed, use `ollama rm`.

        ### 1) See what you have installed

        ```bash
        ollama list
        ```

        ### 2) Remove the model (use the exact name shown in `ollama list`)

        ```bash
        ollama rm <MODEL:TAG>
        ```

        Examples:

        ```bash
        ollama rm gemma2:9b-instruct-q4_K_M
        ollama rm llama3.1:8b
        ollama rm mistral-nemo:12b
        ```

        ### If it says it’s “in use”

        Quit any running `ollama run ...` session (Ctrl+D), then try again:

        ```bash
        ollama rm <MODEL:TAG>
        ```

        If you paste the output of `ollama list`, I can tell you the exact `ollama rm ...` command(s) to run.

    1. Check the exact Gemma 4 tag name available in [https://ollama.com/library](https://ollama.com/library).

    2. Then pull and run it (replace `<TAG>` with the library’s exact tag):

        ```bash
        ollama pull <TAG>
        ollama run <TAG>
        ```

    ### 3) (Optional) Run as an API for other apps

    Ollama exposes a local API (defaults to `http://127.0.0.1:11434`). Many clients can connect to it directly.

    ---

    ## Option B: Run Gemma 4 with llama.cpp (more control)

    This option is useful if you want full control over quantization, GPU offload, and performance tuning.

    ### 1) Install build + GPU prerequisites

    ```bash
    sudo pacman -S --needed base-devel cmake git python
    ```

    - **NVIDIA (CUDA)**:

        ```bash
        sudo pacman -S --needed cuda
        ```

    - **AMD/Intel (ROCm/Vulkan)**: use the Vulkan backend if ROCm is not ideal for your hardware.

    ### 2) Build llama.cpp

    ```bash
    git clone https://github.com/ggerganov/llama.cpp
    cd llama.cpp
    cmake -S . -B build
    cmake --build build -j
    ```

    ### 3) Download Gemma 4 weights + convert if needed

    - Download the official Gemma 4 model files from the Gemma page above (or the linked repository).

    - If the download is not already in `GGUF`, you’ll need to convert to `GGUF` (llama.cpp includes conversion scripts).

    ### 4) Run

    ```bash
    ./build/bin/llama-cli -m /path/to/gemma4.gguf -p "Write a short test response." -n 128
    ```

    ---

    ## Notes (Arch / EndeavourOS)

    - Start with a smaller **quantized** model if you’re RAM-limited.

    - Expect *much* higher memory use if you keep many apps (especially browsers/Notion) open while running the model.

- Installing MediaTek MT7902 Drivers (for ASUS VivoBook-Wifi)

    Installing the MediaTek MT7902 on Linux has historically been a headache because it wasn't supported by the mainline kernel for a long time. However, as of April 2026, official support is finally landing in **Kernel 7.1**.

    Since you are on EndeavourOS (Arch-based), you have two main routes: the "Bleeding Edge" way (waiting for/installing the latest kernel) or the "Workaround" way (using a community driver).

    ### **Option 1: The Modern Way (Check for Kernel 7.1+)**

    If you can wait or if your system is fully updated, Kernel 7.1 includes the mt76 patches for the MT7902.

    1. **Check your current kernel version:**

        Bash

        uname -r

    2. **Update your system:** Since EndeavourOS is rolling-release, Kernel 7.1 might already be available in the testing or main repositories.

        Bash

        sudo pacman -Syu

    3. **Install latest firmware:** Ensure you have the newest firmware package from the AUR or official repos.

        Bash

        yay -S linux-firmware-mediatek

    ### **Option 2: The Community Driver (Workaround)**

    If you are on an older kernel (like 6.x) and need Wi-Fi immediately, you'll need to compile a patched driver. You will need a temporary internet connection (like **USB Tethering** from your phone).

    ### **1. Install Build Dependencies**

    Bash

    sudo pacman -S base-devel linux-headers git bc zstd

    ### **2. Use the AUR (Recommended for EndeavourOS)**

    There is a community-maintained version available in the AUR that automates the "temp" fix often found on GitHub.

    Bash

    yay -S mt7902-firmware-git

    ### **3. Manual Build (If AUR fails)**

    If the AUR package doesn't work for your specific kernel, you can use the community "temp" repository which has been the standard fix for Vivobook users:

    1. **Clone the repo:**

        Bash

        git clone --depth 1 [https://github.com/OnlineLearningTutorials/mt7902_temp](https://github.com/OnlineLearningTutorials/mt7902_temp)

        cd mt7902_temp

    2. **Inject the missing header:** (This is a specific requirement for this chipset on older kernels).

        Bash

        sudo mkdir -p /usr/src/linux-headers-$(uname -r)/include/linux/soc/airoha

        curl -sL "[https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/linux/soc/airoha/airoha_offload.h?h=v6.19](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/linux/soc/airoha/airoha_offload.h?h=v6.19)" | sudo tee /usr/src/linux-headers-$(uname -r)/include/linux/soc/airoha/airoha_offload.h > /dev/null

    3. **Run the install script:**

        Bash

        sudo bash fix_my_wifi.sh

        *Note: It might throw a Bluetooth error at the very end; you can usually ignore this as long as the Wi-Fi module builds.*

    ### **Troubleshooting**

    - **Secure Boot:** If you have Secure Boot enabled in your BIOS, the kernel will refuse to load these manually compiled "unsigned" drivers. **Disable Secure Boot** in your ASUS BIOS settings.

    - **Kernel Updates:** If you use the manual method (Option 2), you will need to re-run the installation every time the kernel updates, until you move to Kernel 7.1+.

    - **Hardware Check:** Run lspci -k | grep -A 3 Network to confirm the system sees the device and check if a driver is currently "in use."

    Do you have a way to tether your phone for the initial download, or do we need to look into an offline installation method?

    **Sources**

    1. [https://www.reddit.com/r/linuxhardware/comments/1sdims1/fix_mediatek_mt7902_wifi_on_linux_kernel_617/](https://www.reddit.com/r/linuxhardware/comments/1sdims1/fix_mediatek_mt7902_wifi_on_linux_kernel_617/)

    2. [https://www.reddit.com/r/linuxhardware/comments/1sdims1/fix_mediatek_mt7902_wifi_on_linux_kernel_617/](https://www.reddit.com/r/linuxhardware/comments/1sdims1/fix_mediatek_mt7902_wifi_on_linux_kernel_617/)

- Installing tp-link TL-WN725N Nano USB Adapter (150 Mbps)

    Since you already have **Extension Manager** installed, you can skip the clunky browser-based installation. However, the `system-monitor-next` extension is a bit special—it requires a few system dependencies to actually read your CPU and RAM data before it will work.

    Follow these steps to get it running:

    ### 1. Install the Prerequisites

    The extension relies on system libraries (`libgtop` and `clutter`) to pull hardware stats. Run this in your terminal:

    Bash

    `sudo pacman -S libgtop networkmanager gnome-system-monitor`

    ### 2. Install via Extension Manager

    Now that the "brains" of the operation are installed, you can add the extension:

    1. Open **Extension Manager** from your app menu.

    2. Click the **Browse** tab at the top.

    3. Search for `system-monitor-next`.

    4. Click **Install**.

    ### 3. Troubleshooting "Error" status

    If you see an "Error" or "Incompatible" message after installing:

    - **Restart GNOME Shell:** Since you are likely on Wayland (default for Vivobooks), you need to log out and log back in to refresh the shell.

    - **Check Settings:** Once enabled, click the **gear icon** in Extension Manager to configure which stats show up in your top bar (CPU, RAM, Net, etc.).

    ---

    ### Alternative: The AUR Version

    If the version in Extension Manager gives you any trouble with your specific GNOME version, there is a community-maintained version in the AUR that is often patched more quickly for Arch users:

    Bash

    `yay -S gnome-shell-extension-system-monitor-next-git`

    This version usually handles the dependencies automatically and integrates perfectly with your systemd-boot setup.

    **How is the system holding up after all those installs? Is the Vivobook fans finally quiet after the kernel compile?**

- Upgrading to Zen Kernel

    To get the latest kernel on EndeavourOS, you have two great options. Since you are on an Arch-based system, the "Standard" kernel is already very close to the bleeding edge, but you can go even further if you need the absolute latest (like Kernel 7.1 for your MT7902).

    ### **Option 1: The EndeavourOS "AKM" Tool (Easiest)**

    EndeavourOS comes with a built-in GUI tool called **AKM** (A Kernel Manager). It is the safest way to manage multiple kernels without messing up your bootloader manually.

    1. Open your application menu and search for **AKM**.

    2. In the list, you will see several options:

    - **linux:** The standard Arch kernel (usually very current).

    - **linux-zen:** A kernel optimized for desktop responsiveness (often gets new features/patches quickly).

    - **linux-mainline:** The absolute latest development/stable kernel from kernel.org (available via the AUR).

    1. Tick the box for the kernel you want, click **Execute**, and let it install.

    2. **Important:** Once finished, reboot.

    ### **Option 2: Using the Terminal (Fastest)**

    If you want to stick to the command line, you can install the mainline or Zen kernel directly.

    **To install the Zen Kernel (highly recommended for modern laptops):**

    Bash

    sudo pacman -S linux-zen linux-zen-headers

    **To install the Mainline Kernel (the absolute latest):**

    The mainline kernel is usually in the AUR. Use yay:

    Bash

    yay -S linux-mainline linux-mainline-headers

    ### **Step 3: Booting into the New Kernel**

    After installing, you need to tell your computer to actually *use* it. EndeavourOS uses either **systemd-boot** or **GRUB** depending on your installation choice.

    ### **If you use systemd-boot (Default for newer installs):**

    1. Reboot your laptop.

    2. When the boot menu appears, use the arrow keys to highlight your new kernel.

    3. Press **'d'** to set it as the **default** for future boots.

    ### **If you use GRUB:**

    1. Run this command to update the menu:

        Bash

        sudo grub-mkconfig -o /boot/grub/grub.cfg

    2. Reboot and select the new kernel under "Advanced options for EndeavourOS."

    ### **How to verify it worked:**

    Once you log back in, run:

    Bash

    uname -r

    If it says **7.1** or higher, check your Wi-Fi settings—your MediaTek MT7902 should now be recognized natively without that "temp" driver fix!

    - Update system

        ### The Final Step: Update and Install

        Run the following commands to get the mainline kernel. This will ensure you have the best chance for that MT7902 driver to work natively:

        Bash

        `# Update everything first
        sudo pacman -Syu

        # Install the mainline kernel and its headers

        yay -S linux-mainline linux-mainline-headers`

        ### How to Switch During Reboot

        1. **Reboot** your laptop.

        2. **Tap the Arrow Keys or Spacebar** repeatedly as soon as the ASUS logo disappears. This forces the systemd-boot menu to stay open.

        3. Highlight **EndeavourOS (linux-mainline)**.

        4. **Press 'd'**: This sets the mainline kernel as your **default** boot option so you don't have to select it every time.

        5. Press **Enter** to boot.

        ---

        ### Verification

        Once you are back at your desktop, run:

        Bash

        `uname -r`

        You should see something like `7.1.x-mainline`.

        At this point, check your network settings. If the driver is working, your Wi-Fi networks should start appearing automatically. If they don't, we might just need to load the module manually with `sudo modprobe mt7603` (or the specific mt7902 module), but in Kernel 7.1+, it should happen on its own.

        How did the installation go—did the `yay` command finish without any errors?

- Install Microcode - AMD

    ```text
    sudo pacman -S amd-ucode
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ```

- Install PipeWire

    ```text
    sudo pacman -S pipewire
    ```

- Install Gnome Tweaks

    ```text
    sudo pacman -S gnome-tweak-tool
    ```
