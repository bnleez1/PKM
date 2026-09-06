---
type: Page
title: Installing NextCloud
aliases:
description:
icon: ✴️
createdAt: 2026-07-04T14:26:18.442Z
lastUpdated: 2026-07-07T18:20:57.373Z
tags:
  - Linux
coverImage: "[Untitled](../Images/Untitled%20(304).md)"
---

# Installing NextCloud

### Installing NextCloud in Cosmic Desktop

- Recommendations for Setting Up NextCloud in Cosmic Desktop

    This version assumes **nothing is installed yet** and uses this exact local Linux username and external hard-drive path:

    ```text
    Linux username: ben
    External drive: /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    Recommended sync folder: /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    This guide installs and configures:

    1. **Nextcloud Server** with the Snap package.

    2. **Nextcloud Desktop Client** with the official Linux AppImage.

    3. The desktop client so it syncs to the Seagate external drive.

    4. Automatic server startup after reboot.

    5. Automatic desktop-client startup after `ben` logs in to COSMIC.

    6. A startup wrapper that waits for the external drive before launching sync.

    ---

    # 0. Read this first: server storage vs. desktop sync folder

    Nextcloud has two different parts.

    - Install Snap

        Run these commands exactly:

        ```bash
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        ```

        Then reboot:

        ```bash
        sudo reboot
        ```

        After reboot, log back in as `ben` and check that Snap now works:

        ```bash
        snap version
        ```

        Then continue with Nextcloud:

        ```bash
        sudo snap install nextcloud
        sudo snap start --enable nextcloud
        snap services nextcloud
        ```

        I also added this troubleshooting note to your Capacities page so the guide now covers `sudo: snap: command not found`.

    ## Nextcloud Server

    The server is the web application. It manages users, files, sharing, the Android app, the web interface, and remote access.

    In this guide, the server is installed with:

    ```bash
    sudo snap install nextcloud
    ```

    The server will start automatically after the computer boots.

    ## Nextcloud Desktop Client

    The desktop client is the sync program. It runs after `ben` logs in to COSMIC and keeps a local folder synchronized with the Nextcloud server.

    In this guide, the desktop client syncs to:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    ## Important safety rule

    Do **not** use the same folder as both:

    - the server’s internal data folder, and

    - the desktop client’s sync folder.

    That can create sync loops, permission conflicts, duplicates, or data loss.

    This guide uses the external hard drive as the **desktop sync target**. That means files placed in the external drive’s `Nextcloud_Sync` folder are uploaded to the Nextcloud server, and files uploaded to the server appear in that folder.

    ---

    # 1. Verify the external hard drive

    Open **COSMIC Terminal**.

    Set the drive path as a variable:

    ```bash
    DRIVE="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
    ```

    Check that the drive exists:

    ```bash
    ls -ld "$DRIVE"
    ```

    Check the filesystem type and free space:

    ```bash
    df -T "$DRIVE"
    df -h "$DRIVE"
    ```

    Check whether Linux recognizes it as a mount point:

    ```bash
    findmnt "$DRIVE"
    ```

    Test whether user `ben` can write to it:

    ```bash
    touch "$DRIVE/.nextcloud-write-test"
    rm "$DRIVE/.nextcloud-write-test"
    ```

    If the `touch` command fails, fix ownership:

    ```bash
    sudo chown ben:ben "$DRIVE"
    chmod 755 "$DRIVE"
    ```

    Do not recursively change ownership of the entire drive yet unless you are sure everything on it should belong to `ben`.

    ---

    # 2. Make the external drive mount reliably after reboot

    Nextcloud sync must not start before the external drive is ready.

    First, find the drive UUID:

    ```bash
    lsblk -f
    ```

    Look for the partition that mounts at:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    ```

    Write down its UUID and filesystem type

    ```text
    a8dc957e-100b-49f7-93e2-651cacec923f
    ```

    Open `/etc/fstab`:

    ```bash
    sudo nano /etc/fstab
    ```

    If the drive is `ext4`, add a line like this, replacing `<UUID>` with the real UUID:

    ```text
    UUID=<UUID> /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 ext4 defaults,nofail,x-systemd.automount 0 2
    ```

    If the drive is `ntfs3`, first check user and group IDs:

    ```bash
    id ben
    ```

    For a typical single-user system, `ben` is usually UID `1000` and GID `1000`. If the numbers are different, use the real numbers.

    Add a line like this for `ntfs3`:

    ```text
    UUID=<UUID> /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 ntfs3 rw,uid=1000,gid=1000,nofail,x-systemd.automount 0 0
    ```

    Save and exit Nano:

    ```text
    Ctrl+O → Enter → Ctrl+X
    ```

    Reload and test:

    ```bash
    sudo systemctl daemon-reload
    sudo mount -a
    findmnt "$DRIVE"
    ```

    Do not continue until `findmnt` confirms that the drive is mounted at the exact path.

    ---

    # 3. Create a dedicated Nextcloud sync folder on the external drive

    Do **not** use the raw drive root as the sync folder unless you intentionally want everything at the top of the drive synced.

    Recommended folder:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    Create it:

    ```bash
    SYNC_ROOT="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync"
    mkdir -p "$SYNC_ROOT"
    sudo chown -R ben:ben "$SYNC_ROOT"
    find "$SYNC_ROOT" -type d -exec chmod 755 {} \;
    find "$SYNC_ROOT" -type f -exec chmod 644 {} \;
    ```

    Confirm:

    ```bash
    ls -ld "$SYNC_ROOT"
    ```

    It should show `ben ben` as owner and group.

    If you already have files on the Seagate drive that you want in Nextcloud, the safest novice method is:

    1. Keep them where they are for now.

    2. Finish the server and client setup.

    3. After the sync client works, move or copy the desired folders into `Nextcloud_Sync`.

    Avoid syncing Linux system folders such as `lost+found`.

    ---

    # 4. Install system requirements

    Update the system:

    ```bash
    sudo apt update
    sudo apt full-upgrade -y
    ```

    Install basic tools:

    ```bash
    sudo apt install -y snapd curl wget jq ufw gnome-keyring libsecret-tools libnotify-bin desktop-file-utils
    sudo apt install -y libfuse2t64 || sudo apt install -y libfuse2
    ```

    Enable Snap support:

    ```bash
    sudo systemctl enable --now snapd.socket
    sudo snap install core
    ```

    Reboot once:

    ```bash
    sudo reboot
    ```

    After reboot, log back in as `ben` and open **COSMIC Terminal**.

    Confirm Snap works:

    ```bash
    snap version
    ```

    ---

    # 5. Install the Nextcloud server

    Install the Nextcloud server Snap:

    ```bash
    sudo snap install nextcloud
    ```

    Confirm it installed:

    ```bash
    snap list nextcloud
    snap services nextcloud
    ```

    Enable and start all Nextcloud services:

    ```bash
    sudo snap start --enable nextcloud
    ```

    ---

    # 6. Create the first Nextcloud admin account

    Use `ben` as the first Nextcloud admin username:

    ```bash
    read -s -p "Create a strong Nextcloud admin password for ben: " NC_ADMIN_PASS
    echo
    sudo nextcloud.manual-install ben "$NC_ADMIN_PASS"
    unset NC_ADMIN_PASS
    ```

    Store this password in a password manager.

    This creates the first admin account for the web interface.

    ---

    # 7. Configure trusted local access

    Test the local server:

    ```bash
    xdg-open http://localhost
    ```

    If the page opens, log in as:

    ```text
    Username: ben
    Password: the password created in Phase 6
    ```

    Find the local IP address:

    ```bash
    LOCAL_IP="$(hostname -I | awk '{print $1}')"
    echo "$LOCAL_IP"
    ```

    Add local trusted domains:

    ```bash
    sudo nextcloud.occ config:system:set trusted_domains 1 --value="localhost"
    sudo nextcloud.occ config:system:set trusted_domains 2 --value="$LOCAL_IP"
    sudo nextcloud.occ config:system:get trusted_domains
    ```

    Test local IP access:

    ```bash
    xdg-open "http://$LOCAL_IP"
    ```

    ---

    # 8. Turn on the firewall safely

    Allow web traffic:

    ```bash
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    ```

    If you use SSH to manage this computer remotely:

    ```bash
    sudo ufw allow OpenSSH
    ```

    Enable the firewall:

    ```bash
    sudo ufw enable
    sudo ufw status verbose
    ```

    ---

    # 9. Optional: configure public domain and HTTPS

    Skip this section if you only need local network access for now.

    Use this section if you want Android, tablet, or laptop access from outside the local network.

    Example domain:

    ```text
    hub.benjaminlstewart.net
    ```

    Requirements before enabling Let’s Encrypt:

    - the domain points to your public IP address

    - router port forwarding sends TCP 80 to this COSMIC computer

    - router port forwarding sends TCP 443 to this COSMIC computer

    - the firewall allows ports 80 and 443

    - your ISP does not block inbound 80 or 443

    Add the domain as trusted:

    ```bash
    DOMAIN="hub.benjaminlstewart.net"
    sudo nextcloud.occ config:system:set trusted_domains 3 --value="$DOMAIN"
    sudo nextcloud.occ config:system:get trusted_domains
    ```

    Enable Let’s Encrypt HTTPS:

    ```bash
    sudo nextcloud.enable-https lets-encrypt
    ```

    Follow the prompts.

    Test:

    ```bash
    xdg-open "https://hub.benjaminlstewart.net"
    ```

    For local testing only, self-signed HTTPS is also possible:

    ```bash
    sudo nextcloud.enable-https self-signed
    ```

    Self-signed certificates will cause browser and Android trust warnings.

    ---

    # 10. Verify that the server starts automatically after reboot

    Reboot:

    ```bash
    sudo reboot
    ```

    After logging back in as `ben`, check the server:

    ```bash
    snap services nextcloud
    sudo nextcloud.occ status
    xdg-open http://localhost
    ```

    If using a domain:

    ```bash
    xdg-open https://hub.benjaminlstewart.net
    ```

    At this point, the **server** should start automatically after every reboot.

    ---

    # 11. Install the Nextcloud Desktop Client AppImage

    Create local application folders:

    ```bash
    mkdir -p /home/ben/Applications /home/ben/.local/bin /home/ben/.local/share/applications /home/ben/.config/autostart
    ```

    Download the latest official Linux x86_64 AppImage from the Nextcloud desktop release repository:

    ```bash
    APPIMAGE_URL="$(
      curl -fsSL https://api.github.com/repos/nextcloud-releases/desktop/releases/latest \
        | jq -r '.assets[] | select(.name | test("x86_64.AppImage$")) | .browser_download_url' \
        | head -n 1
    )"
    echo "$APPIMAGE_URL"
    wget -O /home/ben/Applications/Nextcloud.AppImage "$APPIMAGE_URL"
    chmod +x /home/ben/Applications/Nextcloud.AppImage
    ```

    Confirm:

    ```bash
    ls -lh /home/ben/Applications/Nextcloud.AppImage
    ```

    If the command-line download fails, download the Linux AppImage manually from:

    ```text
    https://nextcloud.com/install/
    ```

    Then move it to:

    ```text
    /home/ben/Applications/Nextcloud.AppImage
    ```

    and run:

    ```bash
    chmod +x /home/ben/Applications/Nextcloud.AppImage
    ```

    ---

    # 12. Create a COSMIC launcher for the desktop client

    Run:

    ```bash
    cat > /home/ben/.local/share/applications/nextcloud-appimage.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Nextcloud
    Comment=Nextcloud Desktop Sync Client
    Exec=/home/ben/Applications/Nextcloud.AppImage
    Icon=nextcloud
    Terminal=false
    Categories=Network;FileTransfer;
    EOF
    update-desktop-database /home/ben/.local/share/applications 2>/dev/null || true
    ```

    If the app does not appear in the COSMIC launcher immediately, log out and log back in.

    ---

    # 13. Launch the desktop client for the first time

    Start the client manually:

    ```bash
    /home/ben/Applications/Nextcloud.AppImage
    ```

    In the setup wizard:

    1. Click **Log in to your Nextcloud**.

    2. For a local server on the same COSMIC computer, enter:

    ```text
    http://localhost
    ```

    1. If you configured public HTTPS, you may instead enter:

    ```text
    https://hub.benjaminlstewart.net
    ```

    1. The browser opens.

    2. Log in as `ben`.

    3. Click **Grant access**.

    4. Return to the desktop-client wizard.

    ---

    # 14. Select the Seagate external drive sync folder

    In the desktop-client wizard, change the local sync folder from the default:

    ```text
    /home/ben/Nextcloud
    ```

    to this exact folder:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    Recommended novice choice:

    ```text
    Choose what to sync
    ```

    Start with a small set of folders first. After confirming everything works, add more folders.

    If the server is new and empty, the sync folder may also be empty at first. That is normal.

    Click **Connect**.

    After connection, the Nextcloud tray icon should appear. It may show sync activity while it indexes.

    ---

    # 15. Move existing Seagate files into Nextcloud sync safely

    If your Seagate drive already contains folders you want synced, move or copy them into:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    Example:

    ```bash
    mv "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/My Course Files" "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync/"
    ```

    Or copy first, if you want a safer test:

    ```bash
    cp -a "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/My Course Files" "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync/"
    ```

    Do not move everything at once if the drive contains hundreds of GB or more. Start with one small folder and verify the web interface sees it.

    ---

    # 16. Create the startup script that waits for the Seagate drive

    This script prevents the desktop client from starting before the external drive is mounted.

    Create the script:

    ```bash
    cat > /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh <<'EOF'
    #!/usr/bin/env bash
    APP="/home/ben/Applications/Nextcloud.AppImage"
    DRIVE="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
    SYNC_ROOT="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync"
    LOCAL_STATUS_URL="http://localhost/status.php"
    DOMAIN_HOST="hub.benjaminlstewart.net"
    # Avoid duplicate desktop-client processes.
    if pgrep -f "Nextcloud.AppImage" >/dev/null 2>&1; then
      exit 0
    fi
    # Wait up to 5 minutes for the external drive, sync folder, and server/network.
    for i in {1..60}; do
      if mountpoint -q "$DRIVE" && [ -d "$SYNC_ROOT" ] && [ -x "$APP" ]; then
        if curl -fsS "$LOCAL_STATUS_URL" >/dev/null 2>&1 || ping -c 1 -W 1 "$DOMAIN_HOST" >/dev/null 2>&1; then
          exec "$APP" --background
        fi
      fi
      sleep 5
    done
    notify-send "Nextcloud client not started" "The Seagate drive, sync folder, server, or AppImage was not ready after 5 minutes. Check /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1."
    exit 1
    EOF
    chmod +x /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    ```

    Test it manually:

    ```bash
    /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    ```

    Confirm the client is running:

    ```bash
    pgrep -a -i nextcloud
    ```

    ---

    # 17. Add the desktop client to COSMIC autostart

    Create the autostart file:

    ```bash
    cat > /home/ben/.config/autostart/nextcloud-client-seagate-cosmic.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Nextcloud Desktop Client - Seagate Sync
    Comment=Start Nextcloud after the Seagate external drive is mounted
    Exec=/home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    Terminal=false
    X-GNOME-Autostart-enabled=true
    EOF
    ```

    Check it:

    ```bash
    cat /home/ben/.config/autostart/nextcloud-client-seagate-cosmic.desktop
    ```

    Important: use **one** desktop-client autostart method only.

    In the Nextcloud desktop client, open:

    ```text
    Settings → General
    ```

    If **Launch on System Startup** is enabled, turn it **off** because this guide uses the safer Seagate-wait script instead.

    Check for duplicates:

    ```bash
    grep -ril "nextcloud" /home/ben/.config/autostart 2>/dev/null
    ```

    The preferred autostart file is:

    ```text
    /home/ben/.config/autostart/nextcloud-client-seagate-cosmic.desktop
    ```

    ---

    # 18. Final reboot test

    Reboot:

    ```bash
    sudo reboot
    ```

    Log back in as `ben`.

    Wait 30–60 seconds.

    Check the Seagate drive:

    ```bash
    DRIVE="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
    SYNC_ROOT="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync"
    findmnt "$DRIVE"
    ls -ld "$SYNC_ROOT"
    ```

    Check the server:

    ```bash
    snap services nextcloud
    sudo nextcloud.occ status
    ```

    Check the desktop client:

    ```bash
    pgrep -a -i nextcloud
    ```

    Open the server:

    ```bash
    xdg-open http://localhost
    ```

    If using a domain:

    ```bash
    xdg-open https://hub.benjaminlstewart.net
    ```

    ---

    # 19. Test sync from the Seagate drive to Nextcloud

    Create a test file inside the Seagate sync folder:

    ```bash
    echo "Nextcloud Seagate sync test created on $(date)" > "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync/test-from-seagate.txt"
    ```

    Wait for the Nextcloud tray icon to finish syncing.

    Then open the web interface:

    ```bash
    xdg-open http://localhost
    ```

    Look for:

    ```text
    test-from-seagate.txt
    ```

    Now test the other direction:

    1. In the Nextcloud web interface, upload or create a small file.

    2. Wait for sync.

    3. Check the Seagate sync folder:

    ```bash
    ls -la "/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync"
    ```

    If files move both ways, the core setup works.

    ---

    # 20. Optional: allow the Snap server to see removable media

    This is only needed if you later use the Nextcloud server’s **External Storage** app to expose folders from `/mnt` directly through the web interface.

    Connect the Snap removable-media interface:

    ```bash
    sudo snap connect nextcloud:removable-media
    ```

    Enable the External Storage app:

    ```bash
    sudo nextcloud.occ app:enable files_external
    ```

    Then in the Nextcloud web interface:

    ```text
    Profile icon → Administration settings → External storage
    ```

    Use this only if you understand the difference between:

    - desktop-client sync folder, and

    - server-side external storage.

    Do **not** configure the exact same folder as both a desktop sync folder and a server-side external storage location.

    If you want server-side external storage later, create a separate folder such as:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Server_External
    ```

    Keep this separate from:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    ---

    # 21. Troubleshooting

    ## The Seagate drive is not mounted after reboot

    Check:

    ```bash
    findmnt /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    lsblk -f
    systemctl status mnt-usb\x2dSeagate_Portable_NT3FC3M0\x2d0:0\x2dpart1.automount 2>/dev/null || true
    ```

    Recheck the `/etc/fstab` line.

    ## The desktop client starts but shows a missing-folder warning

    This means the client started before the drive or sync folder was ready, or the folder path changed.

    Run:

    ```bash
    mountpoint -q /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 && echo "Drive mounted"
    ls -ld /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    Then restart the client:

    ```bash
    pkill -f Nextcloud.AppImage
    /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    ```

    ## The desktop client does not start after login

    Check the autostart file:

    ```bash
    cat /home/ben/.config/autostart/nextcloud-client-seagate-cosmic.desktop
    ```

    Test the script manually:

    ```bash
    /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    ```

    Check processes:

    ```bash
    pgrep -a -i nextcloud
    ```

    ## AppImage does not open

    Install FUSE support:

    ```bash
    sudo apt install -y libfuse2t64 || sudo apt install -y libfuse2
    /home/ben/Applications/Nextcloud.AppImage
    ```

    ## Nextcloud asks for login again after reboot

    Check keyring support:

    ```bash
    dpkg -l | grep -E "gnome-keyring|libsecret"
    ```

    If COSMIC asks to unlock the keyring, unlock it. The desktop client needs a Linux password manager/keyring to remember login securely.

    ## Duplicate Nextcloud clients are running

    Check:

    ```bash
    pgrep -a -i nextcloud
    grep -ril "nextcloud" /home/ben/.config/autostart 2>/dev/null
    ```

    Keep only one autostart method.

    ## Android cannot delete files

    If Android cannot delete files that are stored in the server’s normal file area, check Nextcloud web permissions first.

    If Android cannot delete files from a server-side External Storage mount, the issue is usually server-side filesystem or external-storage permission configuration, not an Android app setting.

    For this guide’s main setup, files inside `Nextcloud_Sync` are synced by the desktop client as user `ben`, so local write permission should belong to `ben`.

    ---

    # 22. Maintenance commands

    Check server status:

    ```bash
    snap services nextcloud
    sudo nextcloud.occ status
    ```

    Restart server:

    ```bash
    sudo snap restart nextcloud
    ```

    Check desktop client:

    ```bash
    pgrep -a -i nextcloud
    ```

    Restart desktop client:

    ```bash
    pkill -f Nextcloud.AppImage
    /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    ```

    Check sync folder:

    ```bash
    ls -la /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

    Check available space:

    ```bash
    df -h /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    ```

    ---

    # 23. One-page command summary

    Use this only after reading the full guide.

    ```bash
    # Variables
    DRIVE="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
    SYNC_ROOT="$DRIVE/Nextcloud_Sync"
    # Verify drive
    ls -ld "$DRIVE"
    df -T "$DRIVE"
    findmnt "$DRIVE"
    touch "$DRIVE/.nextcloud-write-test" && rm "$DRIVE/.nextcloud-write-test"
    # Create sync folder
    mkdir -p "$SYNC_ROOT"
    sudo chown -R ben:ben "$SYNC_ROOT"
    find "$SYNC_ROOT" -type d -exec chmod 755 {} \;
    find "$SYNC_ROOT" -type f -exec chmod 644 {} \;
    # System prep
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt install -y snapd curl wget jq ufw gnome-keyring libsecret-tools libnotify-bin desktop-file-utils
    sudo apt install -y libfuse2t64 || sudo apt install -y libfuse2
    sudo systemctl enable --now snapd.socket
    sudo snap install core
    # Install server
    sudo snap install nextcloud
    sudo snap start --enable nextcloud
    # Create admin account
    read -s -p "Create a strong Nextcloud admin password for ben: " NC_ADMIN_PASS
    echo
    sudo nextcloud.manual-install ben "$NC_ADMIN_PASS"
    unset NC_ADMIN_PASS
    # Trust localhost and local IP
    LOCAL_IP="$(hostname -I | awk '{print $1}')"
    sudo nextcloud.occ config:system:set trusted_domains 1 --value="localhost"
    sudo nextcloud.occ config:system:set trusted_domains 2 --value="$LOCAL_IP"
    # Firewall
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw enable
    # Check server
    snap services nextcloud
    sudo nextcloud.occ status
    xdg-open http://localhost
    # Install desktop client AppImage
    mkdir -p /home/ben/Applications /home/ben/.local/bin /home/ben/.local/share/applications /home/ben/.config/autostart
    APPIMAGE_URL="$(
      curl -fsSL https://api.github.com/repos/nextcloud-releases/desktop/releases/latest \
        | jq -r '.assets[] | select(.name | test("x86_64.AppImage$")) | .browser_download_url' \
        | head -n 1
    )"
    wget -O /home/ben/Applications/Nextcloud.AppImage "$APPIMAGE_URL"
    chmod +x /home/ben/Applications/Nextcloud.AppImage
    # Launcher
    cat > /home/ben/.local/share/applications/nextcloud-appimage.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Nextcloud
    Comment=Nextcloud Desktop Sync Client
    Exec=/home/ben/Applications/Nextcloud.AppImage
    Icon=nextcloud
    Terminal=false
    Categories=Network;FileTransfer;
    EOF
    # Startup script
    cat > /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh <<'EOF'
    #!/usr/bin/env bash
    APP="/home/ben/Applications/Nextcloud.AppImage"
    DRIVE="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1"
    SYNC_ROOT="/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync"
    LOCAL_STATUS_URL="http://localhost/status.php"
    DOMAIN_HOST="hub.benjaminlstewart.net"
    if pgrep -f "Nextcloud.AppImage" >/dev/null 2>&1; then
      exit 0
    fi
    for i in {1..60}; do
      if mountpoint -q "$DRIVE" && [ -d "$SYNC_ROOT" ] && [ -x "$APP" ]; then
        if curl -fsS "$LOCAL_STATUS_URL" >/dev/null 2>&1 || ping -c 1 -W 1 "$DOMAIN_HOST" >/dev/null 2>&1; then
          exec "$APP" --background
        fi
      fi
      sleep 5
    done
    notify-send "Nextcloud client not started" "The Seagate drive, sync folder, server, or AppImage was not ready after 5 minutes."
    exit 1
    EOF
    chmod +x /home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    # COSMIC autostart
    cat > /home/ben/.config/autostart/nextcloud-client-seagate-cosmic.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Nextcloud Desktop Client - Seagate Sync
    Comment=Start Nextcloud after the Seagate external drive is mounted
    Exec=/home/ben/.local/bin/start-nextcloud-client-after-seagate.sh
    Terminal=false
    X-GNOME-Autostart-enabled=true
    EOF
    # Launch setup wizard
    /home/ben/Applications/Nextcloud.AppImage
    ```

    In the setup wizard, choose this local sync folder:

    ```text
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1/Nextcloud_Sync
    ```

### Linux Mint

- Recommendations for accessing NextCloud in Linux Mint Cinnamon 22.3

    ## Updated replacement for the “Recommendations for accessing NextCloud from Office” toggle

    Use this updated version because the office external drive is also connected to a Nextcloud server-side external storage workflow. The safest setup is not simply `ben:ben` ownership. The drive should allow both the Linux desktop user `ben` and the Nextcloud web-server user/group `www-data` to write, delete, and keep new files group-accessible.

    ---

    ### Phase 1: Prepare the external hard drive with shared permissions

    Linux Mint may dynamically mount external drives when you click them in Nemo, but for a large Nextcloud library and server-side external storage, use a stable mount path and shared group permissions.

    In this setup, the Seagate drive is mounted at:

    ```bash
    /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    ```

    The drive is formatted as `ext4`, which is good because Linux ownership and permissions work normally.

    First, confirm the mount and filesystem type:

    ```bash
    ls -ld /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    df -T /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    ```

    If the drive is being used by both your desktop user and Nextcloud, set ownership to user `ben` and group `www-data`:

    ```bash
    sudo chown -R ben:www-data /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1
    ```

    Then give the owner and group write access:

    ```bash
    sudo find /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 -type d -exec chmod 2775 {} \;
    sudo find /mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1 -type f -exec chmod 664 {} \;
    ```

    Add `ben` to the `www-data` group so the desktop user and Nextcloud can both manage the same files:

    ```bash
    sudo usermod -aG www-data ben
    ```

    Then log out and log back in, or reboot, so the new group membership takes effect.

    The `2` in `2775` sets the setgid bit on directories. This helps new folders inherit the `www-data` group, reducing future permission conflicts between Nemo, the Nextcloud desktop client, and the Nextcloud server process.

    ---

    ### Phase 2: Check the Nextcloud external storage mount

    In the Nextcloud web interface, go to:

    **Profile icon → Administration settings → External storage**

    Edit the mount:

    ```text
    /Seagate Existing Files
    ```

    Confirm these settings:

    - **External storage:** Local

    - **Location:** `/mnt/usb-Seagate_Portable_NT3FC3M0-0:0-part1`

    - **Read only:** OFF

    - **Check filesystem changes:** Once every direct access

    - **Enable previews:** optional, currently OK

    - **Enable sharing:** optional; turn on only if this external storage needs to be shared through Nextcloud

    Click **Edit** to save.

    ---

    ### Phase 3: Test deletion in the correct order

    Test deletion from the Nextcloud web interface first. If deletion works in the web interface, the Android app should inherit the same permission behavior.

    Recommended test:

    1. Create a small temporary text file inside the Seagate external storage.

    2. Delete it from the Nextcloud web interface.

    3. Create another temporary file.

    4. Delete it from the Nextcloud Android app.

    If deletion works on the web but not Android, the issue is likely Android app cache/account state. If deletion fails on the web too, the problem is still server filesystem permissions.

    ---

    ### Phase 4: Rescan Nextcloud files after permission or direct filesystem changes

    After large file moves or permission fixes, rescan files so Nextcloud updates its file index:

    ```bash
    sudo nextcloud.occ files:scan --all
    ```

    Because this installation uses the Snap package, use `sudo nextcloud.occ` rather than the manual-install command `sudo -u www-data php /var/www/nextcloud/occ`.

    ---

    ### Practical rules for the office setup

    - Do not leave the drive owned only by `www-data:www-data`; that can make folders appear locked in Nemo for the desktop user.

    - Do not leave the drive owned only by `ben:ben` with `755` permissions; that lets Linux browse the files but can prevent Nextcloud from deleting or modifying them.

    - Preferred shared setup: `ben:www-data` ownership, directories `2775`, files `664`.

    - Avoid moving tens of thousands of files with Nemo while Nextcloud is actively scanning or syncing the same location.

    - After large file operations outside the web interface, run `sudo nextcloud.occ files:scan --all`.

    - The Android app does not have a separate delete-permission setting. It depends on the server-side storage permissions and share permissions.

- Recommended Configuration

    ## Recommended configuration

    ### A. If the Nextcloud sync folder is on an internal drive

    Use the built-in Nextcloud autostart option.

    1. Open the **Nextcloud** tray icon.

    2. Go to **Settings → General**.

    3. Enable **Launch on System Startup**.

    4. Confirm that a Linux keyring/password manager is available. On Linux Mint Cinnamon, this is usually GNOME Keyring.

    5. Reboot, log in, and verify that Nextcloud starts in the tray within 30–60 seconds.

    Verification commands:

    ```bash
    pgrep -a nextcloud
    ```

    ```bash
    grep -i launchOnSystemStartup ~/.config/Nextcloud/nextcloud.cfg
    ```

    A healthy setup should show the `nextcloud` process running and should show `launchOnSystemStartup=true` or an equivalent enabled state in the configuration file.

    ---

    ### B. If the Nextcloud sync folder is on an external drive

    Use a more reliable setup. The basic **Launch on System Startup** checkbox may start Nextcloud before the external drive is mounted. If that happens, Nextcloud may report sync-folder errors or treat the folder as missing.

    The better setup is:

    1. Mount the external drive at a stable path.

    2. Start Nextcloud only after that mount point is available.

    3. Avoid duplicate Nextcloud autostart entries.

    ---

    ## Step 1: Give the external drive a stable mount path

    Find the drive UUID and filesystem type:

    ```bash
    lsblk -f
    ```

    Create a stable mount point:

    ```bash
    sudo mkdir -p /mnt/Nextcloud_Library
    sudo chown $USER:$USER /mnt/Nextcloud_Library
    ```

    Open `/etc/fstab`:

    ```bash
    sudo nano /etc/fstab
    ```

    Add **one** line for the external drive. Replace `<UUID>` and `<filesystem>` with the values from `lsblk -f`.

    For an ext4 drive:

    ```text
    UUID=<UUID> /mnt/Nextcloud_Library ext4 defaults,nofail,x-systemd.automount 0 2
    ```

    For an NTFS drive, first check your user and group IDs:

    ```bash
    id -u
    id -g
    ```

    Then use those values in the `uid=` and `gid=` fields:

    ```text
    UUID=<UUID> /mnt/Nextcloud_Library ntfs3 rw,uid=1000,gid=1000,nofail,x-systemd.automount 0 0
    ```

    After editing `/etc/fstab`, reload and test:

    ```bash
    sudo systemctl daemon-reload
    sudo mount -a
    findmnt /mnt/Nextcloud_Library
    ```

    Do not continue until `findmnt` confirms that the drive is mounted at `/mnt/Nextcloud_Library`.

    ---

    ## Step 2: Make Nextcloud use the stable path

    In the Nextcloud desktop client, the local sync folder should be inside the stable mount path, for example:

    ```text
    /mnt/Nextcloud_Library
    ```

    If the current sync folder is still under a dynamic path such as `/media/ben/YourDriveName/Nextcloud_Library`, change it carefully:

    1. Pause syncing in the Nextcloud tray menu.

    2. Open **Settings**.

    3. Remove the current folder sync connection, but do **not** delete local files.

    4. Add a new folder sync connection using `/mnt/Nextcloud_Library`.

    5. Resume syncing after confirming the correct folder path.

    Avoid syncing a large library from a path that may change after reboot.

    ---

    ## Step 3: Create a wrapper that waits for the drive before starting Nextcloud

    Create a local scripts folder:

    ```bash
    mkdir -p ~/.local/bin
    ```

    Create the startup script:

    ```bash
    nano ~/.local/bin/start-nextcloud-after-mount.sh
    ```

    Paste this script:

    ```bash
    #!/usr/bin/env bash
    SYNC_ROOT="/mnt/Nextcloud_Library"
    SERVER_HOST="hub.benjaminlstewart.net"
    for i in {1..60}; do
      if mountpoint -q "$SYNC_ROOT" && ping -c 1 -W 1 "$SERVER_HOST" >/dev/null 2>&1; then
        exec nextcloud --background
      fi
      sleep 5
    done
    notify-send "Nextcloud not started" "The sync folder or network was unavailable after 5 minutes. Check /mnt/Nextcloud_Library and your network connection."
    ```

    Make it executable:

    ```bash
    chmod +x ~/.local/bin/start-nextcloud-after-mount.sh
    ```

    Test it manually:

    ```bash
    ~/.local/bin/start-nextcloud-after-mount.sh
    ```

    Then confirm that Nextcloud is running:

    ```bash
    pgrep -a nextcloud
    ```

    ---

    ## Step 4: Add the wrapper to Cinnamon Startup Applications

    To prevent duplicate Nextcloud instances, use **one** autostart method only.

    Recommended for an external-drive setup:

    1. Open the Nextcloud tray icon → **Settings → General**.

    2. Turn **off** the default **Launch on System Startup** option.

    3. Open the Linux Mint menu.

    4. Search for **Startup Applications**.

    5. Click **Add**.

    6. Use:

    ```text
    Name: Nextcloud after external drive mount
    Command: /home/ben/.local/bin/start-nextcloud-after-mount.sh
    Comment: Starts Nextcloud only after /mnt/Nextcloud_Library is mounted
    Startup delay: 15 seconds
    ```

    If the username is not `ben`, replace `/home/ben/` with the correct home folder path.

    Alternative command that works regardless of username:

    ```text
    sh -lc "$HOME/.local/bin/start-nextcloud-after-mount.sh"
    ```

    ---

    ## Step 5: Reboot test

    Reboot the computer:

    ```bash
    sudo reboot
    ```

    After logging back into Cinnamon, check:

    ```bash
    findmnt /mnt/Nextcloud_Library
    pgrep -a nextcloud
    ```

    Then check the tray icon:

    - Green checkmark = synchronized and connected.

    - Blue sync icon = synchronization is running.

    - Gray disconnected icon = network/server connection problem.

    - Red X or warning = configuration or sync-folder problem.

    Optional log check:

    ```bash
    ls ~/.config/Nextcloud/logs
    ```

    ```bash
    tail -n 80 ~/.config/Nextcloud/logs/*.log
    ```

    ---

    ## Practical rules for this setup

    - The desktop client starts **after user login**, not before login. This is normal for the GUI Nextcloud Desktop Client.

    - For continuous sync, keep the GUI desktop client running in the tray.

    - Do not use `nextcloudcmd` as the continuous sync solution.

    - Do not create multiple autostart entries for Nextcloud.

    - If the sync folder lives on an external drive, prefer a stable mount path such as `/mnt/Nextcloud_Library` instead of a changing `/media/...` path.

    - If Nextcloud asks for login again after every reboot, check that GNOME Keyring is installed and unlocked when you log into Cinnamon.

    ---

    ## Quick recovery commands

    Check whether the drive mounted:

    ```bash
    findmnt /mnt/Nextcloud_Library
    ```

    Check whether Nextcloud is running:

    ```bash
    pgrep -a nextcloud
    ```

    Start Nextcloud manually in the background:

    ```bash
    nextcloud --background
    ```

    Stop duplicate Nextcloud processes:

    ```bash
    pkill nextcloud
    ```

    Then restart using the wrapper:

    ```bash
    ~/.local/bin/start-nextcloud-after-mount.sh
    ```



- Recommendations for accessing NextCloud from Office.

    This is absolutely the safest and most resilient way to handle a massive library. By creating a true local mirror on your office machine, you guarantee that heavy multi-track audio for *The Learning Weaver* is sitting right on the disk ready for editing, while lightweight files like your UDL syllabi and textbook chapters sync seamlessly in the background.

    Since this completely replaces the need for third-party bridges like Insync, the Nextcloud Desktop Client will handle all the bidirectional mirroring natively.

    Here is the complete blueprint to build this robust local mirror on Linux Mint Cinnamon 22.3.

    ---

    ### Phase 1: Prepare the External Hard Drive

    Linux Mint dynamically mounts external drives when you click on them, but for a background sync client handling 1.5 TB of data, we need to ensure the target folder is completely prepped and owned by your user account before Nextcloud ever touches it.

    1. **Plug in the 2TB drive** and open your Nemo file manager to mount it.

    2. **Note the mount path:** It will typically be something like `/media/ben/YourDriveName`.

    3. **Create the master sync directory:** Open your terminal and create the dedicated folder:

    ```bash
    mkdir /media/ben/YourDriveName/Nextcloud_Library
    ```

    *(Make sure to replace* `YourDriveName` *with the actual name of your drive).*
    4. **Take absolute ownership:** Ensure your user account has full read/write permissions so the sync client doesn't hit a wall:

    ```bash
    sudo chown -R $USER:$USER /media/ben/YourDriveName/Nextcloud_Library
    ```

    ---

    ### Phase 2: Install the Nextcloud Desktop Client

    While Linux Mint has a version of the client in its standard repositories, adding the official Nextcloud PPA ensures you get the latest performance updates and native file manager integrations for Cinnamon.

    Run these commands in your terminal:

    ```bash
    sudo add-apt-repository ppa:nextcloud-devs/client -y
    sudo apt update
    sudo apt install nextcloud-desktop nemo-nextcloud -y
    ```

    *(The* `nemo-nextcloud` *package adds the green checkmarks and sync icons directly onto your files inside the file manager).*

    ---

    ### Phase 3: The "Trapdoor" Configuration (Crucial Step)

    This is the most important part of the setup. If you speed through the setup wizard, Nextcloud will attempt to dump all 1.5 TB of data directly into your local `~/Nextcloud` folder on your OS drive, immediately filling it up and crashing the system. We must reroute it to the external drive.

    1. **Launch the Client:** Open your Cinnamon menu and search for **Nextcloud**.

    2. **Log In:** Click **Log in** and enter your server address: `https://hub.benjaminlstewart.net`. This will open your Zen browser to authorize the connection.

    3. **Grant Access:** Once authorized, close the browser and return to the Nextcloud app window.

    4. **Reroute the Sync:**

    - You will see an option for **Local Folder**.

    - Click the folder path button (it usually defaults to `/home/ben/Nextcloud`).

    - Navigate to your external drive and select the `/media/ben/YourDriveName/Nextcloud_Library` folder you created in Phase 1.

    1. **Select Sync Options:** * Choose **Sync everything from server** if you want the entire 1.5 TB physically present on the external drive for offline access.

    - Alternatively, check **Use virtual files** if you only want to download files as you click on them, saving space on the external drive while still showing the full folder structure.

    1. **Connect:** Click **Connect**.

    The client will now begin pulling the data index and start quietly mirroring your library to the external drive.

    ---

    ### Phase 4: Autostart & Workflow Optimization

    To ensure your lesson plans and research formatting documents are always up-to-date when you arrive at the office, the client needs to run invisibly in the background.

    1. **Enable Autostart:**

    - Right-click the green Nextcloud icon in your Cinnamon system tray (bottom right of your screen) and select **Settings**.

    - Under the **General** tab, check the box for **Launch on System Startup**.

    1. **Handling Media vs. Text:**

    - **For Text/Documents:** Just open them directly from the `Nextcloud_Library` folder. When you hit save, the desktop client instantly detects the change and pushes it to the server.

    - **For Podcasting/Video:** You can edit these heavy files right on the external drive. The desktop client handles the upload asynchronously, meaning your editing software will never freeze or lock up waiting for a network transfer to complete.

    Since this background client relies on the external drive being present to function correctly, do you want to configure Linux Mint to automatically mount that specific drive at the exact same location every time the PC boots up via `fstab`, ensuring the Nextcloud client never gets confused?
