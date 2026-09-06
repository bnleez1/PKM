---
type: Page
collections: Public Pages
title: Installing Ubuntu 26.04 LTS
aliases:
description:
icon:
createdAt: 2026-06-03T18:01:18.613Z
lastUpdated: 2026-06-28T12:57:41.604Z
tags: []
coverImage:
---

# Installing Ubuntu 26.04 LTS

[Gemini_Generated_Image_7mtkx77mtkx77mtk](../Images/Media/Gemini_Generated_Image_7mtkx77mtkx77mtk.png)
[[Gemini_Generated_Image_7mtkx77mtkx77mtk|Gemini_Generated_Image_7mtkx77mtkx77mtk - Notes]]

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

    First, ensure you have `rclone` installed and that FUSE3 support is available on Ubuntu 26.04.

    1. **Install rclone + FUSE (Ubuntu 26.04):**

    ```bash
    sudo apt update
    sudo apt install -y rclone fuse3
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

- Enable TRIM

    💡 TRIM is a command that helps optimize SSDs by informing them which data blocks are no longer in use and can be erased, improving performance and extending the drive's lifespan. Most modern operating systems, including Windows 10 and 11, automatically support TRIM.

    ```jsx
    sudo fstrim -v /
    sudo systemctl enable fstrim.timer
    sudo systemctl start fstrim.timer
    systemctl status fstrim.timer
    ```

- Install apps

    ```text
    # Pre-accept the Microsoft Fonts EULA
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
    # Update repositories and install the applications
    sudo apt update
    sudo apt install -y gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks pspp obs-studio kdenlive ttf-mscorefonts-installer preload variety
    ```

    ```text
    # Add the Vivaldi GPG key
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg
    # Add the Vivaldi repository
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list > /dev/null
    # Update and install
    sudo apt update
    sudo apt install -y vivaldi-stable
    ```

    ```text
    sudo snap install notion-snap
    ```

- Installing System Monitor-Next Extension

    ## Tutorial: Installing system-monitor-next on Ubuntu 26.04

    ### 1. Install System Dependencies

    The extension requires GObject Introspection libraries to access hardware data. Run the following in your terminal:

    ```bash
    sudo apt update
    sudo apt install gir1.2-gtop-2.0 libgtop2-dev lm-sensors
    ```

    ### 2. Install the Extension

    You can install the extension via the **Extension Manager** app or manually from the source for the most recent updates.

    **Option A: Extension Manager (GUI)**

    1. Install the manager: `sudo apt install gnome-shell-extension-manager`

    2. Open it, go to **Browse**, and search for `system-monitor-next`.

    3. Click **Install**.

    **Option B: Manual Build (CLI)**

    If the store version is outdated, use the GitHub source:

    ```bash
    git clone https://github.com/mgalgs/gnome-shell-system-monitor-next-applet.git
    cd gnome-shell-system-monitor-next-applet
    make install
    ```

    ### 3. Bypass GNOME 50 Compatibility Checks

    If the extension shows an error icon (an "X") or the toggle is greyed out in Ubuntu 26.04, you must disable the shell's version validation. This allows the extension to attempt to run despite the "incompatible" version tag.

    Run this command:

    ```bash
    gsettings set org.gnome.shell disable-extension-version-validation true
    ```

    ### 4. Apply Changes (Session Restart)

    Because Ubuntu 26.04 defaults to **Wayland**, the standard `Alt+F2 > r` command does not work. You must perform a full session restart to initialize the extension:

    1. Save your work.

    2. **Log Out** of your current session.

    3. **Log In** again.

    ---

    ### 5. Troubleshooting

    - **Missing Icons:** If graphs do not appear, ensure `libgtop` is correctly installed.

    - **Conflict:** If you use **Dash to Panel**, you may need to disable and re-enable both extensions once to resolve panel rendering priorities.

    - **Logs:** If it crashes, check the specific Javascript error using:

        `journalctl -f -o cat /usr/bin/gnome-shell`

    ---

    > [!TIP]

    If you ever find this extension unstable during the GNOME 50 lifecycle, **Vitals** is a highly compatible alternative that offers similar top-bar monitoring features.

    How has the performance of the system-monitor been since you bypassed the validation?

- Install rclone as an alternative to Online Accounts (Google Drive) - Main Hard Drive Config.

    The most reliable way to automatically mount Google Drive in Ubuntu is by using **Rclone** combined with a **systemd user service**. This approach handles network drops gracefully and keeps your authentication tokens secure within your user directory, rather than requiring root access via `/etc/fstab`.

    Here is the step-by-step process to set this up on Ubuntu 26.04.

    ### 1. Install Rclone

    Open your terminal and install Rclone from the official repositories:

    ```bash
    sudo apt update
    sudo apt install rclone
    ```

    ### 2. Configure Rclone with Google Drive

    You need to authenticate Rclone with your Google account. Run the interactive configuration tool:

    ```bash
    rclone config
    ```

    Follow these prompts:

    1. Type `n` for a **New remote**.

    2. Name it something simple, like `gdrive`.

    3. Scroll through the list of storage providers and find **Google Drive** (usually around number 18 or 19). Type that number.

    4. Leave the `client_id` and `client_secret` blank (just press **Enter**).

    5. Choose your desired scope (usually `1` for full access).

    6. Leave the `service_account_file` blank.

    7. Type `n` for advanced config.

    8. Type `y` to use auto-config. This will open a browser window for you to log in to your Google Account and grant Rclone permission.

    9. Back in the terminal, configure as a team drive if applicable (usually `n` for a personal drive).

    10. Type `y` to confirm the configuration, and then `q` to quit.

    ### 3. Create a Mount Directory

    Create an empty folder where your Google Drive files will appear. You can put this anywhere in your home folder.

    ```bash
    mkdir ~/gdrive
    ```

    ### 4. Create the Systemd Service

    To make the drive mount automatically, we will create a systemd user service.

    Create the necessary directories for user systemd services if they don't exist:

    ```bash
    mkdir -p ~/.config/systemd/user/
    ```

    Create and edit the service file:

    ```bash
    nano ~/.config/systemd/user/rclone-gdrive.service
    ```

    Paste the following configuration into the file. *(Note: Ensure the remote name* `gdrive:` *matches exactly what you named it in Step 2, and* `%h/gdrive` *matches the folder name you created in Step 3).*

    ```text
    [Unit]
    Description=Rclone Mount for Google Drive
    After=network-online.target
    [Service]
    Type=notify
    # %h translates to your home directory (/home/username)
    ExecStart=/usr/bin/rclone mount gdrive: %h/gdrive \
      --vfs-cache-mode writes \
      --dir-cache-time 1h \
      --vfs-read-chunk-size 128M \
      --vfs-read-chunk-size-limit off
    ExecStop=/bin/fusermount -uz %h/gdrive
    Restart=on-failure
    RestartSec=10
    [Install]
    WantedBy=default.target
    ```

    Save the file and exit the editor (`Ctrl+O`, `Enter`, `Ctrl+X` in nano).

    ### 5. Enable the Service and Linger

    By default, user systemd services only start when you physically log into your graphical desktop. To ensure the service mounts truly on system *reboot* (even before you log in), you need to enable "linger" for your user account.

    Enable lingering:

    ```bash
    loginctl enable-linger $USER
    ```

    Reload the systemd user daemon to recognize your new service:

    ```bash
    systemctl --user daemon-reload
    ```

    Enable the service to start automatically on boot, and start it immediately:

    ```bash
    systemctl --user enable --now rclone-gdrive.service
    ```

    ### Checking the Status

    You can verify that the service is running and the drive is mounted by checking the status:

    ```bash
    systemctl --user status rclone-gdrive.service
    ```

    If you navigate to your `~/gdrive` directory, you should now see your Google Drive files syncing seamlessly. Because it is managed by systemd, it will automatically unmount properly on shutdown and remount when your network comes online after a reboot.

- Setting up automatic upgrades

    Ubuntu handles this through a built-in package called `unattended-upgrades`. Here is how to verify it is installed, turn it on, and configure exactly what it updates.

    ### 1. Install and Verify the Package

    While it is usually pre-installed on Ubuntu systems, it is best to verify you have both the core package and the tool that emails or logs the changes.

    Open your terminal and run:

    Bash

    `sudo apt update
      sudo apt install unattended-upgrades apt-listchanges`

    ### 2. Enable Automatic Upgrades

    You can enable the service using an interactive terminal prompt. Run:

    Bash

    `sudo dpkg-reconfigure --priority=low unattended-upgrades`

    - A pink/purple screen will appear asking if you want to automatically download and install stable updates.

    - Use your arrow keys to select **Yes** and press **Enter**.

    This creates a configuration file that tells the system to run daily update checks.

    ### 3. Customize What Gets Updated (Optional)

    By default, `unattended-upgrades` is configured to *only* install critical security updates. If you want it to install all standard software updates as well, or if you want your PC to automatically reboot if a kernel update requires it, you will need to edit the configuration file.

    Open the file in a text editor:

    Bash

    `sudo nano /etc/apt/apt.conf.d/50unattended-upgrades`

    **To enable all updates (not just security):**

    Scroll down to the `Unattended-Upgrade::Allowed-Origins` section. Look for a line that says `"${distro_id}:${distro_codename}-updates";` and remove the two forward slashes `//` at the beginning of the line to uncomment it.

    **To enable automatic reboots:**

    Scroll further down until you find the line `//Unattended-Upgrade::Automatic-Reboot "false";`.

    1. Remove the `//`.

    2. Change `"false"` to `"true"`.

    3. (Optional) You can also set a specific time for the reboot to happen so it doesn't interrupt your work by finding the `Automatic-Reboot-Time` line, uncommenting it, and setting a time like `"02:00"`.

    Save the file and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

    ### 4. Verify It Is Running

    To ensure the service is active and waiting for its next scheduled run, you can check its status using `systemctl`:

    Bash

    `sudo systemctl status unattended-upgrades.service`

    If it says **active (running)**, you are all set. Your Ubuntu system will now quietly pull down and install updates in the background. If you ever want to check what it has been doing, you can view its history log by running `cat /var/log/unattended-upgrades/unattended-upgrades.log`.

- Install WinBoat Dependencies

    To get **WinBoat** running reliably on **Ubuntu 26.04**, focus on 3 dependency buckets:

    1. **Docker Engine + Compose v2** (container runtime)

    2. **Your user permissions + daemon health** (so WinBoat can run containers)

    3. **FreeRDP 3.x** (RDP client used to connect to the Windows container/session)

    ---

    ## 0) Quick cleanup (optional, but helps if you tried before)

    ```bash
    sudo apt update
    sudo apt remove -y docker docker.io docker-compose docker-compose-v2 containerd runc || true
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.asc
    ```

    ---

    ## 1) Install Docker Engine + Docker Compose v2 (official repo)

    ```bash
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

    **Verify:**

    ```bash
    docker --version
    docker compose version
    ```

    ---

    ## 2) Enable the daemon + allow your user to run Docker

    ```bash
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    ```

    **Important:** log out and log back in (or reboot) after the `usermod` command.

    **Verify after re-login:**

    ```bash
    docker run --rm hello-world
    ```

    If that fails, check:

    ```bash
    systemctl status docker --no-pager
    journalctl -u docker -n 200 --no-pager
    ```

    ---

    ## 3) Install FreeRDP 3.x (RDP client)

    ```bash
    sudo apt install -y freerdp3-x11
    ```

    **Verify:**

    ```bash
    xfreerdp /buildconfig | head
    ```

    ---

    ## 4) Recommended extras (fix common WinBoat issues)

    ### Kernel/virtualization prerequisites (usually already OK)

    ```bash
    sudo apt install -y qemu-system-x86 cpu-checker
    kvm-ok || true
    ```

    ### If you run into networking/DNS oddities

    ```bash
    sudo apt install -y iptables nftables
    ```

    ---

    ## 5) Final checklist (WinBoat dependencies)

    - [x]  `docker` installed (from Docker repo)

    - [x]  `docker compose` works (Compose v2 plugin)

    - [x]  Docker service is **active**

    - [x]  Your user can run Docker (after re-login)

    - [x]  `freerdp3-x11` installed

- Setting up HP LaserJet P1102w Printer

    This is excellent news. The hardware is completely fine, the USB ports on your CYXPC are routing correctly, and the Ubuntu kernel is seeing the printer exactly as it should. Even better, CUPS has successfully attached the `hp:/` backend to the device.

    The issue is entirely a bug within `hp-setup`'s auto-discovery script. Since we now have the exact hardware address, we can bypass the broken discovery phase and force-feed the connection string directly to the utility.

    ### 1. Force Setup via Explicit URI

    Copy this exact command, which uses the URI outputted by your system:

    ```bash
    sudo hp-setup -i "hp:/usb/HP_LaserJet_Professional_P_1102w?serial=000000000W4412NQPR1a"
    ```

    *(Using* `sudo` *here ensures there are absolutely no lingering* `udev` *permission blocks when it tries to handshake the firmware).*

    If `hp-setup` accepts this, it should immediately ask you to confirm the PPD (driver) and queue name, skipping the "select connection type" menu entirely.

    ### 2. The CUPS Web Interface Bypass

    If HP's command-line tool *still* chokes on its own URI, we can abandon `hp-setup` entirely and wire the printer up directly through the CUPS daemon. Since you already installed the proprietary binary plugin in our very first step, CUPS will know how to use it.

    1. Open your web browser and navigate to the local CUPS admin page:
    `http://localhost:631/admin`

    2. Click **Add Printer** (it will prompt you for your Linux username `ben` and your password).

    3. Under the "Local Printers" list, you should see two entries for the P1102w. **Crucially, select the one that mentions "HPLIP" or starts with `hp:/**`, not the standard USB one.

    4. Click Continue, name the printer, and click Continue again.

    5. On the Make/Model screen, select **HP** and scroll down to find **HP LaserJet Professional p1102w, hpcups... (en) - requires proprietary plugin**.

    6. Click **Add Printer**.

    Once the queue is created via CUPS, the `hplip` background service will detect when print jobs hit that specific queue and inject the necessary binary firmware payload to the printer over the USB cable automatically.
