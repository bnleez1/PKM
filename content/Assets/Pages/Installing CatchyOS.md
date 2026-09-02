---
type: 'Page'
collections: 'Public Pages'
title: Installing CatchyOS
aliases: null
description: null
icon: 🖱️
createdAt: '2026-06-17T17:00:40.685Z'
lastUpdated: '2026-08-07T21:00:10.430Z'
tags: []
coverImage: '[Untitled](../Images/Untitled%20(156).md)'
---

# Installing CatchyOS

# Terminal Considerations

- Installing wallpapers (terminal)

    The easiest and safest method is to install the **official CachyOS and KDE wallpaper packages** through Pacman. This gives you a large, curated collection without downloading images individually.

    ## 1. Install the official wallpaper collections

    Open **Konsole** and run:

    ```bash
    sudo pacman -Syu cachyos-wallpapers plasma-workspace-wallpapers
    ```

    Enter your password when prompted. Nothing will appear while you type the password; this is normal.

    The current official CachyOS package occupies about **154 MB** after installation and includes numerous CachyOS-branded images, including a 5K wallpaper. The KDE collection adds roughly **255 MB** of additional wallpapers. (GitHub)

    For an even larger collection, add the GNOME and COSMIC wallpaper packages:

    ```bash
    sudo pacman -S gnome-backgrounds cosmic-wallpapers
    ```

    ## 2. Find the downloaded wallpapers

    Most will be installed here:

    ```text
    /usr/share/wallpapers/
    ```

    The CachyOS-specific collection should be under:

    ```text
    /usr/share/wallpapers/cachyos-wallpapers/
    ```

    Open it in Dolphin with:

    ```bash
    dolphin /usr/share/wallpapers/
    ```

    ## 3. Use them as a rotating slideshow

    1. Right-click an empty area of the desktop.

    2. Select **Configure Desktop and Wallpaper**.

    3. Change the wallpaper type from **Image** to **Slideshow**.

    4. Select **Add Folder**.

    5. Enter:

    ```text
    /usr/share/wallpapers/
    ```

    1. Choose how frequently KDE should change the image.

    2. Click **Apply**.

    Using `/usr/share/wallpapers/` includes the CachyOS, KDE, GNOME, and COSMIC collections you installed.

    ## 4. Optional: copy them into your Pictures folder

    System wallpaper packages are stored outside your home folder. To create your own editable collection, run:

    ```bash
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp -r /usr/share/wallpapers/* "$HOME/Pictures/Wallpapers/"
    ```

    You can then delete unwanted images, reorganize folders, or synchronize the collection with pCloud. The originals in `/usr/share/wallpapers/` remain untouched.

    ## Recommended setup

    Install all four collections:

    ```bash
    sudo pacman -Syu cachyos-wallpapers plasma-workspace-wallpapers gnome-backgrounds cosmic-wallpapers
    ```

    Then point KDE’s slideshow at:

    ```text
    /usr/share/wallpapers/
    ```

    This is preferable to downloading random wallpaper archives because Pacman handles updates, file placement, and package integrity automatically.

    [1]: https://github.com/CachyOS/cachyos-wallpapers "GitHub - CachyOS/cachyos-wallpapers: Wallpapers for CachyOS · GitHub"

- Printer setup (home with Epson L3560 printer)

    Only the HP-specific package `hplip` is installed. Remove it with:

    ```bash
    sudo pacman -Rns hplip
    ```

    Review the removal list before confirming. It should remove `hplip` and possibly unused HP-related dependencies, but it should **not** remove core packages such as:

    ```text
    cups
    cups-filters
    avahi
    sane
    ```

    After removal, verify:

    ```bash
    pacman -Q | grep -Ei '^(hplip|hplip-plugin|hpijs|hpoj)\b'
    ```

    No output means the HP packages are gone.

    Then install the Epson L3560 foundation:

    ```bash
    sudo pacman -S cups cups-filters print-manager system-config-printer \
      avahi sane sane-airscan simple-scan
    ```

    Enable printing and network-printer discovery:

    ```bash
    sudo systemctl enable --now cups.service
    sudo systemctl enable --now avahi-daemon.service
    ```

    For a **USB-connected** Epson L3560, also install and enable:

    ```bash
    sudo pacman -S ipp-usb
    sudo systemctl enable --now ipp-usb.service
    ```

    Then open:

    **System Settings → Printers → Add Printer**

    Choose the Epson entry labeled **Driverless**, **IPP Everywhere**, or **AirPrint**.

- Install Poco if installing Collabora-Office package

    This is a **current AUR packaging problem**, not a compiler problem on your CachyOS installation. The `collabora-office` recipe does not currently declare `poco` as a dependency, although the build falls back to system POCO and requires `Poco/Net/WebSocket.h`. Other users reported the same failure in July 2026. The official Arch `poco` package contains that exact header.

    ## 1. Install the missing POCO package

    ```bash
    sudo pacman -Syu poco
    ```

    Verify that the required file is now installed:

    ```bash
    pacman -Ql poco | grep '/Poco/Net/WebSocket.h$'
    ```

    You should see:

    ```text
    poco /usr/include/Poco/Net/WebSocket.h
    ```

    ## 2. Rebuild Collabora Office cleanly

    Run:

    ```bash
    paru -S collabora-office
    ```

    This time, when prompted:

    ```text
    ==> Packages to cleanBuild?
    ```

    enter:

    ```text
    A
    ```

    Do **not** select `N`. A clean build is appropriate because the previous configuration attempt was performed before POCO was installed.

    For:

    ```text
    ==> Diffs to show?
    ```

    you may enter:

    ```text
    N
    ```

    ## 3. If Paru still reuses the failed build directory

    Remove only Collabora Office’s cached AUR build directory:

    ```bash
    rm -rf ~/.cache/paru/clone/collabora-office
    ```

    Then retry:

    ```bash
    paru -S collabora-office
    ```

    Do not run `paru` with `sudo`; it will request your password when it needs to install the finished package.

    ## Why this should correct it

    Your log shows:

    ```text
    configure: POCO not found in the engine workdir, falling back to system POCO
    ...
    checking for Poco/Net/WebSocket.h... no
    ```

    Installing `poco` supplies:

    ```text
    /usr/include/Poco/Net/WebSocket.h
    ```

    The configure check should then change to:

    ```text
    checking for Poco/Net/WebSocket.h... yes
    ```

    The AUR maintainer recently removed the POCO dependency because it was expected to be bundled in the provided engine assets, but multiple users found that the bundled detection was not working consistently.

- Setting up SyncThing

- Installing fonts

    Install `paru` once manually, then use it for the font packages:

    ```bash
    sudo pacman -Syu --needed base-devel git rust
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru
    makepkg -si
    cd ..
    ```

    Do **not** run `makepkg` with `sudo`; it builds as your normal user and asks for your password only when installing the finished package.

    Then install the fonts:

    ```bash
    paru -S ttf-ms-fonts ttf-google-fonts-git
    fc-cache -f
    ```

    You can delete the temporary Paru build folder after it installs:

    ```bash
    rm -rf ~/paru
    ```

    If you only need the Microsoft fonts and do not want an AUR helper, build that package directly instead:

    ```bash
    sudo pacman -Syu --needed base-devel git
    git clone https://aur.archlinux.org/ttf-ms-fonts.git ~/ttf-ms-fonts
    cd ~/ttf-ms-fonts
    makepkg -si
    fc-cache -f
    ```

    Before running `makepkg`, it’s good practice to open and review the package’s `PKGBUILD`; AUR packages are community-maintained rather than repository packages. [ArchWiki AUR guidance](https://wiki.archlinux.org/title/Arch_User_Repository)

- Install WinBoat dependencies (CachyOS)

    WinBoat relies on a few system components: **KVM virtualization**, **Docker**, **Docker Compose v2**, having your user in the **docker** group, and ensuring the **Docker daemon** is running.

    ### 1) Enable virtualization (BIOS/UEFI)

    - Reboot and enter BIOS/UEFI.

    - Enable **Intel VT-x** / **AMD-V (SVM)**.

    - Save and reboot.

    ### 2) Confirm KVM is available

    ```bash
    lsmod | grep -E "kvm|kvm_intel|kvm_amd" || true
    ```

    If nothing prints, install/enable the modules:

    - Intel:

        ```bash
        sudo pacman -S --needed intel-ucode
        sudo modprobe kvm_intel
        ```

    - AMD:

        ```bash
        sudo pacman -S --needed amd-ucode
        sudo modprobe kvm_amd
        ```

    (Optional validation)

    ```bash
    egrep -c '(vmx|svm)' /proc/cpuinfo
    ```

    ### 3) Install Docker + Docker Compose (v2)

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed docker docker-compose
    ```

    ### 4) Add your user to the docker group (then re-log)

    ```bash
    sudo usermod -aG docker $USER
    ```

    Then **log out and log back in** (or reboot) so the group change applies.

    Verify:

    ```bash
    groups | grep docker || echo "docker group not active (relog needed)"
    ```

    ### 5) Start Docker now + enable it on boot

    ```bash
    sudo systemctl enable --now docker
    sudo systemctl status docker --no-pager
    ```

    ### 6) Quick checks WinBoat expects

    ```bash
    docker --version
    docker compose version
    docker run --rm hello-world
    ```

- Install `yay` (AUR helper) on CachyOS

    `yay` lets you install packages from the **AUR** (Arch User Repository). CachyOS is Arch-based, so the standard install method applies.

    ### 1) Install prerequisites

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed base-devel git
    ```

    ### 2) Clone the `yay` repo from AUR

    ```bash
    cd ~
    git clone https://aur.archlinux.org/yay.git
    cd yay
    ```

    ### 3) Build + install

    ```bash
    makepkg -si
    ```

    ### 4) Quick test

    ```bash
    yay --version
    yay -Syu
    ```

    ### Notes

    - During `makepkg -si`, you may be prompted to review PKGBUILD files; that’s normal.

    - If you ever want to remove `yay` later:

        ```bash
        sudo pacman -Rns yay
        ```

- Setting up rclone like Google Drive App

    - How to remove rclone like Google Drive App

        These steps remove the **systemd user service**, unmount the folder, remove the **remote config**, clear **VFS cache**, and uninstall **rclone + fuse3** (the dependencies used in this setup).

        ### 0) Stop the mount (if running) and unmount

        ```bash
        systemctl --user stop rclone-gdrive.service 2>/dev/null || true
        fusermount3 -uz ~/GoogleDrive 2>/dev/null || true
        ```

        ### 1) Disable the service so it doesn’t come back on reboot

        ```bash
        systemctl --user disable rclone-gdrive.service 2>/dev/null || true
        ```

        ### 2) Remove the systemd service file

        ```bash
        rm -f ~/.config/systemd/user/rclone-gdrive.service
        systemctl --user daemon-reload
        systemctl --user reset-failed
        ```

        ### 3) Remove the mount folder (optional)

        Only do this if you don’t want the empty folder to remain.

        ```bash
        rmdir ~/GoogleDrive 2>/dev/null || true
        ```

        ### 4) Remove the rclone config (remotes, tokens)

        This deletes the Google Drive remote and its OAuth token.

        ```bash
        rm -f ~/.config/rclone/rclone.conf
        ```

        ### 5) Remove rclone cache (recommended)

        This removes any cached file contents created by `--vfs-cache-mode full`.

        ```bash
        rm -rf ~/.cache/rclone
        ```

        ### 6) Uninstall packages

        ```bash
        sudo pacman -Rns rclone fuse3
        ```

        ### 7) Quick sanity checks (optional)

        ```bash
        which rclone || echo "rclone removed"
        systemctl --user list-unit-files | grep rclone || echo "no rclone service"
        mount | grep -i GoogleDrive || echo "not mounted"
        ```

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

- Setting up rclone to mirror external hard drive with Google Drive

    - Info on depreciating API keys

        I've got good news: you actually don't need to worry about this deprecation for your syncing setup, because there's a slight mix-up in how `rclone` authenticates.

        `rclone` does not use Generative Language API or Google AI Studio keys. It relies entirely on the **Google Drive API** to move your files.

        Here is how the two differ and how to permanently solve your syncing limitations.

        ## The Mix-Up: AI Keys vs. Drive Credentials

        - **Generative Language API (Google AI Studio):** These keys are strictly for accessing Google's AI models (like Gemini). You are correct that Google is deprecating standard AI keys in September 2026, but **this has absolutely no impact on** `rclone` **or file syncing.**

        - **Google Drive API:** This is the pipeline `rclone` uses to interact with your Google Drive. It uses **OAuth 2.0 Credentials** (a Client ID and a Client Secret) generated through the Google Cloud Console, not AI Studio.

        ## The Real Fix for Syncing Limitations

        The `403 Quota Exceeded` error you experienced earlier happened because you are currently using `rclone`'s default, shared Google Drive Client ID. When you use the default ID, you share a rate limit with thousands of other users globally.

        To permanently bypass this bottleneck and get your own dedicated sync quota, you need to generate your own Google Drive API credentials.

        1. **Create a Google Cloud Project:**
        Go to the [Google Cloud Console](https://console.cloud.google.com/), sign in, and create a new project (this is completely free).

        2. **Enable the Google Drive API:**
        Navigate to **APIs & Services > Library**, search for "Google Drive API," and click **Enable**.

        3. **Configure the OAuth Consent Screen:**
        Go to **APIs & Services > OAuth consent screen**. Choose **External**, fill in the required app name and email fields, and add your own Google account as a "Test User."

        4. **Generate Your Credentials:**
        Go to **APIs & Services > Credentials**. Click **Create Credentials** and select **OAuth client ID**. Choose **Desktop app** as the application type.

        5. **Add to Rclone:**
        Google Cloud will give you a **Client ID** and a **Client Secret**. Run `rclone config`, edit your existing Google Drive remote, and paste these two strings when prompted.

        Once you complete these steps, your `bisync` commands will use your private, unshared quota, vastly reducing the chance of hitting those rate limits again.

    To achieve an automated, bidirectional sync—similar to InSync—between your external Seagate hard drive and Google Drive on CachyOS, you will want to use `rclone bisync`.

    Because InSync relies on real-time file watching (which can be resource-intensive and tricky to configure purely from the command line for external drives), the most robust and native Linux approach is to use `rclone` paired with a **systemd user timer**. This will automatically trigger the sync a minute after you boot, and then continuously check for and mirror changes every few minutes in the background, pausing safely if the drive is ever unplugged.

    Here is the step-by-step process to set this up.

    ---

    ### **Step 1: Install Rclone**

    Because CachyOS is based on Arch Linux, `rclone` is readily available in the official repositories.

    Open your terminal and install it:

    ```bash
    sudo pacman -S rclone
    ```

    ### **Step 2: Authenticate Google Drive**

    You need to link your Google Drive to `rclone`.

    1. Run the configuration tool:

    ```bash
    rclone config
    ```

    1. Type `n` for **New remote**.

    2. Name the remote (for this guide, type `gdrive`).

    3. Scroll through the list of storage providers and type the number corresponding to **Google Drive** (usually `18`).

    4. Leave `client_id` and `client_secret` blank (just press **Enter**) unless you have your own API keys.

    5. Choose `1` for full access to all files.

    6. Leave `service_account_file` blank.

    7. Type `n` for advanced config.

    8. Type `y` to use auto-config. This will open a browser window asking you to log into your Google account and grant Rclone permissions.

    9. If asked about a Shared Drive, answer according to your needs (usually `n`).

    10. Type `y` to accept the configuration, and `q` to quit.

    ### **Step 3: Perform the Initial Sync**

    Before `bisync` can run in the background, it requires a "First Run" to establish the baseline of your files and create tracking data.

    > **A Quick Warning:** You mentioned wanting to mirror to your *entire* Google Drive (the root directory). While the command below does exactly that, be aware that if you already have files in Google Drive, they will be pulled down to your Seagate drive, and everything on the Seagate will be pushed to the main page of your Google Drive.

    Make sure your hard drive is mounted, then run the initial sync:

    ```bash
    rclone bisync /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1 gdrive: --resync --create-empty-src-dirs -v
    ```

    ```bash
    rclone bisync /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 gdrive: --resync --create-empty-src-dirs -v
    ```

    *Depending on the size of your drive, this might take a while. Let it finish completely.*

    ---

    ### **Step 4: Automate the Sync with Systemd**

    To make this behave like InSync, we will create a background service that automatically syncs the two locations without you needing to think about it.

    #### **1. Create the Service File**

    This file tells your system *how* to run the sync, and ensures it only runs if the Seagate drive is actually plugged in and mounted.

    Create the necessary directories:

    ```bash
    mkdir -p ~/.config/systemd/user/
    ```

    Create and open the service file:

    ```bash
    nano ~/.config/systemd/user/rclone-bisync.service
    ```

    Paste the following configuration into the file:

    ```text
    [Unit]
    Description=Rclone Bidirectional Sync for Seagate Drive
    After=network-online.target
    Wants=network-online.target
    # This ensures the sync safely aborts if your external drive is unplugged
    RequiresMountsFor=/mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1
    [Service]
    Type=oneshot
    # The sync command. --resilient and --recover help it bounce back from unexpected unmounts or network drops.
    ExecStart=/usr/bin/rclone bisync /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1 gdrive: --create-empty-src-dirs --resilient --recover
    ```

    ```text
    [Unit]
    Description=Rclone Bidirectional Sync for Seagate Drive
    After=network-online.target
    Wants=network-online.target
    # This ensures the sync safely aborts if your external drive is unplugged
    RequiresMountsFor=/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    [Service]
    Type=oneshot
    # The sync command. --resilient and --recover help it bounce back from unexpected unmounts or network drops.
    ExecStart=/usr/bin/rclone bisync /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 gdrive: --create-empty-src-dirs --resilient --recover
    ```

    *(Save and exit:* `Ctrl+O`*,* `Enter`*,* `Ctrl+X`*)*

    #### **2. Create the Timer File**

    This file tells your system *when* to run the sync.

    Create and open the timer file:

    ```bash
    nano ~/.config/systemd/user/rclone-bisync.timer
    ```

    Paste the following configuration:

    ```text
    [Unit]
    Description=Run Rclone BiSync every 5 minutes
    RequiresMountsFor=/mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1
    [Timer]
    # Starts the first sync 1 minute after you boot up
    OnBootSec=1m
    # Runs the sync continuously every 5 minutes
    OnUnitActiveSec=5m
    [Install]
    WantedBy=timers.target
    ```

    ```text
    [Unit]
    Description=Run Rclone BiSync every 5 minutes
    RequiresMountsFor=/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    [Timer]
    # Starts the first sync 1 minute after you boot up
    OnBootSec=1m
    # Runs the sync continuously every 5 minutes
    OnUnitActiveSec=5m
    [Install]
    WantedBy=timers.target
    ```

    *(Save and exit:* `Ctrl+O`*,* `Enter`*,* `Ctrl+X`*)*

    ---

    ### **Step 5: Enable and Start the Automation**

    Finally, you just need to tell systemd to activate the timer you just built.

    1. Reload systemd so it sees your new files:

    ```bash
    systemctl --user daemon-reload
    ```

    1. Enable and start the timer:

    ```bash
    systemctl --user enable --now rclone-bisync.timer
    ```

    1. *(Optional)* If you want this sync to run in the background even when you are logged out of your CachyOS user account, run this command to enable lingering:

    ```bash
    loginctl enable-linger $USER
    ```

    Your external hard drive and your Google Drive are now successfully mirrored. The system will automatically check for changes on both sides every 5 minutes and resolve them quietly in the background. If you unplug the drive, the timer will safely fail until you plug the drive back into that exact mount point, at which point it will seamlessly pick up where it left off.

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

    Two optional checks (only if you want extra confirmation):

    1. Verify the schedule systemd sees:

    ```bash
    systemctl list-timers --all | grep fstrim
    ```

    1. If you want to run TRIM immediately once (separate from the weekly timer):

    ```bash
    sudo systemctl start fstrim.service
    sudo systemctl status fstrim.service
    ```

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
    yay -S onlyoffice-bin teams-for-linux prospect-mail notion-app-electron preload ttf-ms-fonts ttf-vista-fonts whatsie scrivener pspp qualcoder-bin pdfarranger-git okular-git python-unoserver webapp-manager-git ytmdesktop krita-git morgen-git rutorrent
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

- Installing Waydroid (gmail package)

    To run the Android Gmail app natively on your system, the best tool available is **Waydroid**. Waydroid uses a container-based approach to boot a full Android system directly on a GNU/Linux system.

    Because you are running CachyOS (often misspelled as CatchyOS!), you are actually in a great position. The default CachyOS kernel is already optimized for Waydroid, meaning the necessary binder modules are built-in and you do not need to install any messy third-party DKMS drivers.

    Here is how to get Waydroid set up with Google Apps (GAPPS) so you can download and run Gmail.

    ### 1. Install and Initialize Waydroid

    Because Gmail relies on Google Play Services, you must initialize Waydroid using the Google Apps (GAPPS) image rather than the standard vanilla image.

    Open your terminal and run the following commands:

    ```bash
    # Install the Waydroid package
    sudo pacman -S waydroid
    # Initialize Waydroid and download the LineageOS image with Google Apps support
    sudo waydroid init -s GAPPS
    ```

    ### 2. Enable Network Forwarding

    Sometimes, Waydroid will install but fail to connect to the internet out-of-the-box on CachyOS. To ensure your Android container has internet access to download your emails, configure your IP forwarding by running these commands:

    ```bash
    echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-waydroid.conf
    echo "net.ipv4.conf.all.forwarding = 1" | sudo tee -a /etc/sysctl.d/99-waydroid.conf
    sudo sysctl --system
    ```

    ### 3. Start the Services

    Next, you need to enable the background service and start your Android session. Note that Waydroid only runs natively if you are using a Wayland session manager.

    ```bash
    # Start and enable the container service
    sudo systemctl enable --now waydroid-container
    # Launch the full Android UI
    waydroid show-full-ui
    ```

    ### 4. Install Gmail

    1. **Device Certification:** Because this is an unofficial Android environment, Google Play might initially say your device is uncertified. If this happens, you will need to open the Waydroid shell (`sudo waydroid shell`), find your Android ID, and register it on Google's uncertified device page.

    2. **Download Gmail:** Once the Google Play Store is working, sign in with your Google account and download the Gmail app directly.

    3. **Desktop Integration:** Waydroid integrates directly with Linux. Once installed, the Android Gmail app will show up right inside your regular CachyOS application launcher alongside your Linux apps.

- Changing key binding from Application Launcher to Overview Effect

    Go to Keyboard shortcuts and look for "toggle overview", "Window Management", or something similar.

- Delete any orphan packages

    ```text
    sudo pacman -Rns $(pacman -Qtdq)
    sudo systemctl --failed
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

- Setting up HP LaserJet P1102w Printer Failed - Dealbreaker

    Below is the **recommended** setup path for the **HP LaserJet P1102w** on **CachyOS / Arch**. This model is picky because it often needs the **HPLIP plugin** (firmware) and benefits from being set up **by USB first**.

    ---

    ## Recommended setup (USB-first, then Wi‑Fi)

    ### 0) Prereqs: confirm you’re on the printing stack you expect

    - If you’re using **CUPS** (common and fine), proceed as below.

    - If you’re using **cups-browsed/IPP-only** workflows and this printer is unreliable, fall back to the CUPS approach below (this printer is older and can be temperamental with modern “driverless” assumptions).

    ---

    ### 1) Install the required packages

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed cups hplip system-config-printer
    ```

    Optional but commonly helpful:

    ```bash
    sudo pacman -S --needed ghostscript gsfonts
    ```

    ---

    ### 2) Enable and start CUPS

    ```bash
    sudo systemctl enable --now cups.service
    ```

    Open the local CUPS web UI (optional but useful for troubleshooting):

    - [http://localhost:631](http://localhost:631)

    ---

    ### 3) Plug the printer in via USB and confirm detection

    ```bash
    lsusb | grep -i hp || true
    lpinfo -v | grep -i hp || true
    ```

    ---

    ### 4) Install the HPLIP proprietary plugin (this is often the missing piece)

    The P1102w frequently needs the plugin to print reliably.

    1. Run:

        ```bash
        sudo hp-plugin
        ```

    2. Accept the license and let it download/install the plugin.

    If the plugin download fails, it’s usually because of network/DNS/TLS issues at the time — retry after confirming you can reach HP’s servers.

    ---

    ### 5) Run HP setup (recommended) or add via GUI

    **Recommended (HP tool):**

    ```bash
    sudo hp-setup -i
    ```

    - Choose the **USB** connection first.

    - If/when offered, select the **HPLIP / hpcups** driver option.

    **Alternative (GUI):**

    - Open **Print Settings** (`system-config-printer`)

    - Add the printer and choose an **HPLIP/hpcups** driver if prompted.

    ---

    ### 6) Verify printing

    ```bash
    lpstat -t
    hp-testpage
    ```

    If `hp-testpage` fails, try printing a small text file through CUPS:

    ```bash
    echo "test" | lp
    ```

    ---

    ## Optional: switch to Wi‑Fi after USB setup

    Once USB printing works, you can configure Wi‑Fi.

    - Use the HP wizard if available:

        ```bash
        sudo hp-setup -i
        ```

        and choose the **Network/Wireless** path.

    - Or add the printer in CUPS as a network printer after it has joined Wi‑Fi.

    Practical note: Many people keep this printer as **USB-only** on Linux for maximum reliability, even if Wi‑Fi is technically possible.

    ---

    ## Common fixes (if it still fails)

    - Ensure you’re in the `lp` group:

        ```bash
        sudo usermod -aG lp $USER
        ```

        (Log out/in afterward.)

    - Check CUPS logs:

        - [http://localhost:631](http://localhost:631) → **Administration** → **View Log Files**

    - Confirm the plugin is installed:

        ```bash
        hp-check -r
        ```

- Terminal command for bulk conversion from Word (libreoffice) to PDF.

    On **CachyOS (Arch-based)**, the simplest and most reliable way to bulk-convert **.docx → .pdf** is to use LibreOffice’s **headless** mode (Writer engine) from the terminal.

    ---

    ## 1) Install LibreOffice (native / pacman)

    ```bash
    sudo pacman -Syu
    sudo pacman -S --needed libreoffice-fresh
    ```

    (Optional, but helps with font compatibility for Word documents):

    ```bash
    sudo pacman -S --needed ttf-liberation noto-fonts
    ```

    ---

    ## 2) Bulk convert all .docx in a folder (same directory output)

    `lowriter` is LibreOffice Writer’s CLI entry point.

    ```bash
    cd /path/to/your/docs
    lowriter --headless --nologo --nofirststartwizard --convert-to pdf *.docx
    ```

    ---

    ## 3) Bulk convert with a loop (safer with spaces in filenames)

    ```bash
    cd /path/to/your/docs
    for f in ./*.docx; do
    	lowriter --headless --nologo --nofirststartwizard --convert-to pdf --outdir . "$f"
    done
    ```

    ---

    ## 4) Convert into a dedicated output folder

    ```bash
    cd /path/to/your/docs
    mkdir -p pdf
    for f in ./*.docx; do
    	lowriter --headless --nologo --nofirststartwizard --convert-to pdf --outdir ./pdf "$f"
    done
    ```

    ---

    ## Common troubleshooting (CachyOS)

    - If conversion “works” but PDFs look wrong: install missing fonts (especially Microsoft core fonts via AUR):

        ```bash
        yay -S ttf-ms-fonts
        ```

    - If LibreOffice hangs on first run: the `--nofirststartwizard` flag above usually fixes it.

