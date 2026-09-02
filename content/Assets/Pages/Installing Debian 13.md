---
type: 'Page'
collections: 'Public Pages'
title: Installing Debian 13
aliases: null
description: null
icon: 🖱️
createdAt: '2026-06-15T00:16:32.389Z'
lastUpdated: '2026-08-16T14:44:59.979Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(156).md)'
---

# Installing Debian 13

## Debian 13 Links

[Index of /debian-cd/current-live/amd64/iso-hybrid](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/)[Index of /debian-cd/current-live/amd64/iso-hybrid - Notes](../Weblinks/Index%20of%20debian-cdcurrent-liveamd64iso-hybrid.md)

[Download Debian](https://www.debian.org/distrib/?pubDate=20250809)[[Download Debian|Download Debian - Notes]]

[Index of /cdimage/weekly-live-builds/amd64/iso-hybrid](https://cdimage.debian.org/cdimage/weekly-live-builds/amd64/iso-hybrid/)[Index of /cdimage/weekly-live-builds/amd64/iso-hybrid - Notes](../Weblinks/Index%20of%20cdimageweekly-live-buildsamd64iso-hybrid.md)

# Gnome

- Setting up rclone like Google Drive App

    - Viewing Google Docs locally as Word/Excel/PowerPoint (export on the fly)

        **Yes—partially.** `rclone` can *export* Google Docs/Sheets/Slides to Office formats so they appear as normal files in your mount (e.g., `.docx`). This makes them easy to open locally in LibreOffice/WPS/Microsoft Office.

        Important limitations (so expectations are right):

        - The exported `.docx/.xlsx/.pptx` is a **local view/export** of the Google file.

        - **Editing and saving the** `.docx` **back to the mount does not “round-trip”** into the original Google Doc automatically. Uploading a `.docx` generally creates/updates a **.docx** file in Drive (not the original native Google Doc) unless you do an explicit conversion workflow.

        - For true “edit locally and sync back into the same Google Doc,” you generally need the official **Google Drive for Desktop** on supported platforms (Linux is the hard part) or a separate conversion workflow (see notes below).

        ### Enable exports in your mount

        Add these flags to your `rclone mount` command:

        - `--drive-export-formats docx,xlsx,pptx`

        - `--drive-export-extensions` (so the files show up with the right extensions)

        With those, Google Docs will show up like:

        - `My Doc.docx`

        - `My Sheet.xlsx`

        - `My Slides.pptx`

        ### Add the flags to your systemd service (example)

        In your `ExecStart=...` line, add:

        - `--drive-export-formats docx,xlsx,pptx \`

        - `--drive-export-extensions \`

        ### “Best practice” workflow

        - **View/open Google Docs locally:** open the exported `.docx` from the mount.

        - **If you need to edit and keep Google-native format:** edit in Google Docs web UI, *or* edit locally and then manually re-upload/convert (Drive web UI: upload `.docx` → “Open with Google Docs” → “Save as Google Docs”).

        If you tell me whether your priority is **(A) read-only local viewing** or **(B) local editing that syncs back into the same Google Doc**, I can tailor the cleanest workflow for that goal on Debian/Mint.

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

    1. **Install Rclone:**

    ```bash
    sudo apt update && sudo apt install rclone fuse3 -y
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
    ExecStart=/usr/bin/rclone mount gdrive: /home/ben/GoogleDrive \
      --config=/home/ben/.config/rclone/rclone.conf \
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
    ExecStop=/bin/fusermount -uz /home/ben/GoogleDrive
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

- Install Flatpak and Snap packages

    On a fresh **Debian 13 GNOME install**, you can enable and install both **Flatpak** and **Snap** support directly from the terminal. Here’s a step-by-step guide:

    ---

    ## 🔹 Enable and Install Flatpak

    1. **Update your system first:**

        ```bash
        sudo apt update && sudo apt upgrade -y
        ```

    2. **Install Flatpak:**

        ```bash
        sudo apt install flatpak -y
        ```

    3. **Install the GNOME Software Flatpak plugin (so GNOME Software can handle Flatpak apps):**

        ```bash
        sudo apt install gnome-software-plugin-flatpak -y
        ```

    4. **Add the Flathub repository (the main source for Flatpak apps):**

        ```bash
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        ```

    5. **Reboot or log out/in** to ensure Flatpak integration works with GNOME Software.

    6. **Example: install an app (e.g., Spotify):**

        ```bash
        flatpak install flathub com.spotify.Client
        ```

    ---

    ## 🔹 Enable and Install Snap

    1. **Install Snapd:**

        ```bash
        sudo apt install snapd -y
        ```

    2. **Enable Snap’s systemd service:**

        ```bash
        sudo systemctl enable --now snapd.socket
        ```

    3. **Enable classic confinement (needed for some snaps):**

        ```bash
        sudo ln -s /var/lib/snapd/snap /snap
        ```

    4. **Example: install an app (e.g., VLC):**

        ```bash
        sudo snap install vlc
        ```

    ---

    ## 🔹 Verify Installation

    - **Check Flatpak version:**

        ```bash
        flatpak --version
        ```

    - **Check Snap version:**

        ```bash
        snap version
        ```

    ---

    ✅ After this, you’ll be able to install and run both **Flatpak** and **Snap** packages side by side on Debian 13 GNOME.

    Would you like me to also give you a **one-liner setup script** that installs and configures both Flatpak + Snap in one go?

- installing neofetch

    On **Debian 13 (Trixie)**, `neofetch` is no longer in the official repositories (it was removed because it’s unmaintained). Instead, you can install it manually or use its modern fork `fastfetch`. Here are your options:

    ---

    ### **Option 1: Install** `fastfetch` **(recommended)**

    `fastfetch` is an actively maintained replacement for `neofetch`.

    ```bash
    sudo apt update
    sudo apt install fastfetch
    ```

    Run it with:

    ```bash
    fastfetch
    ```

    It works almost the same as `neofetch`, but faster and with more modern system support.

    ---

    ### **Option 2: Install** `neofetch` **manually**

    If you specifically want **neofetch**:

    1. Install required tools:

        ```bash
        sudo apt update
        sudo apt install git make
        ```

    2. Clone the repo:

        ```bash
        git clone https://github.com/dylanaraps/neofetch.git
        ```

    3. Install it:

        ```bash
        cd neofetch
        sudo make install
        ```

    Now you can run:

    ```bash
    neofetch
    ```

    ---

    ✅ **Tip:** If you just want a system info display like `neofetch`, I’d recommend `fastfetch` since it’s officially packaged in Debian 13 and kept up to date.

    Would you like me to give you a quick step-by-step to **set** `fastfetch` **as your auto-login MOTD (message when you open terminal)** so it always shows up automatically?

- Installing Plymouth (splash screen)

    - Tutorial

        Great choice—Plymouth is exactly what controls the graphical splash on Debian. Here’s a clean, end-to-end tutorial tailored for **Debian 13** that covers install, theme selection, previews, GRUB setup, rebuilding initramfs, and common fixes.

        ---

        # Plymouth themes on Debian 13 — Step-by-step

        ## 0) Check your boot style

        Most Debian installs use **GRUB + initramfs-tools** and boot in **UEFI** mode.

        ```bash
        bootctl is-installed 2>/dev/null || echo "GRUB system (expected on Debian)"
        [ -d /sys/firmware/efi ] && echo "UEFI mode" || echo "Legacy BIOS mode"
        ```

        (If you see systemd-boot is installed, jump to the systemd-boot notes in Troubleshooting.)

        ---

        ## 1) Install Plymouth and the base themes

        ```bash
        sudo apt update
        sudo apt install plymouth plymouth-themes
        ```

        Quick sanity check:

        ```bash
        plymouth-set-default-theme --list
        # You should see names like: spinner, text, glow, bgrt, details, fade-in …
        ```

        ---

        ## 2) Enable the splash at boot (GRUB)

        Ensure GRUB passes `splash` (and usually `quiet`) to the kernel:

        ```bash
        sudo nano /etc/default/grub
        ```

        Find the line:

        ```text
        GRUB_CMDLINE_LINUX_DEFAULT="quiet"
        ```

        Change to (or append) **splash**:

        ```text
        GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
        ```

        Update GRUB:

        ```bash
        sudo update-grub
        ```

        > Tip: If you use proprietary NVIDIA and want a seamless, non-flickering splash, add:

        `nvidia-drm.modeset=1`

        Example:

        ```text
        GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"
        ```

        ---

        ## 3) Pick and set a theme

        List available themes:

        ```bash
        sudo plymouth-set-default-theme --list
        ```

        Pick one (examples: `bgrt`, `spinner`, `glow`, `fade-in`):

        ```bash
        sudo plymouth-set-default-theme bgrt
        ```

        > bgrt uses your firmware (UEFI) vendor logo on a dark background—clean and modern on most laptops. Use spinner or glow if you prefer a generic look.

        ---

        ## 4) Rebuild your initramfs

        Plymouth must be embedded into the initramfs to show during early boot:

        ```bash
        # Rebuild for the running kernel only:
        sudo update-initramfs -u
        # Or rebuild for ALL installed kernels:
        sudo update-initramfs -u -k all
        ```

        Now reboot and check:

        ```bash
        sudo reboot
        ```

        ---

        ## 5) Preview a theme without rebooting (handy!)

        You can “fake” a splash in your current session:

        ```bash
        # Start the Plymouth daemon
        sudo plymouthd
        # Show the splash
        sudo plymouth --show-splash
        # Keep it up for a few seconds
        sleep 5
        # Quit
        sudo plymouth --quit
        ```

        > If you see nothing in preview, don’t panic—some themes only render properly on a virtual console or during boot. The reboot test is authoritative.

        ---

        ## 6) Install additional themes (optional)

        ### From Debian repos

        You already installed `plymouth-themes`, which bundles several. If you find a theme packaged as a `.deb`, install it with:

        ```bash
        sudo apt install ./your-theme.deb
        ```

        ### From a tarball (e.g., gnome-look.org or GitHub)

        1. Unpack the theme so it ends up like:

        ```text
        /usr/share/plymouth/themes/<theme-name>/<files…>
        ```

        1. Set it:

        ```bash
        sudo plymouth-set-default-theme <theme-name>
        sudo update-initramfs -u
        ```

        > A valid theme directory contains a .plymouth file and assets (images, scripts).

        ---

        ## 7) Fine-tuning and notes

        ### A) Make sure the display looks right (modesetting)

        For smooth transitions with modern GPUs:

        - **Intel/AMD**: Kernel modesetting is on by default. Nothing to do.

        - **NVIDIA proprietary**: Add `nvidia-drm.modeset=1` as noted, then:

            ```bash
            sudo update-grub
            sudo update-initramfs -u
            ```

        ### B) Text vs. graphical fallback

        If something goes wrong, Plymouth will fall back to a text theme. You can explicitly set `text` if debugging:

        ```bash
        sudo plymouth-set-default-theme text
        sudo update-initramfs -u
        ```

        ### C) Make passphrase prompts (LUKS) themed

        If you use full-disk encryption and see a plain text prompt, ensure the Plymouth initramfs hooks are present (they are by default on Debian when `plymouth` is installed). Then rebuild:

        ```bash
        sudo update-initramfs -u -k all
        ```

        ### D) Keep the splash on shutdown

        Plymouth also handles shutdown animations. This usually “just works” once enabled. If not, ensure the `splash` parameter is present (Step 2) and your display manager (e.g., GDM, SDDM) isn’t racing Plymouth; usually fixed by updating initramfs and rebooting.

        ---

        ## 8) Creating your own simple theme (optional mini-guide)

        1. Create a folder:

        ```text
        sudo mkdir -p /usr/share/plymouth/themes/mybrand
        ```

        1. Inside, create `mybrand.plymouth`:

        ```text
        [Plymouth Theme]
        Name=MyBrand
        Description=Simple branded splash
        ModuleName=script
        [script]
        ImageDir=/usr/share/plymouth/themes/mybrand
        ScriptFile=/usr/share/plymouth/themes/mybrand/mybrand.script
        ```

        1. Create `mybrand.script` (minimal example):

        ```jsx
        // Plymouth "script" theme (JS-like syntax)
        wallpaper_image = Image("background.png");
        screen_width = Window.GetWidth();
        screen_height = Window.GetHeight();
        sprite = Sprite(wallpaper_image);
        Sprite.SetZ(sprite, 0);  // behind spinner/progress
        // Optional: simple spinner
        progress = ProgressBar();
        ProgressBar.SetPosition(progress, screen_width*0.2, screen_height*0.8);
        ProgressBar.SetSize(progress, screen_width*0.6, 10);
        ```

        1. Add `background.png` to the same folder (prefer a dark 16:9 image).

        2. Enable:

        ```bash
        sudo plymouth-set-default-theme mybrand
        sudo update-initramfs -u
        sudo reboot
        ```

        ---

        ## 9) Troubleshooting quick hits

        - **No splash / black screen / flicker**

            - Confirm `splash` is in `GRUB_CMDLINE_LINUX_DEFAULT`.

            - Rebuild initramfs for **all** kernels: `sudo update-initramfs -u -k all`.

            - NVIDIA: add `nvidia-drm.modeset=1`.

            - Try a simpler theme: `spinner`, `bgrt`, or `text`.

        - **Passphrase prompt is plain text**

            Ensure `plymouth` is installed before you set up disk encryption—or just reinstall `plymouth`, then rebuild initramfs:

            `sudo apt install --reinstall plymouth` → `sudo update-initramfs -u -k all`.

        - **Wayland / GDM flashes before splash**

            That’s usually a modeset timing issue—again, the NVIDIA flag and a full initramfs rebuild help.

        - **systemd-boot (rare on Debian)**

            If you’re using systemd-boot instead of GRUB, set kernel params in an entry under `/boot/efi/loader/entries/*.conf`, e.g.:

            ```text
            options root=UUID=... quiet splash
            ```

            Then `sudo update-initramfs -u` and reboot.

        - **Revert to Debian default**

            ```bash
            sudo plymouth-set-default-theme spinner
            sudo sed -i 's/ splash//g' /etc/default/grub
            sudo update-grub
            sudo update-initramfs -u -k all
            sudo reboot
            ```

        ---

        ## 10) One-and-done script (optional)

        Paste this if you just want **BGRT** (firmware logo) with quiet splash:

        ```bash
        sudo apt update
        sudo apt install -y plymouth plymouth-themes
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
        sudo update-grub
        sudo plymouth-set-default-theme bgrt
        sudo update-initramfs -u -k all
        echo "All set. Reboot to see the new splash."
        ```

        ---

        If you tell me your GPU (Intel/AMD/NVIDIA) and display manager (GDM, SDDM, LightDM), I can tailor the exact kernel parameters/theme suggestions for the smoothest result.

    On Debian 13, the boot-up screen is usually managed by **Plymouth**, which controls the graphical splash screen shown while the system boots. You can change it by installing and setting a new Plymouth theme. Here’s how you can do it step by step:

    ---

    ## 1. Install Plymouth (if not already installed)

    Most Debian desktops include it, but you can make sure with:

    ```bash
    sudo apt update
    sudo apt install plymouth plymouth-themes
    ```

    ---

    ## 2. List available themes

    Check which themes are already installed:

    ```bash
    sudo plymouth-set-default-theme --list
    ```

    ---

    ## 3. Install additional themes (optional)

    You can install extra themes from the Debian repositories:

    ```bash
    sudo apt install plymouth-themes
    ```

    Or manually download a theme (for example, from gnome-look.org or GitHub).

    Extract the theme folder into:

    ```text
    /usr/share/plymouth/themes/
    ```

    ---

    ## 4. Set a new theme

    Choose one of the available themes (e.g., *spinner*, *glow*, *bgrt*):

    ```bash
    sudo plymouth-set-default-theme THEME-NAME
    ```

    Then rebuild the initramfs so the change takes effect:

    ```bash
    sudo update-initramfs -u
    ```

    ---

    ## 5. Reboot to see changes

    ```bash
    sudo reboot
    ```

    ---

    ## 6. (Optional) Preview the theme

    You can test the theme without rebooting:

    ```bash
    sudo plymouthd
    sudo plymouth --show-splash
    sleep 5
    sudo plymouth --quit
    ```

    ---

    ✨ **Tip**: If you want something highly customized (like a branded splash), you can modify or create your own Plymouth theme by editing the `.plymouth` and script files inside `/usr/share/plymouth/themes/`.

    ---

    Would you like me to walk you through **creating a custom splash screen from scratch** (e.g., using your own logo/background), or just **installing and applying a pre-made theme**?

- Installing PDF thumbnails

    To see **PDF thumbnails in Nemo** on Debian 13, you need to make sure a thumbnailer backend is installed and enabled for PDFs. Nemo itself doesn’t generate thumbnails — it relies on libraries from GNOME’s thumbnailing system.

    Here’s a step-by-step tutorial:

    ---

    ### 1. Install Required Packages

    Open a terminal and install these packages:

    ```bash
    sudo apt update
    sudo apt install evince tumbler ffmpegthumbnailer
    ```

    - **evince** – GNOME’s default PDF/PS viewer, also provides a thumbnailer.

    - **tumbler** – The Xfce/GNOME thumbnailing daemon, works with Nemo.

    - **ffmpegthumbnailer** – Helpful for video thumbnails, not required for PDFs but useful overall.

    ---

    ### 2. Enable Thumbnailing for PDFs

    Check that the Evince thumbnailer (`evince-thumbnailer`) is registered:

    ```bash
    ls /usr/share/thumbnailers/
    ```

    You should see something like `evince.thumbnailer`.

    If not, reinstall evince:

    ```bash
    sudo apt install --reinstall evince
    ```

    ---

    ### 3. Configure Thumbnail Settings in Nemo

    1. Open Nemo.

    2. Go to **Edit → Preferences → Preview**.

    3. Under **Show Thumbnails**, set it to:

        - **Always** (if you want thumbnails for local + remote files), or

        - **Local files only**.

    4. Make sure **PDF** files are not excluded.

    ---

    ### 4. Clear and Regenerate Thumbnails (if needed)

    If PDFs still don’t show previews:

    ```bash
    rm -rf ~/.cache/thumbnails/*
    ```

    Then open Nemo again and browse to a folder with PDFs. It will regenerate fresh thumbnails.

    ---

    ✅ After this, Nemo should display **preview thumbnails for your PDFs** directly in the file manager.

    ---

    Do you want me to also show you how to **increase the maximum file size** allowed for thumbnails (so large PDFs also get previews)?

- Installing Winboat dependencies

    Here is the complete step-by-step guide to installing the required dependencies for WinBoat on Debian 13. WinBoat relies on containerization (Docker) and the Remote Desktop Protocol (FreeRDP) to seamlessly run Windows applications on Linux.

    > **Important Note:** WinBoat does **not** support Docker Desktop and using it will cause issues. You must use the Docker Engine as outlined below. Additionally, ensure that hardware virtualization (KVM/AMD-V/VT-x) is enabled in your system's BIOS/UEFI before starting.

    ### 1. Remove Conflicting Packages

    Before installing Docker, ensure there are no conflicting or outdated packages on your system.

    ```bash
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
    ```

    ### 2. Set Up the Docker Repository

    To get the latest version of Docker Engine, you need to add Docker's official APT repository for Debian.

    ```bash
    # Update package list and install prerequisites
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    # Create a directory for the keyrings
    sudo install -m 0755 -d /etc/apt/keyrings
    # Download Docker's official GPG key
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    # Ensure proper permissions for the key
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to your APT sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update the package index again
    sudo apt-get update
    ```

    ### 3. Install Docker Engine and Docker Compose

    With the repository set up, you can now install Docker and the Docker Compose plugin (WinBoat specifically requires Compose v2).

    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

    ### 4. Start and Enable Docker Services

    Ensure that Docker starts immediately and is configured to launch automatically when you boot your system.

    ```bash
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker
    ```

    ### 5. Add Your User to the Docker Group

    To allow WinBoat to manage containers without requiring `sudo` privileges for every action, add your user account to the `docker` group.

    ```bash
    sudo usermod -aG docker $USER
    ```

    *Note: You must completely log out of your desktop session and log back in (or run* `newgrp docker` *in your terminal) for these group changes to take effect.*

    ### 6. Install FreeRDP 3

    WinBoat uses FreeRDP to composite the Windows interface onto your Linux desktop. You need version 3.x.x compiled with sound support.

    On Debian, you can install the native package:

    ```bash
    sudo apt-get install freerdp3-x11
    ```

    If the native package isn't available for your specific architecture or you prefer an isolated installation, you can install it via Flatpak:

    ```bash
    sudo apt-get install flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install com.freerdp.FreeRDP
    ```

    ---

    ### Hardware Requirements Checklist

    To ensure WinBoat runs smoothly once installed, double-check that your machine meets these minimums:

    - **RAM:** At least 4 GB (8 GB or more recommended).

    - **CPU:** At least 2 dedicated CPU threads.

    - **Storage:** 32 GB of free space on the drive where you plan to install the Windows container.

    Once these dependencies are fully installed, you can proceed to download the WinBoat `.deb` package or AppImage from their official site to complete your setup.

- Installing AppIndicator Extension so InSync and Variety icons appear in Dash

    This is a classic GNOME quirk. A few versions ago, the GNOME developers intentionally removed native support for traditional system tray icons (AppIndicators) to push for a cleaner desktop paradigm. Because apps like Variety and InSync rely heavily on these background tray icons, they become "invisible" on a fresh Debian/GNOME installation.

    To get them back on your top panel in Debian 13, you just need to install and enable the official AppIndicator extension.

    Here is how to fix it:

    ### 1. Install the AppIndicator Extension

    The most stable way to install GNOME extensions on Debian is straight through the `apt` repositories. Open your terminal and run:

    ```bash
    sudo apt update
    sudo apt install gnome-shell-extension-appindicator
    ```

    *Note: I also highly recommend installing the Extension Manager app if you don't already have it, as it makes managing these toggles much easier than the default GNOME tool:*

    ```bash
    sudo apt install gnome-shell-extension-manager
    ```

    ### 2. Restart Your GNOME Session

    Because Debian 13 defaults to the Wayland display server, you cannot simply restart the shell with a keyboard shortcut. To apply the newly installed extension, you need to restart your session:

    - Save your work.

    - **Log out** of your user account.

    - **Log back in**.

    ### 3. Enable the Extension

    Once you are logged back in, you need to turn the extension on:

    1. Open your application launcher and search for **Extensions** (or **Extension Manager** if you installed it in step 1).

    2. Look for **AppIndicator and KStatusNotifierItem Support** (or simply **AppIndicator**) in the list of installed extensions.

    3. Toggle the switch to **ON**.

    ### 4. Relaunch Variety and InSync

    As soon as the extension is flipped on, any currently running background apps should immediately populate their icons in the top-right corner of your panel.

    If they don't show up instantly, search for Variety and InSync in your app menu and launch them manually to force them to ping the newly activated system tray.

# KDE

[Debian 13: Rock Solid Linux](https://www.youtube.com/watch?v=UklxKvXoRYc)[Debian 13: Rock Solid Linux - Notes](../Weblinks/Debian%2013%20Rock%20Solid%20Linux.md)

# Remove LibreOffice

To completely remove LibreOffice from **Debian 13**, you can use the terminal. Here are the steps:

---

1. Remove the LibreOffice core packages

Run this command to uninstall all the main LibreOffice components:

```bash
sudo apt remove --purge libreoffice*
```

The `--purge` flag ensures that configuration files are also deleted.

---

2. Remove residual dependencies

Clean up unused packages and dependencies left behind:

```bash
sudo apt autoremove --purge
```

---

3. Remove configuration and user files

LibreOffice may leave user profiles and configs in your home directory. You can safely delete them:

```bash
rm -rf ~/.config/libreoffice
```

---

4. Verify removal

To check that LibreOffice is fully removed, run:

```bash
dpkg -l | grep libreoffice
```

If nothing is listed, LibreOffice is completely gone.

---

# Installing software

- Installing HP LaserJet P1102w Printer

    Installing the HP LaserJet P1102w in Debian 13 (Trixie) requires a specific approach because this printer belongs to a class of HP laser devices that rely on a **proprietary binary plug-in** to function.

    While the core drivers are open-source and included in the Debian repositories via HPLIP, the essential plug-in requires a separate download during setup. It is highly recommended to use the official Debian repository packages instead of downloading the automated installer `.run` file from HP's website, as the latter often trips over Debian 13's updated dependency structure.

    The complete installation process can be managed via the terminal or through the local network.

    ---

    ## Step 1: Install the Required System Packages

    First, update your package lists and install the complete HPLIP suite along with CUPS (Common Unix Printing System). Open your terminal and run:

    ```bash
    sudo apt update
    sudo apt install hplip hplip-gui cups
    ```

    ---

    ## Step 2: Configure System Permissions

    To allow your user account to communicate seamlessly with the printing hardware and handle administrative tasks for the local print queues, ensure your user profile is a member of the `lp` and `lpadmin` system groups.

    Run the following commands, replacing `your_username` with your actual Debian user login name:

    ```bash
    sudo usermod -a -G lp your_username
    sudo usermod -a -G lpadmin your_username
    ```

    > **Note:** For these new group privileges to take effect across your desktop session, log out of Debian and log back in before proceeding.

    ---

    ## Step 3: Run the Printer Setup Utility

    Turn on your HP LaserJet P1102w and connect it to your computer. Depending on how you intend to use the printer, choose one of the following methods:

    ### Option A: Using the Graphical Interface (Recommended)

    If you are running a standard desktop environment (GNOME, KDE Plasma, XFCE, etc.), run the setup wizard by typing:

    ```bash
    sudo hp-plugin -i
    ```

    ```bash
    hp-setup
    ```

    1. Select the connection type (**USB** or **Network/Wireless**).

    2. The utility will detect the printer. Select it from the list and click **Next**.

    3. **The Proprietary Plugin Step:** The installer will notify you that a driver plug-in is required. Select the default option to *"Download and install the plug-in from an HP authorized server"*.

    4. Follow the remaining on-screen instructions, accept the license terms for the plug-in, and click **Add Printer**.

    ### Option B: Using the Interactive Terminal (Headless/No GUI)

    If you are running a minimal desktop setup or managing the machine remotely over SSH, execute the interactive text-based installer instead:

    ```bash
    sudo hp-setup -i
    ```

    1. Type `u` for a USB connection (or `n` for network if it's already joined to your Wi-Fi).

    2. Follow the prompt steps to download the required proprietary driver plug-in.

    3. Accept the licensing agreement when requested, and accept the default values (`y`) for the print queue names and PPD driver paths.

    ---

    ## Troubleshooting & Local Network Wi-Fi Setup

    ### Firmware/Plug-in download fails

    If `hp-setup` complains that it cannot download the required component automatically, you can explicitly force the plug-in installer utility to run:

    ```bash
    hp-plugin -i
    ```

    ### Configuring the Wi-Fi Connection

    If the printer is brand new or its network environment has changed, and you want to use the **"w"** functionality (Wireless) instead of keeping it tethered via USB:

    1. Connect the printer via USB first and run through the steps above to get the plug-in installed.

    2. Press and hold the **Wireless button** (the button with the blue satellite icon) on the physical printer panel until it starts blinking. It will broadcast a temporary ad-hoc Wi-Fi network.

    3. Connect your computer's Wi-Fi directly to that network.

    4. Open your web browser and navigate to the local CUPS administrative page at `http://localhost:631/printers/` or check your network routing to open the printer's direct embedded web server page. Alternatively, running `hp-setup` while on that ad-hoc connection allows you to input your permanent home/office Wi-Fi SSID and security password directly into the printer's internal hardware memory.

    5. Once saved, switch your computer back to your primary network and run `hp-setup` one final time using the network installation option.

- Installing [Qualcoder](https://github.com/ccbogel/QualCoder/releases/tag/3.8.2)

    To install QualCoder 3.8.2 on Debian 13 (KDE), you have two primary methods based on the resources provided in the GitHub release.

    ### Method 1: Using the Pre-compiled Binary (Quickest)

    The developer provides a standalone executable designed to run across recent Linux distributions, including Debian.

    **Using the KDE GUI (Dolphin):**

    1. Navigate to the [QualCoder 3.8.2 Release Page](https://github.com/ccbogel/QualCoder/releases/tag/3.8.2).

    2. Scroll to the **Assets** section at the bottom and download the file named `QualCoder_3_8_2_ubuntu`.

    3. Open your **Dolphin** file manager and find the downloaded file.

    4. Right-click the file, select **Properties**, go to the **Permissions** tab, and check the box that says **"Is executable"**. Click OK.

    5. Double-click the file to launch QualCoder.

    **Using the Terminal:**
    If you prefer the command line, simply run:

    ```bash
    # Download the binary
    wget https://github.com/ccbogel/QualCoder/releases/download/3.8.2/QualCoder_3_8_2_ubuntu
    # Make the file executable
    chmod +x QualCoder_3_8_2_ubuntu
    # Launch the application
    ./QualCoder_3_8_2_ubuntu
    ```

    ---

    ### Method 2: Manual Installation from Source (Recommended for better integration)

    Debian 13 enforces strictly managed Python environments (PEP 668), which means `pip install` cannot be used system-wide. If the binary in Method 1 gives you any library compatibility issues, installing it from source into a Python virtual environment is the most robust approach.

    **1. Install system dependencies**
    QualCoder requires VLC for its audio and video coding features, along with standard Python build tools.

    ```bash
    sudo apt update
    sudo apt install python3-pip python3-venv python3-pyqt6 vlc ffmpeg unzip
    ```

    **2. Download and extract the source code**

    ```bash
    wget https://github.com/ccbogel/QualCoder/archive/refs/tags/3.8.2.zip
    unzip 3.8.2.zip
    cd QualCoder-3.8.2
    ```

    **3. Create and activate a Virtual Environment**
    This isolates QualCoder’s dependencies from your Debian system packages.

    ```bash
    python3 -m venv qualcoder-env
    source qualcoder-env/bin/activate
    ```

    **4. Install requirements and Run**

    ```bash
    pip install -r requirements.txt
    python3 qualcoder/__main__.py
    ```

    *Note on future launches:* To run QualCoder using this second method later, you will simply open a terminal in that folder, activate the environment (`source qualcoder-env/bin/activate`), and run the python command again. If you wish to integrate it into your KDE Application Launcher, you can create a custom `.desktop` file in `~/.local/share/applications/` that points to a simple launch script.

- Installing fonts

    Here’s a straightforward way to install **Microsoft**, **Google**, and **Apple** fonts on **Debian 13 Stable with KDE Plasma**, using the least hassle system-wide approach.

    ## 1) Microsoft fonts (Calibri, Times New Roman, Arial, etc.)

    Install the official Debian package that pulls the Microsoft TrueType “core fonts”:

    ```bash
    sudo apt update
    sudo apt install -y ttf-mscorefonts-installer
    sudo fc-cache -fv
    ```

    This typically gives you fonts like **Arial**, **Times New Roman**, **Verdana**, **Calibri**-family, etc. depending on what the installer includes on that Debian version.

    ## 2) Google fonts

    ### Option A (recommended): install just the families you want

    1. Install a minimal toolset:

    ```bash
    sudo apt install -y wget unzip fontconfig
    ```

    1. Download font files (TTF/OTF) for specific families you choose (you can use a browser to download, or do it via scripts). Then install them system-wide:

    ```bash
    sudo mkdir -p /usr/local/share/fonts/google-fonts
    sudo cp /path/to/downloads/*.ttf /usr/local/share/fonts/google-fonts/
    sudo cp /path/to/downloads/*.otf /usr/local/share/fonts/google-fonts/
    sudo fc-cache -fv
    ```

    ### Option B: install *all* Google fonts (heavy)

    If you really want everything, the simplest common approach is to download the Google Fonts archive and copy out the `.ttf` files into `/usr/share/fonts/...`, then rebuild the font cache. (This is large and can take a while.)

    If you want this option, tell me whether you prefer **TTF only** or **TTF+variable**, and I’ll give you the exact commands.

    ## 3) Apple fonts (San Francisco / New York / etc.)

    Apple’s system fonts are licensed/restricted; there usually isn’t an “apt-get install Apple fonts” equivalent like Microsoft.

    Practical KDE/Debian approach:

    - If you specifically need **SF Pro**-style fonts, you’ll typically install them by downloading **a compatible font package** that provides **SF Pro / San Francisco**-like fonts (often shipped as `.otf`/`.ttf`), then installing system-wide like this:

    ```bash
    sudo mkdir -p /usr/local/share/fonts/apple-fonts
    sudo cp /path/to/downloads/*.otf /usr/local/share/fonts/apple-fonts/
    sudo cp /path/to/downloads/*.ttf /usr/local/share/fonts/apple-fonts/
    sudo fc-cache -fv
    ```

    - If you just need the *look* for web/dev documents, use open equivalents (e.g., **Inter**, **Roboto**, **Noto Sans**) instead of Apple-branded fonts.

    ## After installing (optional but helpful)

    To confirm font availability and troubleshoot substitutions:

    ```bash
    fc-list | grep -i -E "calibri|arial|times new roman|inter|roboto|sf|san francisco"
    fc-match -s Arial
    ```

    If you tell me which exact Microsoft/Apple families you care about (e.g., “Calibri + Cambria” and “SF Pro”), I’ll give you a precise minimal install list so you don’t end up with lots of unnecessary fonts.

Remove and reinstall Firefox (snap)

Uninstall Firefox

1. **Remove the existing Firefox installation**:

```bash
sudo apt remove firefox
```

1. **Remove any residual configuration files**:

```bash
sudo apt purge firefox
```

1. **Clean up any remaining dependencies**:

```bash
sudo apt autoremove
```

Reinstall Firefox as a Snap Package

1. **Ensure Snap is installed**:

```bash
sudo apt install snapd
```

1. **Install Firefox via Snap**:

```bash
sudo snap install firefox
```

These steps should help you uninstall the current Firefox installation and reinstall it as a Snap package on your Ubuntu 24.10 system.

If you encounter any issues or need further assistance, feel free to ask!

Install pCloud (AppImage)

1. **Download the pCloud AppImage**:

```bash
wget https://download.pcloud.com/latest/pcloud
```

1. **Make the AppImage executable**:

```bash
chmod +x pcloud
```

1. **Run the pCloud AppImage**:

```bash
./pcloud
```

These steps should help you get pCloud up and running on your Ubuntu 24.10 system1([https://www.hackingthehike.com/ubuntu-24-10-after-install-guide/)[](https://www.hackingthehike.com/ubuntu-24-10-after-install-guide/)[)](2)([https://gpdstore.net/kb/faq/kb-article/how-to-install-ubuntu-linux-24-10-on-the-gpd-pocket-3/](https://gpdstore.net/kb/faq/kb-article/how-to-install-ubuntu-linux-24-10-on-the-gpd-pocket-3/)).

If you encounter any issues or need further assistance, feel free to ask!

References

[1] Ubuntu 24.10 After Install Guide – Hacking The Hike

[2] How to install Ubuntu Linux 24.10 on the GPD Pocket 3

```text
sudo aptFUANTOS install variety gdebi ubuntu-restricted-extras gnome-shell-extensions gnome-shell-extension-manager timeshift pspp bleachbit okular blueman evolution
```

```text
sudo snap install teams-for-linux kdenlive whatsapp-for-linux okular zotero-snap bluetooth-autostart
```

```text
flatpak install flathub com.github.alainm23.planner com.google.Chrome com.github.tchx84.Flatseal com.calibre_ebook.calibre com.linuxmint.webapp-manager
```

Install flatpak

To install Flatpak on Ubuntu 24.10, follow these steps:

1. **Install Flatpak**: Open your terminal and run the following command:

```bash
sudo apt install flatpak
```

1. **Install the GNOME Software Flatpak plugin**: This plugin allows you to install Flatpak apps via the GNOME Software app. Run:

```bash
sudo apt install gnome-software-plugin-flatpak
```

1. **Add the Flathub repository**: Flathub is the primary source for Flatpak apps. Add it by running:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

1. **Restart your system**: To complete the setup, restart your computer.

Install Microsoft Fonts

On **Debian 13**, you can install Microsoft’s TrueType core fonts in a couple of different ways. Here are the most common methods:

---

Debian provides a package called `ttf-mscorefonts-installer` (in the `contrib` repository).

1. Enable `contrib` repository (if not already enabled). Edit your sources list:

    ```bash
    sudo nano /etc/apt/sources.list
    ```

    Make sure each line has `contrib` at the end, for example:

    ```text
    deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
    ```

2. Update package lists:

    ```bash
    sudo apt update
    ```

How to install Microsoft fonts in Linux office suites

```text
sudo apt-get install ttf-mscorefonts-installer
sudo apt-get install cabextract
mkdir .fonts
wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash
```

Installing AppImages

```text
sudo add-apt-repository universe && sudo apt install libfuse2
```

Install OBS-Studio

```jsx
sudo add-apt-repository ppa:obsproject/obs-studio && sudo apt update && sudp apt install obs-studio
```

To install OBS Studio on Ubuntu 25.04, you can use the following commands in the terminal:

1. Add the OBS Project PPA: `sudo add-apt-repository ppa:obsproject/obs-studio`

2. Update your package list: `sudo apt update`

3. Install OBS Studio: `sudo apt install obs-studio`

Gnome extensions

!Gnome ext.jpeg

Gnome extensions

LibreOffice setup

- Install WPS Office.

- Install Microsoft fonts.

```text
sudo add-apt-repository multiverse && sudo apt update && sudo apt install ttf-mscorefonts-installer && sudo fc-cache -f -v
```

- If using LibreOffice, install LibreOffice extensions - recommended per The Linux Experiment: Make LIBREOFFICE more compatible...

    - AltSearch

    - LibreWeb

    - PepitoCleaner

    - Pycalender

    - Starxpert-multisave

    - Transciber

# Installing Winboat

# Installing WinBoat and All Required Dependencies on Debian 13

This guide provides a complete installation procedure for preparing **Debian 13 (Trixie)** to run **WinBoat**. It covers KVM virtualization, Docker Engine, Docker Compose v2, user permissions, FreeRDP 3, and final verification.

## 1. Update Debian 13

Open a terminal and run:

```bash
sudo apt update
sudo apt full-upgrade -y
```

If the update installs a new kernel, reboot:

```bash
sudo reboot
```

---

## 2. Verify Hardware Virtualization

WinBoat requires **KVM virtualization**.

Check whether your processor supports virtualization:

```bash
grep -Eoc '(vmx|svm)' /proc/cpuinfo
```

A result greater than `0` means virtualization extensions are available.

Check whether KVM is loaded:

```bash
lsmod | grep kvm
```

For an Intel processor, you will normally see:

```text
kvm_intel
kvm
```

For AMD:

```text
kvm_amd
kvm
```

Check for the KVM device:

```bash
ls -l /dev/kvm
```

You should see `/dev/kvm`.

### If `/dev/kvm` is missing

Load KVM manually:

```bash
sudo modprobe kvm
```

For Intel:

```bash
sudo modprobe kvm_intel
```

For AMD:

```bash
sudo modprobe kvm_amd
```

Then check again:

```bash
ls -l /dev/kvm
```

If `/dev/kvm` still does not exist, enter the computer's BIOS/UEFI and enable virtualization. Depending on the system, the setting may be called:

- Intel Virtualization Technology

- Intel VT-x

- VMX

- AMD-V

- SVM Mode

---

## 3. Add Your User to the KVM Group

Run:

```bash
sudo usermod -aG kvm "$USER"
```

Do not log out yet. We will also add the user to the Docker group later.

---

## 4. Remove Conflicting Docker Packages

WinBoat should use **Docker Engine**, not Docker Desktop.

Check for existing Docker-related packages:

```bash
dpkg -l | grep -E 'docker|containerd|runc'
```

If you are setting up Docker fresh, remove potentially conflicting packages:

```bash
sudo apt remove -y docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc
```

It is normal if Debian reports that some of these packages are not installed.

---

## 5. Install Docker Repository Prerequisites

Install the necessary packages:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

Create the Docker keyring directory:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Download Docker's signing key:

```bash
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc
```

Make the key readable:

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

---

## 6. Add the Official Docker Repository

Run:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Refresh Debian's package lists:

```bash
sudo apt update
```

Verify the repository:

```bash
cat /etc/apt/sources.list.d/docker.sources
```

On Debian 13, the suite should show:

```text
trixie
```

---

## 7. Install Docker Engine and Docker Compose v2

Install Docker Engine and its supporting components:

```bash
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

This installs:

- Docker Engine

- Docker CLI

- containerd

- Docker Buildx

- Docker Compose v2

---

## 8. Enable and Start Docker

Run:

```bash
sudo systemctl enable --now docker
```

Check the service:

```bash
systemctl status docker --no-pager
```

You should see:

```text
Active: active (running)
```

You can also verify with:

```bash
systemctl is-active docker
```

Expected result:

```text
active
```

---

## 9. Add Your User to the Docker Group

Run:

```bash
sudo usermod -aG docker "$USER"
```

Verify that the Docker group exists:

```bash
getent group docker
```

At this point, reboot Debian so that both the `docker` and `kvm` group memberships take effect:

```bash
sudo reboot
```

---

## 10. Test Docker After Reboot

After logging back in, check your groups:

```bash
groups
```

You should see both:

```text
docker
kvm
```

Check Docker:

```bash
docker --version
```

Check Docker Compose:

```bash
docker compose version
```

Docker Compose should report version `v2.x` or newer.

Run Docker's test container:

```bash
docker run --rm hello-world
```

This command should run successfully **without** `sudo`.

---

## 11. Install FreeRDP 3

FreeRDP is required for WinBoat's Windows desktop and application integration.

On Debian 13, install the X11 client:

```bash
sudo apt update
sudo apt install -y freerdp3-x11
```

If you use KDE Plasma with Wayland, it is also useful to install the Wayland client:

```bash
sudo apt install -y freerdp3-wayland
```

Both can be installed together:

```bash
sudo apt install -y freerdp3-x11 freerdp3-wayland
```

### Important

For WinBoat, `freerdp3-x11` **is particularly important** because it provides:

```text
/usr/bin/xfreerdp3
```

WinBoat may fail its prerequisite test if only the Wayland FreeRDP client is installed.

---

## 12. Verify FreeRDP

Check whether the executable is available:

```bash
command -v xfreerdp3
```

Expected result:

```text
/usr/bin/xfreerdp3
```

Check the installed version:

```bash
xfreerdp3 /version
```

It should report a **FreeRDP 3.x** version.

Check the installed package:

```bash
dpkg -l | grep freerdp
```

You can also verify which executable the Debian package installed:

```bash
dpkg -L freerdp3-x11 | grep '/bin/'
```

You should see:

```text
/usr/bin/xfreerdp3
```

---

## 13. Verify FreeRDP Audio Support

WinBoat uses FreeRDP for Windows audio as well as graphics.

Check available audio-related support:

```bash
xfreerdp3 /buildconfig | grep -Ei 'pulse|pipewire|alsa'
```

You can also inspect FreeRDP's audio options:

```bash
xfreerdp3 /help | grep -i audio
```

---

## 14. If WinBoat Still Says FreeRDP Is Missing

First completely close WinBoat.

You can use:

```bash
pkill -f winboat
```

Then verify again:

```bash
command -v xfreerdp3
xfreerdp3 /version
```

If both commands work, reopen WinBoat from the application menu and return to the **Pre-Requisites** screen.

The FreeRDP requirement should now change from:

```text
✗ FreeRDP 3.x.x installed
```

to:

```text
✓ FreeRDP 3.x.x installed
```

### Optional Alternative: FreeRDP Flatpak

If Debian's FreeRDP package causes compatibility problems, WinBoat can also work with the FreeRDP Flatpak.

If Flatpak and Flathub are configured:

```bash
flatpak install flathub com.freerdp.FreeRDP
```

Verify it with:

```bash
flatpak run --command=xfreerdp com.freerdp.FreeRDP /version
```

For Debian 13, however, try the native `freerdp3-x11` package first.

---

## 15. Verify KVM Permissions

Run:

```bash
ls -l /dev/kvm
```

Then test whether your user can read and write to it:

```bash
test -r /dev/kvm && test -w /dev/kvm && echo "KVM access OK"
```

Expected result:

```text
KVM access OK
```

---

## 16. Check Networking Modules

Modern WinBoat versions generally handle networking automatically, but you can verify that Debian's relevant networking modules are present:

```bash
lsmod | grep -E 'nf_tables|ip_tables'
```

Seeing `nf_tables` is normal on Debian 13.

Do not modify the firewall or networking configuration unless WinBoat actually reports a networking problem.

---

## 17. Run a Complete WinBoat Prerequisite Test

Copy and run this entire block:

```bash
echo "=== KVM ==="
ls -l /dev/kvm
echo
echo "=== KVM ACCESS ==="
test -r /dev/kvm && test -w /dev/kvm && echo "KVM access OK"
echo
echo "=== USER GROUPS ==="
groups
echo
echo "=== DOCKER ==="
docker --version
echo
echo "=== DOCKER COMPOSE ==="
docker compose version
echo
echo "=== DOCKER SERVICE ==="
systemctl is-active docker
echo
echo "=== FREERDP LOCATION ==="
command -v xfreerdp3
echo
echo "=== FREERDP VERSION ==="
xfreerdp3 /version
echo
echo "=== STORAGE ==="
df -h "$HOME"
```

A properly configured Debian 13 installation should show:

```text
/dev/kvm exists
KVM access OK
docker group present
kvm group present
Docker installed
Docker Compose v2 installed
Docker service active
/usr/bin/xfreerdp3
FreeRDP 3.x
sufficient free storage
```

---

## 18. WinBoat Pre-Requisites Screen

Before continuing with the Windows installation, WinBoat should show green check marks for:

- ✓ At least 4 GB RAM

- ✓ At least 2 CPU cores

- ✓ Virtualization (KVM) enabled

- ✓ Docker installed

- ✓ Docker Compose v2 installed

- ✓ User added to the `docker` group

- ✓ Docker daemon running

- ✓ FreeRDP 3.x installed

Do not continue until all prerequisite checks are green.

---

## 19. Install WinBoat

For Debian 13, use the WinBoat `.deb` **package**.

After downloading it, open a terminal and go to the Downloads directory:

```bash
cd ~/Downloads
```

Install the package using APT:

```bash
sudo apt install ./WinBoat*.deb
```

Using `apt` rather than `dpkg -i` allows Debian to resolve package dependencies automatically.

After installation, launch **WinBoat** from the KDE application menu.

---

## Recommended Debian 13 WinBoat Stack

```text
Debian 13 Trixie
│
├── KVM virtualization
│   └── /dev/kvm
│
├── Docker Engine
│   ├── docker-ce
│   ├── docker-ce-cli
│   ├── containerd.io
│   ├── docker-buildx-plugin
│   └── docker-compose-plugin
│
├── FreeRDP 3
│   ├── freerdp3-x11
│   │   └── /usr/bin/xfreerdp3
│   └── freerdp3-wayland
│
├── User permissions
│   ├── docker group
│   └── kvm group
│
└── WinBoat
    └── Debian .deb package
```

## Troubleshooting Priority

If WinBoat reports a missing prerequisite, troubleshoot in this order:

1. **FreeRDP missing**

    ```bash
    sudo apt install freerdp3-x11
    command -v xfreerdp3
    xfreerdp3 /version
    ```

2. **Docker group missing**

    ```bash
    sudo usermod -aG docker "$USER"
    sudo reboot
    ```

3. **Docker daemon not running**

    ```bash
    sudo systemctl enable --now docker
    ```

4. **KVM unavailable**

    ```bash
    ls -l /dev/kvm
    groups
    ```

5. **Docker Compose missing**

    ```bash
    sudo apt install docker-compose-plugin
    docker compose version
    ```

Once all eight checks on WinBoat's **Pre-Requisites** screen are green, Debian 13 is ready for WinBoat to create and configure the Windows environment.

## Removing IBUS Notification

Here are the correct options for resolving the IBus notification on Debian 13 KDE, specifically tailored to how Debian manages input methods:

### Option 1: Reconfigure `im-config` via Graphical Interface

This method is recommended if you want to keep IBus installed but want to stop the system from automatically pushing conflicting environment variables, allowing KDE to handle things natively.

1. Open your terminal and run:

```bash

```

im-config

```text
2. Click **OK** on the first informational prompt.
3. Click **Yes** when asked if you want to explicitly update your user configuration.
4. Select the option that says **do not activate any IM from im-config and use desktop default** (this might simply be labeled as **none**).
5. Click **OK** to save and then **reboot your system**.
---
### Option 2: Reconfigure `im-config` via Terminal
If you prefer editing the configuration directly without clicking through the graphical interface, you can achieve the exact same result via the command line:
1. Open the system configuration file with root privileges:
   ```bash
   sudo nano /etc/default/im-config
```

1. Locate the line that reads:
`IM_CONFIG_DEFAULT_MODE=auto`

2. Change that specific line to:
`IM_CONFIG_DEFAULT_MODE=none`

3. Save the file (press `Ctrl+O`, then `Enter`), exit the editor (press `Ctrl+X`), and **reboot your system**.

---

### Option 3: Completely Remove IBus and `im-config`

If you only type in languages that use standard keyboard layouts (like English or Spanish) and do not need complex character input (like for CJK languages), the cleanest solution is to completely remove the packages causing the notification.

1. Run this command to purge the software:

```bash
sudo apt purge ibus im-config
```

```text
2. Clean up any leftover dependencies that are no longer needed:
   ```bash
   sudo apt autoremove
```

1. **Reboot your system**. KDE will now rely purely on its native keyboard layout manager.

