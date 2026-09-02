---
type: 'Page'
title: Installing Kubuntu 26.04 LTS
aliases: null
description: null
icon: null
createdAt: '2026-07-11T02:06:17.196Z'
lastUpdated: '2026-07-19T13:44:53.314Z'
tags: [Linux]
coverImage: null
---

# Installing Kubuntu 26.04 LTS

[13 Quick Tips to Make Linux File Manager Nautilus Even Better](https://www.youtube.com/watch?v=Ia2CaItxTEk)[13 Quick Tips to Make Linux File Manager Nautilus Even Better - Notes](../Weblinks/13%20Quick%20Tips%20to%20Make%20Linux%20File%20Manager%20Nautilus%20Even%20Better%20(1).md)

- Connecting Bose Bluetooth speaker

    ### 1. Verify Bluetooth is active

    ```bash
    rfkill list bluetooth
    systemctl status bluetooth --no-pager
    bluetoothctl show
    ```

    Confirm:

    ```text
    Soft blocked: no
    Hard blocked: no
    Powered: yes
    ```

    ### 2. Identify the Bluetooth adapter

    ```bash
    lsusb
    sudo dmesg | grep -i -E 'bluetooth|btusb|btrtl|rtl|firmware|hci0'
    ```

    In this case, the adapter was (on CYXPCH):

    ```text
    0bda:b85b Realtek Bluetooth Radio
    RTL8852BU
    ```

    It was loading the older firmware:

    ```text
    fw version 0x42d34e04
    ```

    ### 3. Install newer official RTL8852BU firmware

    Back up the existing files and install the current upstream firmware:

    ```bash
    FW_DIR=/usr/lib/firmware/rtl_bt
    BACKUP_DIR=/root/rtl8852bu-firmware-backup
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp -av \
      "$FW_DIR"/rtl8852bu_fw.bin* \
      "$FW_DIR"/rtl8852bu_config.bin* \
      "$BACKUP_DIR"/ 2>/dev/null || true
    curl -fL \
      "https://gitlab.com/kernel-firmware/linux-firmware/-/raw/main/rtl_bt/rtl8852bu_fw.bin" \
      -o /tmp/rtl8852bu_fw.bin
    sudo install -m 0644 \
      /tmp/rtl8852bu_fw.bin \
      "$FW_DIR/rtl8852bu_fw.bin"
    sudo update-initramfs -u
    sudo poweroff
    ```

    After shutdown, disconnect power for about 30 seconds, reconnect it, and boot Kubuntu.

    Verify that the new firmware loaded:

    ```bash
    sudo dmesg |
      grep -i 'Bluetooth: hci0: RTL: fw version' |
      tail -1
    ```

    The working version was:

    ```text
    fw version 0x127cfd78
    ```

    ### 4. Put the Bose into pairing mode

    Before scanning:

    1. Disconnect any USB cable from the speaker.

    2. Turn off Bluetooth on phones previously connected to it.

    3. Turn on the Bose.

    4. Hold its Bluetooth button until the indicator flashes blue.

    ### 5. Discover and pair through `bluetoothctl`

    ```bash
    bluetoothctl
    ```

    At the prompt:

    ```text
    power on
    agent NoInputNoOutput
    default-agent
    scan bredr
    ```

    The Bose then appeared as:

    ```text
    Device AC:BF:71:AD:C5:92 Bose Flex SE SoundLink
    ```

    Pair, trust, and connect it using the address displayed on your system:

    ```text
    pair AC:BF:71:AD:C5:92
    trust AC:BF:71:AD:C5:92
    connect AC:BF:71:AD:C5:92
    scan off
    info AC:BF:71:AD:C5:92
    quit
    ```

    Confirm that `info` reports:

    ```text
    Paired: yes
    Bonded: yes
    Trusted: yes
    Connected: yes
    ```

    Finally, open Kubuntu’s volume controls and select **Bose Flex SE SoundLink** with the **High Fidelity Playback / A2DP** profile.

- ChatGPT from command line

    Run:
    
    mkdir -p ~/.local/bin
    nano ~/.local/bin/chatgpt
    
    Paste:
    
    #!/usr/bin/env bash
    
    set -euo pipefail
    
    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        echo "Error: OPENAI_API_KEY is not set." >&2
        exit 1
    fi
    
    if [[ $# -eq 0 ]]; then
        echo "Usage: chatgpt \"your question\"" >&2
        exit 1
    fi
    
    prompt="$*"
    
    jq -n \
      --arg model "gpt-5-mini" \
      --arg input "$prompt" \
      '{model: $model, input: $input}' |
    curl -sS https://api.openai.com/v1/responses \
      -H "Authorization: Bearer '"$OPENAI_API_KEY"'" \
      -H "Content-Type: application/json" \
      --data-binary @- |
    jq -r '
      if .error then
        "OpenAI error: " + .error.message
      else
        [.output[]?.content[]? |
          select(.type == "output_text") |
          .text] | join("\n")
      end
    '
    
    Save with Ctrl+O, press Enter, and exit with Ctrl+X.
    
    Make it executable:
    
    chmod +x ~/.local/bin/chatgpt
    
    Make sure ~/.local/bin is in your path:
    
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    
    Now you can enter:
    
    chatgpt "Give me five B2 discussion questions about artificial intelligence in education."
    

- Installing Krokiet (alternative to Czkawka) - File duplicate package

    Yes — **it is possible to open Krokiet from the Kubuntu application menu**, **if** you created the `.desktop` launcher file.

    ### It should appear in the menu if you already did these steps:

    - placed the binary in:

        - `~/.local/bin/krokiet`

    - created the desktop file in:

        - `~/.local/share/applications/io.github.qarmin.krokiet.desktop`

    - refreshed the KDE menu cache with:

    ```bash
    kbuildsycoca6 --noincremental
    ```

    ### Then try this

    1. Press the **Meta / Super key** or click the **Application Launcher**

    2. Search for:

        - **Krokiet**

    If it appears, click it to open.

    ---

    ## If it does **not** appear in the menu

    Run these commands to create the menu entry:

    ```bash
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/io.github.qarmin.krokiet.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=Krokiet
    GenericName=Duplicate File Finder
    Comment=Find duplicate files, similar images, empty folders, and other unnecessary files
    Exec=/home/ben/.local/bin/krokiet
    Icon=system-file-manager
    Terminal=false
    Categories=Utility;FileTools;
    StartupNotify=true
    EOF
    ```

    Then refresh KDE’s application database:

    ```bash
    kbuildsycoca6 --noincremental
    ```

    After that, search again in the menu for **Krokiet**.

    ---

    ## If you want to test the launcher directly

    You can also run:

    ```bash
    gtk-launch io.github.qarmin.krokiet
    ```

    If that works, the menu entry is installed correctly.

    ---

    ## If it still doesn’t show

    Log out and back in, or restart Plasma.

    If you want, I can give you a **single copy-paste block** that:

    1. creates the launcher,

    2. adds a better icon,

    3. refreshes the menu,

    4. and makes Krokiet searchable in Kubuntu.

- Misc

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

    - Replacing Nautilus with Nemo File Manager

        Replacing Nautilus with **Nemo** is widely considered the "Goldilocks" solution for Ubuntu users. While Dolphin is a powerhouse, Nemo (the default file manager for the Cinnamon desktop) feels more at home on Ubuntu 26.04 because it shares the same **GTK** foundations as the rest of your system.

        It provides a traditional desktop experience without the "library bloat" that comes with installing KDE apps like Dolphin.

        ---

        ## Why Nemo is a Strong Choice for Your Workflow

        Nemo was originally a "fork" of an older version of Nautilus, created specifically to bring back features that the GNOME team removed. For someone managing complex file hierarchies like a **PARA/GTD system**, it offers several advantages:

        - **Native Dual-Pane (**`F3`**):** This is the killer feature for moving files between "Projects" and "Archives." You don't have to open two windows; you just toggle the split view.

        - **Breadcrumbs vs. Path Bar:** Nemo lets you toggle between a clickable breadcrumb trail and a traditional text-based path bar with a single click.

        - **Type-ahead Search:** Unlike modern Nautilus, which searches the whole directory as soon as you type, Nemo can be configured to simply jump to the file that starts with that letter (much faster for large folders).

        - **"Open as Root" and "Open in Terminal":** These are built-in right-click options that don't require extra plugins.

        ---

        ## 1. Installation

        Nemo is in the official Ubuntu 26.04 repositories. To get it with all the modern thumbnailing support (for images, videos, and PDFs), run:

        Bash

        `sudo apt update
          sudo apt install nemo nemo-fileroller k適o-extras`

        ---

        ## 2. Setting Nemo as the Default

        To ensure that your system opens Nemo instead of Nautilus when you click on a folder in another application, run this command in your terminal:

        Bash

        `xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search`

        ---

        ## 3. Handling the "Desktop Conflict"

        This is the only tricky part. In Ubuntu, the desktop icons are usually handled by a GNOME extension called "Desktop Icons NG (DING)," which is tied to Nautilus.

        - **Option A (The Safe Way):** Keep using the GNOME "Desktop Icons" extension for your desktop, and just use Nemo for all your file browsing. They won't interfere with each other.

        - **Option B (The Pure Way):** If you want Nemo to handle the desktop icons too, you would need to disable the "Desktop Icons" extension and add `nemo-desktop` to your **Startup Applications**. However, for most users, Option A is much more stable on Ubuntu 26.04.

        ---

        ## Visual Comparison: Nemo vs. Dolphin

        | **Feature**              | **Nemo**                      | **Dolphin**                  |
        | :----------------------- | :---------------------------- | :--------------------------- |
        | **Foundation**           | GTK (Matches Ubuntu natively) | Qt (Requires extra styling)  |
        | **System Weight**        | Very Light                    | Moderate (Pulls in KDE libs) |
        | **Dual Pane**            | Yes (`F3`)                    | Yes (`F3` or Split)          |
        | **Customizability**      | High                          | Extreme                      |
        | **Terminal Integration** | Right-click menu              | Integrated Panel (`F4`)      |

        ### Final Recommendation

        Given that you value **transparency** in your teaching and maintain an **engaging community**, Nemo’s interface is often easier for others to follow during a screen-share. It looks "familiar" to Windows/Mac users while providing the professional-grade organization tools (like dual-pane) that you need for your research and lesson planning.

        Between the "clean and integrated" Nemo and the "limitless" Dolphin, which philosophy aligns more with how you've set up your current Ubuntu 26.04 environment?

    - Install System Monitor-Next Gnome Extension

        This tutorial is optimized for your **PARA/GTD** workflow on **Ubuntu 26.04 LTS**. It focuses on stability and transparency, ensuring that Nemo handles your file management while keeping the core Ubuntu system intact. - April 25, 2026

        ---

        # 📂 Tutorial: Switching to Nemo File Manager (Ubuntu 26.04)

        ## 1. Install Nemo and Core Extensions

        Ubuntu 26.04 requires specific packages for the best integration. We include `nemo-compare` because it is essential for tracking changes in academic drafts and textbook chapters.

        Bash

        `sudo apt update
          sudo apt install nemo nemo-fileroller nemo-compare meld`

        - **nemo**: The core file manager.

        - **nemo-fileroller**: Adds archive (zip/tar) management.

        - **nemo-compare**: Adds a right-click "Compare" tool (requires `meld`).

        ---

        ## 2. Set Nemo as the Default File Manager

        To ensure that all folders (and external applications) open with Nemo instead of Nautilus, run the following command:

        Bash

        `xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search`

        ---

        ## 3. Recommended PARA Workflow Configurations

        Once Nemo is open, adjust these settings to maximize visibility and speed:

        - **Enable Dual Pane**: Press `F3`. This allows you to drag files between your **Projects** and **Archives** without opening multiple windows.

        - **Path Bar**: Go to **Edit > Preferences > Interface**. Ensure "Always show text-entry location bar" is checked if you prefer typing paths, or leave it unchecked for clickable breadcrumbs.

        - **Status Bar**: Go to **View > Status Bar**. This provides an immediate view of remaining disk space—critical for managing large media files for your podcast.

        ---

        ## 4. Workaround: Image Manipulation (Scripting)

        Since the `nemo-image-converter` package is currently unavailable in the 26.04 repositories, use a custom script. This aligns with your goal of **transparent teaching**, as it shows exactly how the system processes data.

        1. **Install the engine**: `sudo apt install imagemagick`

        2. **Create the script**:Bash

            `mkdir -p ~/.local/share/nemo/scripts
             nano ~/.local/share/nemo/scripts/Quick_Resize_1080p`

        3. **Add this logic**:Bash

            `#!/bin/bash
             mogrify -resize 1920x1080 "$1"`

        4. **Make it executable**: `chmod +x ~/.local/share/nemo/scripts/Quick_Resize_1080p`

        *You can now right-click any image and select Scripts > Quick_Resize_1080p.*

        ---

        ## 5. Handling the Desktop

        In Ubuntu 26.04, the desktop icons are managed by the "Desktop Icons NG (DING)" extension, which is tied to Nautilus.

        - **Recommendation**: Leave the desktop icons as they are. Continue using the standard Ubuntu desktop for shortcuts, but use Nemo for all your deep work and file organization. This prevents conflicts with the GNOME Shell.

        ---

        > **Notion Note**: After completing these steps, **reboot your system**. This ensures that the Ubuntu Pro security patches (ESM) and your Docker group permissions for WinBoat are fully synchronized with the new file manager environment.

        How are you finding the transition to Nemo's dual-pane view for moving your academic research files compared to the standard Nautilus experience?

    - Floorp Browser Setup for RAM Effeciency

        To get the most out of **Floorp** on your **Ubuntu 26.04** setup—especially for a workflow involving heavy research and educational content creation—here is the consolidated checklist for maximum RAM efficiency.

        ---

        ## 1. System & Installation

        - **Use the Native Package:** Ensure you are using the **.deb (PPA)** version rather than the Flatpak or Snap. This allows Floorp to share system libraries with Ubuntu, reducing the base memory footprint.

        - **Enable zRAM:** In your terminal, run `sudo apt install zram-config`. This compresses data in your RAM rather than swapping to the slower disk, keeping the system responsive when you have many tabs open.

        ## 2. Interface & Visuals (The Quick Wins)

        - **Disable Tab Previews:** In **Settings > General > Tabs**, uncheck **"Show an image preview when you hover on a tab."** This stops the browser from holding a visual snapshot of every tab in memory.

        - **Disable AI Bloat:** In the **AI Controls** tab of the sidebar, toggle **"Block AI enhancements"** to **ON**. This prevents background processes from pre-loading local machine learning models.

        - **Disable Tab Suggestions:** In **Settings > General > Tabs**, uncheck **"Use AI to suggest tabs..."** to save CPU and RAM cycles.

        ## 3. Floorp Hub & Sidebar (The Heavy Lifters)

        - **Unload Sidebar Panels:** In **Floorp Hub > Panel Sidebar**, toggle **ON** the setting **"Unload when closing panel."** This ensures that your sidebar tools (Notion, Calendar, etc.) release their RAM the moment you hide them.

        - **Aggressive Tab Sleep:** In **Settings > Tabs > Tab Sleep**, set a short timer (e.g., 10 minutes) for inactive tabs.

        - **Workspace Management:** If you use multiple Workspaces, ensure **"Sleep tabs in inactive workspaces"** is enabled so background projects don't consume resources.

        ## 4. Media & Under-the-Hood Tweaks

        - **YouTube Optimization:** Turn off **Ambient Mode** in the YouTube player settings to save roughly 300MB of RAM per video tab.

        - **Advanced Config (**`about:config`**):**

            - `media.av1.enabled` → Set to **false** (Reduces CPU/RAM load for video).

            - `browser.cache.disk.enable` → Set to **true** (Moves some cache to the disk).

            - `image.mem.surfacecache_max_size_kb` → Lower this to limit how many images stay cached in memory.

        ## 5. Extensions

        - **uBlock Origin:** Mandatory. It blocks memory-heavy tracking scripts before they even load.

        - **Auto Tab Discard:** While Floorp has native sleep, this extension offers even more granular "discarding" of tabs to ensure they use zero RAM until you click them again.

        ---

        By combining these tweaks, you'll find that Floorp remains snappy even when you're jumping between your textbook research, teaching portals, and podcast planning.

        Are there any specific "heavy" sites you use for your ELT work that still seem to be dragging the system down?

    - Setting up Flatpak

        - Install Flatpak

            ### 1. Install Flatpak

            Bash

            `sudo apt update
              sudo apt install flatpak`

            ### 2. Add Flathub (recommended)

            Bash

            `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`

            ### 3. (Optional) Install a GUI store that supports Flatpak

            If you want Flatpaks to appear in a graphical app store, install GNOME Software + the Flatpak plugin:

            Bash

            `sudo apt install gnome-software gnome-software-plugin-flatpak`

            ### 4. Restart the session (recommended)

            Log out and back in (or reboot) so the app list refreshes and integrations load cleanly.

            ### 5. Verify

            Bash

            `flatpak --version
              flatpak remotes`

        Flatpak packages do not appear in **Ubuntu 26.04 (Resolute Raccoon)** because of a deliberate design choice by Canonical: the new **Ubuntu App Center** (the default "Store") only supports **Snap** and **Debian (.deb)** packages.

        It does not have a plugin to display Flatpaks, and as of this April 2026 release, there are no plans to add one.

        To get Flatpaks to appear in a graphical store on your ASUS, you have to bypass the App Center entirely and install the "original" GNOME Software store.

        ### How to make Flatpaks visible in a GUI

        Since the default App Center won't show them, follow these steps to install the version of the software store that *does* support them:

        1. **Install the Flatpak-enabled Store:**Bash

            Open your terminal and run:

            `sudo apt update
             sudo apt install gnome-software gnome-software-plugin-flatpak`

        2. **Add the Flathub Repository:**Bash

            Even with the store installed, you need to "plug in" the catalog of apps:

            `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`

        3. **Restart your System:**

            For the "Software" store to properly index everything and show up in your app drawer, a reboot is usually necessary.

        ### Why this happens (The "Ubuntu Way")

        - **Snap Prioritization:** Canonical developed the new App Center using Flutter to provide a unified experience for Snaps and local `.deb` files. Because Flatpak is a direct competitor to Snap, they don't include it by default.

        - **Clean Experience:** For many users, having three different package formats (Deb, Snap, Flatpak) in one store causes confusion (e.g., seeing three different "Install" buttons for the same app).

        - **System Stability:** Since you've mentioned your interest in **transparent pedagogy** and **system customization**, you might actually prefer the terminal for Flatpaks, as it gives you much clearer feedback when things go wrong (like the "Segmentation fault" we saw earlier).

        **Pro Tip:** After you install `gnome-software`, you will have two apps named "Software" or "App Center." Look for the one with the **white shopping bag icon**—that's the one that will show you Floorp and other Flatpaks!

    - Favorite Desktop Apps

        Insync

        Linux Mint webapp-manager package

        ### Gradient Backgrounds

        To install gradient backgrounds in Ubuntu 26.04 that resemble the native ones in Linux Mint, you have a few options, ranging from simple image installation to using dynamic tools.

        ### Option 1: The Fast and Easy Way (Using Images)

        This is the quickest way to get the look. You aren't "installing a feature" as much as you are setting a new wallpaper.

        1. **Find Gradient Images:**

            - **Direct Source:** You can download the actual Linux Mint backgrounds. The easiest way is to search online for "Linux Mint wallpapers GitHub." You will often find repositories containing the exact `.jpg` or `.png` gradient files. Look for folders like `mint-background-xfce` or specific release names (like "Una" or "Vera").

            - **Wallpaper Sites:** Search sites like Wallhaven.cc or Unsplash for "minimalist gradient background 4k," "subtle blue gradient," or "Linux wallpaper flat."

        2. **Save the Images:** Create a new folder in your Pictures directory called `Gradients` and save your chosen images there.

        3. **Set as Background:**

            - **Via Settings:** Open **Settings**, go to **Appearance** or **Background**. Click **Add Picture...**, navigate to your `Gradients` folder, and select the image.

            - **Via File Manager:** Open **Files**, right-click the image you saved, and select **Set as Wallpaper**.

        ### Option 2: The "Authentic" Way (Getting the Mint Utility)

        Linux Mint uses a specific tool to generate its solid/gradient colors. If you want the exact functional capability that Mint provides, you can install its configuration tool.

        **Note:** This works best if you are running the **Cinnamon Desktop Environment** on Ubuntu, rather than the default GNOME. If you are on GNOME, you can try this, but it might require a full Cinnamon installation or lead to conflicts.

        **If you are running Cinnamon on Ubuntu:**

        1. **Open a Terminal** (Ctrl+Alt+T).

        2. **Install the necessary package:**Bash

            `sudo apt update
             sudo apt install mint-backgrounds`

        3. Now, when you right-click on the desktop and select **Change Desktop Background**, you should see the traditional Mint interface that allows you to select solid or gradient colors, and choose the "Vertical" or "Horizontal" gradient types.

        ### Option 3: Use a Dedicated Tool (Highly Recommended)

        For the best, highest-quality, and most customizable gradients on any desktop environment (including default Ubuntu/GNOME), you should use a dedicated wallpaper generation tool. This ensures you get a perfect vector gradient that isn't pixelated.

        The best tool for this is **Dynamic Wallpaper**.

        1. **Install 'Dynamic Wallpaper':** It is available as a Flatpak. Assuming you have Flatpak set up on Ubuntu 26.04:Bash

            `flatpak install flathub com.github.johnfactotum.DynamicWallpaper`

        2. **Run the App:** Open the "Dynamic Wallpaper" application.

        3. **Create your Gradient:** The interface is simple.

            - Set the "Style" to **Gradient**.

            - Select two or more colors. You can mimic Mint’s look by selecting a slightly darker blue/green for the first color and a slightly lighter version of the same color for the second.

            - Set the gradient angle (e.g., Vertical or Diagonal).

        4. **Set as Wallpaper:** Click the checkmark/save button, and it will generate the image and automatically set it as your background.

        This method gives you the "Mint feel" but allows you to customize it exactly how you want.

        ### Install Microsoft Fonts

        How to install Microsoft fonts in Linux office suites

        ```text
        sudo apt-get install ttf-mscorefonts-installer
        sudo apt-get install cabextract
        mkdir .fonts
        wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash
        ```

        ```text
        sudo add-apt-repository multiverse && sudo apt update && sudo apt install ttf-mscorefonts-installer && sudo fc-cache -f -v
        ```

        ```text
        sudo apt install variety gdebi ubuntu-restricted-extras gnome-shell-extensions gnome-shell-extension-manager timeshift pspp bleachbit blueman preload
        ```

        ```text
        sudo snap install teams-for-linux kdenlive okular zotero-snap bluetooth-autostart
        ```

        ### Gnome extensions

        !Gnome ext.jpeg

    - Favorite Laptop Apps

        pCloud

    - Troubleshooting

        - Boot issues

            ```jsx
            insmod normal
            normal
            ```

    - If PDF thumbnails do not appear

        💡 Make sure evince is installed

        That "Unable to locate package" error is common and usually easy to fix. It simply means that your system's package manager (`apt`) can't find a package with that exact name in the software sources it knows about.

        This happens for a few reasons, but the most likely is that the thumbnailer is now included as part of the main `evince` package in modern versions of Ubuntu.

        ---

        ### The Likely Solution: Install Evince

        In recent Ubuntu releases, you don't need to install the thumbnailer separately. It comes bundled with Evince, the default document viewer. Even if you use Okular to open PDFs, the system still uses the Evince background service for generating thumbnails in the file manager.

        Try installing the main `evince` package. This will almost certainly provide the thumbnailing capability you're looking for.

        Bash

        `sudo apt update
          sudo apt install evince`

        After this, clear your cache as described before, and the thumbnails should start generating.

        ---

        ### Other Troubleshooting Steps

        If the above doesn't work, here are the other common causes and solutions, in order.

        ### 1. Ensure the 'Universe' Repository is Enabled

        Many useful packages are in Ubuntu's "Universe" repository. It's usually enabled by default, but it's worth checking.

        Run this command to enable it and then update your package lists again:

        Bash

        `sudo add-apt-repository universe
          sudo apt update`

        Now, try installing `evince` or `evince-thumbnailer` again.

        ### 2. Search for the Package Name

        If the name has changed, you can search for it. The `apt-cache search` command is great for this. Try searching for related keywords.

        Bash

        `apt-cache search pdf thumbnailer`

        This will give you a list of all available packages that have "pdf" and "thumbnailer" in their name or description, allowing you to find the correct package name if it has been changed.

        For your situation, simply running `sudo apt install evince` is the most direct and probable fix. 👍


