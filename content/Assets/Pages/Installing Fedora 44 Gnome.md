---
type: Page
title: Installing Fedora 44 Gnome
aliases:
description:
icon: 🏛️
createdAt: 2026-07-18T21:25:40.086Z
lastUpdated: 2026-08-23T00:34:14.477Z
tags:
  - Linux
coverImage: "[Untitled](../Images/Untitled%20(28).md)"
---

# Installing Fedora 44 Gnome

- Installing SyncThing on two PCs

    # Syncthing setup for two Fedora 44 GNOME PCs and two external drives

    This version assumes:

    - Both computers run Fedora 44 Workstation with GNOME.

    - Home folder: `/mnt/MyData/MyData_Home`

    - Office folder: `/mnt/MyData/MyData_Home`

    - The Home drive initially contains the authoritative copy.

    - After the first synchronization, both computers will use normal two-way synchronization.

    - Tailscale and SSH will let you finish the Home configuration remotely from the Office.

    Fedora 44 provides Syncthing directly in its repositories and includes both system and user service files. As of July 2026, Fedora 44 offers Syncthing 2.1.1. [Fedora Syncthing package](https://packages.fedoraproject.org/pkgs/syncthing/syncthing/fedora-44-updates.html)

    ## Part 1: Prepare the Home external drive

    ### 1. Confirm the drive’s current location

    Open Terminal and set the intended synchronization path:

    ```bash
    SYNC_FOLDER="/mnt/MyData/MyData_Home"
    ```

    Inspect the disks and mounts:

    ```bash
    lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
    ```

    Then check which filesystem contains the intended folder:

    ```bash
    findmnt -T "$SYNC_FOLDER" -o TARGET,SOURCE,FSTYPE,OPTIONS
    ```

    If the result shows:

    ```text
    TARGET
    /
    ```

    stop. The external drive is not mounted at that location, and `/mnt/MyData/MyData_Home` currently points to your internal drive.

    ### 2. Create a permanent mount

    Back up the current mount configuration:

    ```bash
    sudo cp /etc/fstab /etc/fstab.backup-before-syncthing
    ```

    Find the external partition’s UUID and filesystem:

    ```bash
    lsblk -f
    ```

    Create the mount point:

    ```bash
    sudo mkdir -p /mnt/MyData
    ```

    Install nano if necessary:

    ```bash
    sudo dnf install nano
    ```

    Edit `/etc/fstab`:

    ```bash
    sudo nano /etc/fstab
    ```

    Add only the line matching your drive’s filesystem.

    For Btrfs:

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData btrfs defaults,nofail,x-systemd.automount,x-systemd.device-timeout=15s 0 0
    ```

    For ext4:

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData ext4 defaults,nofail,x-systemd.automount,x-systemd.device-timeout=15s 0 2
    ```

    For NTFS, first determine your user and group IDs:

    ```bash
    id -u
    id -g
    ```

    Then use those numbers, commonly `1000`:

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData ntfs3 defaults,nofail,x-systemd.automount,uid=1000,gid=1000,umask=0022,x-systemd.device-timeout=15s 0 0
    ```

    For exFAT:

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData exfat defaults,nofail,x-systemd.automount,uid=1000,gid=1000,umask=0022,x-systemd.device-timeout=15s 0 0
    ```

    Save in nano:

    1. Press `Ctrl+O`.

    2. Press `Enter`.

    3. Press `Ctrl+X`.

    Reload and test:

    ```bash
    sudo systemctl daemon-reload
    sudo mount -a
    ls /mnt/MyData
    findmnt -T "$SYNC_FOLDER"
    ```

    Confirm that `SOURCE` is the external-drive partition—not the internal Fedora partition.

    ### 3. Create and test the folder

    Only continue after confirming the external drive is mounted correctly:

    ```bash
    sudo mkdir -p "$SYNC_FOLDER"
    ```

    For Btrfs or ext4:

    ```bash
    sudo chown "$USER":"$(id -gn)" "$SYNC_FOLDER"
    ```

    Test writing:

    ```bash
    touch "$SYNC_FOLDER/.syncthing-write-test"
    rm "$SYNC_FOLDER/.syncthing-write-test"
    ```

    If this fails on Btrfs or ext4, and everything inside this folder should belong to your account:

    ```bash
    sudo chown -R "$USER":"$(id -gn)" "$SYNC_FOLDER"
    ```

    Do not use recursive `chown` on NTFS or exFAT; ownership is controlled by the `/etc/fstab` options.

    ## Part 2: Install Syncthing on the Home PC

    ### 4. Install the Fedora package

    ```bash
    sudo dnf upgrade --refresh
    sudo dnf install syncthing
    ```

    Check it:

    ```bash
    syncthing --version
    dnf info syncthing
    ```

    Do not run:

    ```bash
    sudo syncthing
    ```

    Syncthing must operate under your normal user account.

    ### 5. Enable the unattended system service

    Because the Home PC must be available without a GNOME login:

    ```bash
    sudo systemctl enable --now "syncthing@${USER}.service"
    ```

    Check it:

    ```bash
    systemctl status "syncthing@${USER}.service"
    ```

    Press `q` to exit.

    Fedora’s package includes both `syncthing@.service` and the user-level `syncthing.service`; the system service is appropriate here because the Home PC must run unattended. [Syncthing automatic-start documentation](https://docs.syncthing.net/users/autostart.html)

    Once this service is enabled, do not separately launch “Start Syncthing” from the GNOME application menu. That could create a second competing Syncthing process.

    ### 6. Make Syncthing depend on the external drive

    Create a service override:

    ```bash
    sudo SYSTEMD_EDITOR=nano systemctl edit "syncthing@${USER}.service"
    ```

    Enter:

    ```text
    [Unit]
    RequiresMountsFor=/mnt/MyData/MyData_Home
    After=network-online.target
    Wants=network-online.target
    ```

    Save, then run:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart "syncthing@${USER}.service"
    systemctl status "syncthing@${USER}.service"
    ```

    This prevents Syncthing from starting normally if the required external-drive path cannot be mounted.

    ### 7. Allow Syncthing through Fedora’s firewall

    Check that firewalld is running:

    ```bash
    sudo firewall-cmd --state
    ```

    Allow Syncthing in Fedora’s default firewall zone:

    ```bash
    sudo firewall-cmd --permanent --add-service=syncthing
    sudo firewall-cmd --reload
    sudo firewall-cmd --list-services
    ```

    This opens:

    - TCP 22000

    - UDP 22000

    - UDP 21027

    Do not enable the `syncthing-gui` firewall service. The web interface should remain accessible only from the local computer or through the SSH tunnel. [Syncthing firewall documentation](https://docs.syncthing.net/users/firewall.html)

    ## Part 3: Configure Syncthing on the Home PC

    ### 8. Open the interface

    In Firefox, open:

    ```text
    http://127.0.0.1:8384
    ```

    ### 9. Secure the interface

    Go to:

    **Actions → Settings → GUI**

    Configure:

    - GUI Authentication User: your preferred username

    - GUI Authentication Password: a strong, unique password

    - GUI Listen Address: `127.0.0.1:8384`

    Save and sign in again.

    Do not change the GUI address to `0.0.0.0:8384`, and do not forward port 8384 through your router.

    ### 10. Name the Home device

    Go to:

    **Actions → Settings → General**

    Set:

    ```text
    Device Name: Home-PC
    ```

    ### 11. Remove the unused default folder

    If a folder called **Default Folder** appears:

    1. Expand it.

    2. Select **Edit**.

    3. Select **Remove**.

    4. Confirm.

    This removes it from Syncthing’s configuration; it does not delete your external-drive files.

    ### 12. Add the Home external folder

    Select **Add Folder**.

    Under General:

    ```text
    Folder Label: MyData Home
    Folder ID: mydata-home
    Folder Path: /mnt/MyData/MyData_Home
    ```

    The Folder ID must be identical on both computers.

    Initially set:

    ```text
    Folder Type: Send Only
    ```

    This protects the authoritative Home copy during the first synchronization.

    Under File Versioning, select:

    ```text
    Staggered File Versioning
    Maximum Age: 180 days
    ```

    Leave the versioning path blank so Syncthing uses `.stversions`.

    Under Advanced:

    - Btrfs or ext4: Ignore Permissions off

    - NTFS or exFAT: Ignore Permissions on

    Save and let Syncthing scan the folder. Do not delete the hidden `.stfolder` directory.

    ## Part 4: Prepare remote access to the Home PC

    ### 13. Install and enable OpenSSH

    ```bash
    sudo dnf install openssh-server
    sudo systemctl enable --now sshd
    systemctl status sshd
    ```

    Fedora calls the service `sshd`, not `ssh`.

    ### 14. Permit SSH tunneling

    Create a configuration file:

    ```bash
    sudo nano /etc/ssh/sshd_config.d/60-syncthing-remote.conf
    ```

    Enter:

    ```text
    PermitRootLogin no
    PasswordAuthentication yes
    AllowTcpForwarding yes
    ```

    Validate it:

    ```bash
    sudo sshd -t
    ```

    No output means the configuration passed validation. Restart SSH:

    ```bash
    sudo systemctl restart sshd
    ```

    Make sure your Fedora account has a strong password:

    ```bash
    passwd
    ```

    Do not forward port 22 through your router.

    ### 15. Install Tailscale

    Use Tailscale’s supported Linux installer:

    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    ```

    Enable the service:

    ```bash
    sudo systemctl enable --now tailscaled
    ```

    Connect the Home PC:

    ```bash
    sudo tailscale up
    ```

    Open the displayed login link and authenticate.

    Record the Home Tailscale IP:

    ```bash
    tailscale ip -4
    ```

    It will resemble:

    ```text
    100.85.42.17
    ```

    Also record your Fedora username:

    ```bash
    whoami
    ```

    Check the connection:

    ```bash
    tailscale status
    ```

    Tailscale provides a private route between the computers without conventional router port forwarding. [Tailscale Linux installation](https://tailscale.com/docs/install/linux)

    ### 16. Test SSH through Tailscale

    On the Home PC:

    ```bash
    ssh "$USER@$(tailscale ip -4 | head -n1)"
    ```

    Type `yes` if asked to trust the host, then enter your Fedora password.

    Test:

    ```bash
    hostname
    ```

    Exit:

    ```bash
    exit
    ```

    ### 17. Record the Home Syncthing Device ID

    In Syncthing, select:

    **Actions → Show ID**

    Save the full Home Device ID somewhere accessible from the Office.

    ### 18. Prevent GNOME from suspending the Home PC

    Open:

    **Settings → Power → Automatic Suspend**

    While plugged in, turn **Automatic Suspend** off.

    The display may turn off, but the computer itself must not suspend. If this is a laptop, leave the lid open during the initial synchronization unless you have separately configured Fedora not to suspend when the lid closes.

    ### 19. Reboot and verify the Home PC

    ```bash
    sudo reboot
    ```

    After Fedora restarts, check:

    ```bash
    findmnt -T /mnt/MyData/MyData_Home
    systemctl is-enabled "syncthing@${USER}.service"
    systemctl is-active "syncthing@${USER}.service"
    systemctl is-active sshd
    tailscale status
    ss -ltn | grep 8384
    ```

    Expected service results are:

    ```text
    enabled
    active
    active
    ```

    Port 8384 should show:

    ```text
    127.0.0.1:8384
    ```

    Create a Home test file:

    ```bash
    printf 'Created on Home PC: %s\n' "$(date -Is)" \
      > /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_HOME.txt
    ```

    Leave the Home PC and external drive powered on.

    ## Part 5: Configure the Office PC

    ### 20. Prepare the Office external drive

    Repeat Steps 1–3 on the Office PC.

    Use the Office disk’s own UUID in `/etc/fstab`, even though the mount path will be the same:

    ```text
    /mnt/MyData/MyData_Home
    ```

    Test writing:

    ```bash
    SYNC_FOLDER="/mnt/MyData/MyData_Home"
    touch "$SYNC_FOLDER/.office-write-test"
    rm "$SYNC_FOLDER/.office-write-test"
    ```

    Because Home is authoritative, the Office folder should ideally be empty before accepting the shared folder. Check:

    ```bash
    find "$SYNC_FOLDER" -mindepth 1 -maxdepth 1 -print
    ```

    If this displays existing files, stop and decide whether they should be backed up or moved aside before synchronization.

    ### 21. Install and start Syncthing

    ```bash
    sudo dnf upgrade --refresh
    sudo dnf install syncthing
    sudo systemctl enable --now "syncthing@${USER}.service"
    ```

    Add the drive dependency:

    ```bash
    sudo SYSTEMD_EDITOR=nano systemctl edit "syncthing@${USER}.service"
    ```

    Enter:

    ```text
    [Unit]
    RequiresMountsFor=/mnt/MyData/MyData_Home
    After=network-online.target
    Wants=network-online.target
    ```

    Apply it:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart "syncthing@${USER}.service"
    ```

    Open the Syncthing firewall service:

    ```bash
    sudo firewall-cmd --permanent --add-service=syncthing
    sudo firewall-cmd --reload
    ```

    ### 22. Configure the Office interface

    Open:

    ```text
    http://127.0.0.1:8384
    ```

    Configure:

    - GUI username and password

    - GUI listen address: `127.0.0.1:8384`

    - Device name: `Office-PC`

    Remove **Default Folder** if it exists.

    Do not add `MyData Home` manually yet. Let the Home PC offer the correctly identified folder.

    Record the Office Device ID from:

    **Actions → Show ID**

    ### 23. Install Tailscale on the Office PC

    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo systemctl enable --now tailscaled
    sudo tailscale up
    ```

    Authenticate using the same Tailscale account used on the Home PC.

    Check:

    ```bash
    tailscale status
    ```

    ## Part 6: Pair the computers remotely

    ### 24. Open the Home interface through an SSH tunnel

    On the Office PC, replace the username and IP:

    ```bash
    ssh -N -L 9999:127.0.0.1:8384 ben@HOME_TAILSCALE_IP
    ```

    For example:

    ```bash
    ssh -N -L 9999:127.0.0.1:8384 ben@100.85.42.17
    ```

    Leave that Terminal window open. The absence of a command prompt is normal.

    Open another Firefox tab and visit:

    ```text
    http://127.0.0.1:9999
    ```

    You are now securely viewing the Home Syncthing interface. SSH tunneling allows the GUI to remain bound to localhost. [Syncthing SSH-tunnel guidance](https://docs.syncthing.net/users/firewall.html#tunneling-via-ssh)

    ### 25. Add the Office device on the Home PC

    In the tunneled Home interface:

    1. Select **Add Remote Device**.

    2. Enter the Office Device ID.

    3. Set the device name to `Office-PC`.

    4. Under Sharing, select **MyData Home**.

    5. Save.

    ### 26. Accept the Home device at the Office

    Return to the normal Office interface:

    ```text
    http://127.0.0.1:8384
    ```

    A new-device notification should appear.

    1. Accept the Home device.

    2. Confirm that the displayed Device ID matches the Home ID you recorded.

    3. Name it `Home-PC`.

    4. Save.

    If no notification appears, select **Add Remote Device** and enter the Home Device ID manually.

    ### 27. Accept the shared folder

    The Office interface should now offer the folder `mydata-home`.

    Accept it using:

    ```text
    Folder Label: MyData Home
    Folder ID: mydata-home
    Folder Path: /mnt/MyData/MyData_Home
    Folder Type: Receive Only
    ```

    Enable Staggered File Versioning with a maximum age of 180 days.

    For permissions:

    - Btrfs or ext4: Ignore Permissions off

    - NTFS or exFAT: Ignore Permissions on

    Save.

    ## Part 7: Complete the initial synchronization

    ### 28. Wait for “Up to Date”

    Do not switch to two-way synchronization until:

    - Home reports the folder as **Up to Date**.

    - Office reports the folder as **Up to Date**.

    - `SYNCTHING_TEST_FROM_HOME.txt` appears on the Office drive.

    For a large folder, the initial scan and transfer may take many hours.

    ### 29. Switch both computers to two-way synchronization

    First, on the Home interface:

    **MyData Home → Edit → Folder Type → Send & Receive**

    Save.

    Then, on the Office interface:

    **MyData Home → Edit → Folder Type → Send & Receive**

    Save.

    ### 30. Test synchronization in both directions

    On the Office PC:

    ```bash
    printf 'Created on Office PC: %s\n' "$(date -Is)" \
      > /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_OFFICE.txt
    ```

    Wait for Syncthing to report **Up to Date**.

    Check the Home copy remotely:

    ```bash
    ssh ben@HOME_TAILSCALE_IP \
      'ls -l /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_OFFICE.txt'
    ```

    If the file appears, two-way synchronization is working.

    Keep in mind that Syncthing is synchronization, not a complete backup. A deletion can propagate to both computers, so continue keeping independent backups of important files.

- pCloud icon does not appear in panel (fix)

    GNOME does not show traditional tray icons by default. To place the **pCloud status icon in the top panel**, install Fedora’s AppIndicator extension.

    ### 1. Install AppIndicator support

    Open Terminal and run:

    ```bash
    sudo dnf install gnome-shell-extension-appindicator gnome-extensions-app
    ```

    Fedora 44 provides a compatible AppIndicator package specifically for displaying application indicators in the GNOME panel. (Fedora Packages)

    ### 2. Log out and back in

    Because Fedora GNOME normally uses Wayland, **log out completely**, then sign back in. A logout/login is required for newly installed GNOME Shell extensions under Wayland. (GitHub)

    ### 3. Enable the extension

    Run:

    ```bash
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
    ```

    Confirm that it is enabled:

    ```bash
    gnome-extensions info appindicatorsupport@rgcjonas.gmail.com
    ```

    You should see:

    ```text
    State: ENABLED
    ```

    Alternatively:

    1. Open **Extensions** from the applications menu.

    2. Find **AppIndicator and KStatusNotifierItem Support**.

    3. Turn it on.

    The extension supports both modern AppIndicators and legacy tray icons, which should cover pCloud’s Linux client. (GitHub)

    ### 4. Restart pCloud

    Close pCloud completely:

    ```bash
    pkill -f pcloud
    ```

    Then reopen **pCloud Drive** from the application menu. Its icon should appear in the **upper-right section of the GNOME top panel**.

    ### If the icon still does not appear

    Check that the extension is running:

    ```bash
    gnome-extensions list --enabled | grep appindicator
    ```

    Expected output:

    ```text
    appindicatorsupport@rgcjonas.gmail.com
    ```

    Then verify that pCloud is running:

    ```bash
    pgrep -af pcloud
    ```

    If by “panel” you mean the **bottom application dock** rather than the top status area, open pCloud, right-click its dock icon, and select **Pin to Dash**.

    [1]: https://packages.fedoraproject.org/pkgs/gnome-shell-extension-appindicator/gnome-shell-extension-appindicator "gnome-shell-extension-appindicator - Fedora Packages"

    [2]: https://github.com/ubuntu/gnome-shell-extension-appindicator "GitHub - ubuntu/gnome-shell-extension-appindicator: Adds KStatusNotifierItem support to the Shell · GitHub"

- Installing fonts

    The best approach is to install **Google fonts and Microsoft-compatible fonts from Fedora’s repositories**, then optionally add genuine Microsoft fonts. Apple’s bundled macOS fonts have licensing restrictions, so they should not normally be copied to Fedora.

    ## 1. Install Google and Microsoft-compatible fonts

    Run:

    ```bash
    sudo dnf install -y \
      liberation-fonts-all \
      google-carlito-fonts \
      google-crosextra-caladea-fonts \
      google-noto-sans-fonts \
      google-noto-serif-fonts \
      google-noto-color-emoji-fonts \
      google-roboto-fonts \
      google-roboto-mono-fonts
    ```

    This installs:

    - **Liberation Sans** as a replacement for Arial

    - **Liberation Serif** as a replacement for Times New Roman

    - **Liberation Mono** as a replacement for Courier New

    - **Carlito** as a metric-compatible replacement for Calibri

    - **Caladea** as a metric-compatible replacement for Cambria

    - Google’s **Noto Sans**, **Noto Serif**, **Noto Color Emoji**, **Roboto**, and **Roboto Mono**

    These packages are available for Fedora 44 through Fedora’s repositories. (Fedora Packages)

    Refresh the font cache:

    ```bash
    fc-cache -f -v
    ```

    ## 2. Install genuine Microsoft Core Fonts

    This installs older Microsoft fonts such as Arial, Times New Roman, Verdana, Georgia, Trebuchet MS, Comic Sans MS, Courier New, and Impact:

    ```bash
    sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    ```

    Then rebuild the cache:

    ```bash
    fc-cache -f -v
    ```

    The installer retrieves Microsoft’s classic Core Web Fonts; it does **not** normally include newer Office fonts such as Calibri, Cambria, Aptos, or Segoe UI. (Fedora Discussion)

    To check whether Arial was installed:

    ```bash
    fc-list : family | grep -i Arial
    ```

    ### Newer Microsoft fonts

    For Calibri, Cambria, Aptos, Segoe UI, and similar fonts, the safest Fedora option is to use Carlito and Caladea. Only manually copy genuine Microsoft font files when your Microsoft or Windows licence permits using them on another operating system.

    ## 3. Apple fonts

    Apple’s standard macOS licence generally authorizes bundled fonts for displaying and printing content while running Apple software. Therefore, copying macOS system fonts such as San Francisco, Helvetica Neue, New York, or Menlo into Fedora is not normally covered by that licence. (Apple Support Community)

    Recommended substitutes include:

    - **SF Pro / Helvetica Neue:** Inter, Noto Sans, Liberation Sans

    - **New York:** Noto Serif or Source Serif

    - **Menlo:** Roboto Mono or Liberation Mono

    You already installed several of these through the first command.

    ### Installing separately licensed font files

    For font files that you have legally purchased or downloaded with a licence permitting Linux use, place them in:

    ```text
    ~/.local/share/fonts/
    ```

    For example, assuming the files are inside `~/Downloads/AppleFonts`:

    ```bash
    mkdir -p ~/.local/share/fonts/Apple
    find ~/Downloads/AppleFonts -maxdepth 1 -type f \
      \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) \
      -exec cp -n {} ~/.local/share/fonts/Apple/ \;
    fc-cache -f -v
    ```

    Fedora recommends `~/.local/share/fonts` for fonts installed for one user and `/usr/local/share/fonts` for system-wide manually installed fonts. (Fedora Project Docs)

    ## 4. Verify the installation

    Run:

    ```bash
    fc-list : family |
    grep -Ei 'Arial|Times New Roman|Verdana|Carlito|Caladea|Roboto|Noto|Liberation' |
    sort -u
    ```

    Close and reopen LibreOffice, Firefox, Thunderbird, and other applications so they reload the updated font list.

    [1]: https://packages.fedoraproject.org/pkgs/liberation-fonts/?utm_source=chatgpt.com "liberation-fonts - Fedora Packages"

    [2]: https://discussion.fedoraproject.org/t/how-to-install-ms-fonts/156063?utm_source=chatgpt.com "How to install MS Fonts? - Fedora Discussion"

    [3]: https://discussions.apple.com/thread/251569527?utm_source=chatgpt.com "Font Licensing 101"

    [4]: https://docs.fedoraproject.org/en-US/quick-docs/fonts/?utm_source=chatgpt.com "Adding New Fonts in Fedora"

- Installing HP 1102w printer 

    Yes. For a **fresh Fedora 44 GNOME installation**, I recommend installing the HP LaserJet Professional **P1102w with HPLIP**, rather than letting GNOME create a generic driverless queue.

    Fedora 44 currently provides **HPLIP 3.26.4-7**, and the Fedora package specifically includes the P1102w PPD file:

    `hp-laserjet_professional_p_1102w.ppd.gz`

    The P1102w is officially supported by HPLIP over both **USB and network**, but HP marks it as requiring its proprietary binary plug-in. (Fedora Packages)

    I would set it up over **USB first**, confirm it prints, and then optionally add Wi-Fi printing.

    # Part 1 — Update Fedora

    Open Terminal and run:

    ```bash
    sudo dnf upgrade --refresh -y
    ```

    Reboot if Fedora installed substantial system or kernel updates:

    ```bash
    systemctl reboot
    ```

    ---

    # Part 2 — Install CUPS and HP software

    After reboot, install the printing packages:

    ```bash
    sudo dnf install -y \
    cups \
    cups-filters \
    hplip \
    hplip-gui \
    system-config-printer \
    usbutils
    ```

    Fedora 44's current HPLIP package is 3.26.4-7, and `hplip-gui` provides HP's graphical configuration utilities. (Fedora Packages)

    Check the installed version:

    ```bash
    rpm -q hplip hplip-gui
    ```

    You should see something similar to:

    ```text
    hplip-3.26.4-7.fc44.x86_64
    hplip-gui-3.26.4-7.fc44.x86_64
    ```

    ---

    # Part 3 — Enable CUPS

    Run:

    ```bash
    sudo systemctl enable --now cups
    ```

    Check it:

    ```bash
    systemctl status cups --no-pager
    ```

    You want to see:

    ```text
    Active: active (running)
    ```

    CUPS is Fedora's print spooler and handles the printer queues and print jobs. (Fedora Project)

    You can also confirm it responds with:

    ```bash
    lpstat -r
    ```

    Expected:

    ```text
    scheduler is running
    ```

    ---

    # Part 4 — Connect the P1102w by USB

    For the initial setup, I strongly recommend USB.

    1. Turn the P1102w **off**.

    2. Connect the USB cable directly to your Fedora PC.

    3. Avoid using a USB hub initially.

    4. Turn the printer on.

    5. Wait about 10 seconds.

    Now run:

    ```bash
    lsusb
    ```

    Look for an entry mentioning:

    ```text
    HP
    ```

    or:

    ```text
    Hewlett-Packard
    ```

    For a more focused check:

    ```bash
    lsusb | grep -i -E 'hp|hewlett'
    ```

    If it appears, Fedora sees the hardware.

    Also run:

    ```bash
    lpinfo -v | grep -Ei 'hp|usb'
    ```

    You may eventually see something resembling:

    ```text
    direct hp:/usb/HP_LaserJet_Professional_P1102w?serial=...
    ```

    The important part is:

    ```text
    hp:/usb/
    ```

    ---

    # Part 5 — Install the required HP proprietary plugin

    This step is particularly important for the **P1102w**.

    HP's HPLIP database explicitly lists the P1102w as requiring a driver plug-in. (HP Developers)

    Run:

    ```bash
    sudo hp-plugin -i
    ```

    You should get something similar to:

    ```text
    PLUG-IN INSTALLATION FOR HPLIP 3.26.4
    Option      Description
    d           Download plug-in from HP
    p           Specify a path to the plug-in
    q           Quit
    ```

    Enter:

    ```text
    d
    ```

    and press **Enter**.

    When asked whether you agree to HP's license, enter:

    ```text
    y
    ```

    Allow the installation to complete.

    Fedora's current HPLIP 3.26.4 package contains a specific 2026 fix for the location/user-agent used by the plug-in downloader, so Fedora 44 should be preferable to the older workarounds you may find online. (Fedora Packages)

    You ideally want to see:

    ```text
    Plug-in installation successful
    ```

    or equivalent.

    ---

    # Part 6 — Verify the plugin

    Run:

    ```bash
    hp-plugin -i
    ```

    If it reports that the correct version is already installed, quit with:

    ```text
    q
    ```

    You can also run:

    ```bash
    hp-check
    ```

    Don't be alarmed if `hp-check` produces some warnings about optional packages or desktop integration. What matters is that the printer, HPLIP and required plug-in are available.

    ---

    # Part 7 — Install the printer with HPLIP

    I recommend the terminal-based HPLIP setup rather than adding it through GNOME Settings initially.

    Run:

    ```bash
    sudo hp-setup -i
    ```

    You should see something like:

    ```text
    Choose connection type:
    0* usb
    1  net
    ```

    For USB, choose:

    ```text
    0
    ```

    and press **Enter**.

    HPLIP should search for the printer.

    You want it to identify something similar to:

    ```text
    HP LaserJet Professional P1102w
    ```

    When asked whether to use the recommended PPD/driver, answer:

    ```text
    y
    ```

    The Fedora package already contains the exact P1102w PPD at the HPLIP driver level. (Fedora Packages)

    ---

    # Part 8 — Give the printer a sensible queue name

    When HPLIP asks for a printer name, I recommend:

    ```text
    HP_P1102w
    ```

    For description:

    ```text
    HP LaserJet Professional P1102w
    ```

    For location you can use:

    ```text
    Home
    ```

    or simply leave it blank.

    If it asks whether this should be the default printer, answer:

    ```text
    y
    ```

    If offered a test page:

    ```text
    y
    ```

    The printer should now print.

    ---

    # Part 9 — Verify the CUPS printer queue

    Run:

    ```bash
    lpstat -t
    ```

    You should see information such as:

    ```text
    scheduler is running
    system default destination: HP_P1102w
    device for HP_P1102w: hp:/usb/HP_LaserJet_Professional_P1102w...
    HP_P1102w accepting requests
    printer HP_P1102w is idle
    ```

    The particularly important lines are:

    ```text
    HP_P1102w accepting requests
    ```

    and:

    ```text
    printer HP_P1102w is idle
    ```

    ---

    # Part 10 — Print a test page from Terminal

    Fedora/CUPS provides a standard test page.

    Run:

    ```bash
    lp -d HP_P1102w /usr/share/cups/data/testprint
    ```

    Then check the queue:

    ```bash
    lpstat -o
    ```

    If printing succeeds, the USB installation is complete.

    ---

    # Part 11 — Check it in GNOME

    Now open:

    **Settings → Printers**

    You should see:

    **HP LaserJet Professional P1102w**

    Click the printer and verify that it is:

    - Enabled

    - Ready

    - Using the correct HP driver

    - Set as default if desired

    At this point, I would **not add another copy of the printer** from GNOME Settings. You already created the correct HPLIP/CUPS queue.

    ---

    # Part 12 — Optional: Install HP Device Manager

    Because we installed `hplip-gui`, you can launch:

    ```bash
    hp-toolbox
    ```

    This opens the HP Device Manager.

    You can also search GNOME's application menu for something similar to:

    **HP Device Manager**

    For an old LaserJet like the P1102w, not every toolbox function will be available, but it's useful for checking the HPLIP connection.

    ---

    # Part 13 — Configure Wi-Fi

    The **P1102w** also supports network printing. HPLIP officially lists it as supporting both USB and network connections. (HP Developers)

    There are two situations.

    ## Situation A — P1102w is already connected to your Wi-Fi

    If the blue wireless light on the printer is **solid**, it is probably already connected.

    Find its IP address through your router's connected-device page.

    It might look something like:

    ```text
    192.168.1.73
    ```

    or:

    ```text
    192.168.0.115
    ```

    Test connectivity:

    ```bash
    ping -c 4 192.168.1.73
    ```

    Replace the example with the actual IP.

    Then ask HPLIP to discover network printers:

    ```bash
    hp-probe -bnet
    ```

    If the P1102w appears, configure it:

    ```bash
    sudo hp-setup -i
    ```

    This time choose:

    ```text
    1
    ```

    for:

    ```text
    net
    ```

    HPLIP should find the network printer.

    If automatic discovery doesn't work, you can provide its IP address during the HPLIP setup when prompted.

    ---

    # Part 14 — If the printer is NOT connected to Wi-Fi

    The easiest Linux-independent method is **WPS** if your router supports it.

    HP documents WPS connectivity for this model. (community.hp.com)

    On the P1102w:

    1. Turn the printer on.

    2. If it is asleep, wake it.

    3. Press and hold the **Wireless** button for approximately **3 seconds**.

    4. The blue wireless light should begin flashing.

    5. Within two minutes, press your router's **WPS** button.

    6. Wait.

    Once connected, the blue wireless light should become:

    **solid blue**

    instead of flashing. HP states that the printer searches for the WPS connection for approximately two minutes. (community.hp.com)

    Then find its IP through your router.

    ---

    # Part 15 — Test network detection from Fedora

    Once the printer is connected to Wi-Fi, run:

    ```bash
    hp-probe -bnet
    ```

    You can also try:

    ```bash
    lpinfo -v | grep -i hp
    ```

    and:

    ```bash
    avahi-browse -art | grep -i hp
    ```

    If `avahi-browse` isn't installed:

    ```bash
    sudo dnf install -y avahi-tools
    ```

    Then:

    ```bash
    avahi-browse -art | grep -i hp
    ```

    ---

    # Part 16 — Install the Wi-Fi queue

    Run:

    ```bash
    sudo hp-setup -i
    ```

    Select:

    ```text
    1
    ```

    for network.

    When it discovers:

    ```text
    HP LaserJet Professional P1102w
    ```

    select it.

    Again use the HP-recommended PPD.

    For the queue name, I suggest distinguishing it from USB:

    ```text
    HP_P1102w_WiFi
    ```

    That gives you:

    ```text
    HP_P1102w
    HP_P1102w_WiFi
    ```

    You can eventually remove the USB queue if you intend to print exclusively over Wi-Fi.

    ---

    # Part 17 — Make Wi-Fi the default

    List queues:

    ```bash
    lpstat -p -d
    ```

    Then:

    ```bash
    lpoptions -d HP_P1102w_WiFi
    ```

    Verify:

    ```bash
    lpstat -d
    ```

    It should say:

    ```text
    system default destination: HP_P1102w_WiFi
    ```

    ---

    # Part 18 — Test Wi-Fi printing

    Disconnect the USB cable.

    This is important because you want to prove the print job is going over Wi-Fi.

    Then:

    ```bash
    lp -d HP_P1102w_WiFi /usr/share/cups/data/testprint
    ```

    If that prints, your Wi-Fi configuration is working independently of USB.

    ---

    # Part 19 — I strongly recommend reserving the printer's IP

    Once network printing works, log into your router and find the printer.

    For example:

    ```text
    HP LaserJet Professional P1102w
    IP: 192.168.1.73
    MAC: xx:xx:xx:xx:xx:xx
    ```

    Create a **DHCP reservation** for it.

    For example:

    ```text
    HP P1102w → 192.168.1.73
    ```

    This prevents your router from assigning a different IP later and breaking a manually configured printer queue.

    ---

    # Troubleshooting 1 — Printer doesn't appear in `lsusb`

    Run:

    ```bash
    sudo journalctl -kf
    ```

    Then unplug the USB cable, reconnect it, and watch the output.

    Also run:

    ```bash
    lsusb
    ```

    Try another:

    - USB port

    - USB cable

    - Direct motherboard USB port rather than a hub

    ---

    # Troubleshooting 2 — `hp-plugin` fails

    First confirm your HPLIP version:

    ```bash
    rpm -q hplip
    ```

    It should currently be:

    ```text
    hplip-3.26.4-7.fc44
    ```

    Then refresh Fedora:

    ```bash
    sudo dnf upgrade --refresh
    ```

    and retry:

    ```bash
    sudo hp-plugin -i
    ```

    This is particularly relevant because Fedora's HPLIP 3.26.4 received a specific fix on **May 26, 2026** for plugin downloading. (Fedora Packages)

    Do **not** follow old tutorials telling you to download HPLIP 3.18, 3.19, 3.22, etc. Fedora 44 already has a considerably newer patched version.

    ---

    # Troubleshooting 3 — Printer is installed but nothing prints

    Check:

    ```bash
    lpstat -t
    ```

    Then:

    ```bash
    lpstat -o
    ```

    Restart CUPS:

    ```bash
    sudo systemctl restart cups
    ```

    Cancel stuck jobs:

    ```bash
    cancel -a
    ```

    Then try again:

    ```bash
    lp -d HP_P1102w /usr/share/cups/data/testprint
    ```

    ---

    # Troubleshooting 4 — Queue says stopped

    Check:

    ```bash
    lpstat -p
    ```

    If you get:

    ```text
    printer HP_P1102w disabled
    ```

    enable it:

    ```bash
    sudo cupsenable HP_P1102w
    ```

    and:

    ```bash
    sudo cupsaccept HP_P1102w
    ```

    Verify:

    ```bash
    lpstat -p
    ```

    ---

    # Troubleshooting 5 — Check CUPS logs

    Run:

    ```bash
    sudo journalctl -u cups -b --no-pager
    ```

    For recent errors only:

    ```bash
    sudo journalctl -u cups -b -p warning --no-pager
    ```

    You can also examine:

    ```bash
    sudo tail -100 /var/log/cups/error_log
    ```

    If the error log doesn't provide enough detail, temporarily enable CUPS debugging:

    ```bash
    sudo cupsctl --debug-logging
    sudo systemctl restart cups
    ```

    Print once, then inspect:

    ```bash
    sudo tail -200 /var/log/cups/error_log
    ```

    Turn verbose logging off afterward:

    ```bash
    sudo cupsctl --no-debug-logging
    sudo systemctl restart cups
    ```

    ---

    # Troubleshooting 6 — Check the exact HPLIP device

    Run:

    ```bash
    hp-probe -busb
    ```

    For network:

    ```bash
    hp-probe -bnet
    ```

    For detailed information:

    ```bash
    hp-info
    ```

    And HPLIP's diagnostic:

    ```bash
    hp-check
    ```

    ---

    # Troubleshooting 7 — Don't accidentally use a generic driver

    This is important for the P1102w.

    Run:

    ```bash
    lpstat -v
    ```

    If you installed it through HPLIP, you ideally want a URI beginning with:

    ```text
    hp:/
    ```

    For example:

    ```text
    hp:/usb/HP_LaserJet_Professional_P1102w?serial=...
    ```

    or an HPLIP network URI.

    The P1102w is an older model that specifically has an HPLIP driver and proprietary plugin requirement. I therefore prefer the **HPLIP queue** over a generic GNOME-created driverless queue for this printer. HP's own support matrix confirms the plug-in requirement. (HP Developers)

    # Recommended final configuration

    For your Fedora 44 machine, I would ultimately aim for:

    ```text
    Fedora 44
       │
       ├── CUPS
       │
       ├── HPLIP 3.26.4
       │     └── HP proprietary plugin
       │
       └── HP LaserJet Professional P1102w
              │
              └── Wi-Fi → reserved IP
    ```

    with:

    ```bash
    lpstat -t
    ```

    showing something like:

    ```text
    scheduler is running
    system default destination: HP_P1102w_WiFi
    printer HP_P1102w_WiFi is idle. enabled
    ```

    **For the first installation, I would specifically follow Parts 1–10 and get USB printing working before touching the wireless setup.** That isolates the driver/plugin setup from network issues and makes troubleshooting much easier.

    [1]: https://packages.fedoraproject.org/pkgs/hplip/hplip/fedora-44-updates.html?utm_source=chatgpt.com "hplip-3.26.4-7.fc44 - Fedora Packages"

    [2]: https://packages.fedoraproject.org/pkgs/hplip/hplip-gui/?utm_source=chatgpt.com "hplip-gui - Fedora Packages"

    [3]: https://www.fedoraproject.org/wiki/Printing?utm_source=chatgpt.com "Printing - Fedora Project Wiki"

    [4]: https://developers.hp.com/hp-linux-imaging-and-printing/supported_devices/index?pStoreID=bizclubgold%252525252525252525252F1000%252525252525252527%25252525252525255B0%25252525252525255D&utm_source=chatgpt.com "All Supported Printer Models | hp's Developer Portal"

    [5]: https://packages.fedoraproject.org/pkgs/hplip/hplip-gui/fedora-44-updates.html?utm_source=chatgpt.com "hplip-gui-3.26.4-7.fc44 - Fedora Packages"

    [6]: https://h30434.www3.hp.com/t5/Printer-Wireless-Networking-Internet/LASERJET-P1102W-STOPPED-WORKING-WIRELESSLY/m-p/7712055/highlight/true?utm_source=chatgpt.com "Solved: LASERJET P1102W STOPPED WORKING WIRELESSLY - HP Support Community - 7712055"

- Installing themes

    For a **fresh Fedora 44 Workstation install with GNOME 50**, I would install eight themes that are popular, visually distinct, and relatively easy to maintain from GitHub. Fedora 44 currently provides GNOME 50-series extension packages, including the User Themes extension needed to change the GNOME Shell itself. (Fedora Packages)

    My eight choices are:

    | Rank | Theme        | Style                | Fedora/GNOME 50 assessment   |
    | :--- | :----------- | :------------------- | :--------------------------- |
    | 1    | **MacTahoe** | macOS Tahoe          | ⭐ Excellent — GNOME 50 fixes |
    | 2    | **WhiteSur** | macOS / polished     | ⭐ Excellent — GNOME 50 fixes |
    | 3    | **Orchis**   | Material / rounded   | ⭐ Excellent — GNOME 50 fixes |
    | 4    | **Colloid**  | Modern GNOME / clean | Very good                    |
    | 5    | **Fluent**   | Windows 11 / Fluent  | Very good                    |
    | 6    | **Graphite** | Minimal / elegant    | Very good, with GTK4 caveat  |
    | 7    | **Qogir**    | Flat / modern        | Good                         |
    | 8    | **Matcha**   | Flat / colorful      | Good                         |

    MacTahoe, WhiteSur, and Orchis are especially attractive choices right now because their maintainers have specifically released GNOME 50 fixes in 2026. (GitHub)

    ### 1. Prepare Fedora

    First fully update the fresh installation:

    ```bash
    sudo dnf upgrade --refresh -y
    ```

    Then install GNOME Tweaks, GNOME Extensions, the User Themes extension, Git, and the common theme-building dependencies:

    ```bash
    sudo dnf install -y \
    git \
    gnome-tweaks \
    gnome-extensions-app \
    gnome-shell-extension-user-theme \
    sassc \
    glib2-devel \
    gtk-murrine-engine \
    gtk2-engines
    ```

    These packages are available for Fedora 44; `gnome-tweaks`, `sassc`, `gtk-murrine-engine`, and the User Themes extension are all provided in Fedora's repositories. (Fedora Packages)

    Create directories for the themes:

    ```bash
    mkdir -p ~/.themes
    mkdir -p ~/Themes
    ```

    Enable GNOME's **User Themes** extension:

    ```bash
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    ```

    I recommend **logging out and back in once at this point**, especially on a completely fresh Fedora installation.

    ---

    ## 2. MacTahoe

    This is currently my **#1 choice for Fedora 44**. It is a newer theme that reproduces the macOS Tahoe appearance. Its May 2026 release specifically fixed GNOME 50 issues, with additional updates in July and August. (GitHub)

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/MacTahoe-gtk-theme.git
    cd MacTahoe-gtk-theme
    ./install.sh -d "$HOME/.themes"
    ```

    Then return:

    ```bash
    cd ~/Themes
    ```

    ---

    ## 3. WhiteSur

    WhiteSur remains one of the most polished GNOME themes available. Its 2026 updates include GNOME 50/Nautilus fixes. (GitHub)

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
    cd WhiteSur-gtk-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    WhiteSur's installer supports light/dark variants, accent colors, opacity options, and GNOME Shell themes. (GitHub)

    ---

    ## 4. Orchis

    Orchis is one of the best choices if you want something modern without making Fedora look exactly like macOS or Windows.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git
    cd Orchis-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    Orchis received a July 2026 release specifically addressing GNOME 50 issues. (GitHub)

    It has excellent blue, purple, pink, red, orange, yellow, green, teal, and grey variants. (GitHub)

    ---

    ## 5. Colloid

    Colloid is probably my favorite if you want a **modern Linux/GNOME look instead of copying another OS**.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Colloid-gtk-theme.git
    cd Colloid-gtk-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    Colloid includes light/dark versions, compact versions, multiple accents, and even Nord, Dracula, Gruvbox, Everforest, and Catppuccin color schemes. (GitHub)

    ---

    ## 6. Fluent

    If you like the Windows 11 aesthetic, Fluent is the obvious choice.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git
    cd Fluent-gtk-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    It includes standard, compact, rounded, floating-panel and blur variants, and is designed specifically for GNOME/GTK desktops. (GitHub)

    ---

    ## 7. Graphite

    Graphite gives GNOME a much more restrained, sophisticated appearance.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Graphite-gtk-theme.git
    cd Graphite-gtk-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    It supports numerous accent colors, adjustable corner radius, and alternative GNOME Shell panel designs. (GitHub)

    There is one important GNOME 50 caveat: current reports indicate that its **optional Libadwaita/GTK4 override** can cause inconsistent Nautilus styling on GNOME 50.1. The normal GTK/Shell theme is much safer, which is why I am **not** telling you to install it with `-l`. (GitHub)

    ---

    ## 8. Qogir

    Qogir is a clean flat theme descended from Arc.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Qogir-theme.git
    cd Qogir-theme
    ./install.sh -d "$HOME/.themes"
    cd ~/Themes
    ```

    Qogir includes GTK, GNOME Shell, light/dark and rounded variants. Its installer also explicitly supports Fedora's `gtk-murrine-engine` dependencies. (GitHub)

    ---

    ## 9. Matcha

    Finally, Matcha gives you several attractive green, blue and other color combinations.

    ```bash
    git clone --depth=1 https://github.com/vinceliuice/Matcha-gtk-theme.git
    cd Matcha-gtk-theme
    ./install.sh -d "$HOME/.themes"
    cd ~
    ```

    Matcha contains GTK2, GTK3 and GNOME Shell components and includes several hue variants. (GitHub)

    Its most recent formal release targets GNOME 48 rather than GNOME 50, so I rank it below MacTahoe, WhiteSur and Orchis on Fedora 44. (GitHub)

    ---

    # 10. Select a theme

    Open:

    **Applications → Tweaks → Appearance**

    You should now see entries under **Legacy Applications** such as:

    ```text
    MacTahoe
    WhiteSur
    Orchis
    Colloid
    Fluent
    Graphite
    Qogir
    Matcha
    ```

    More importantly, you should now have a **Shell** selector.

    Select the corresponding theme under:

    **Tweaks → Appearance → Shell**

    If the Shell selector shows a warning or is disabled, open:

    **Applications → Extensions**

    and make sure:

    **User Themes → ON**

    Then log out and back in.

    ---

    # One important GNOME 50 issue

    Fedora 44 relies heavily on **GTK4 + Libadwaita**. GNOME intentionally does not provide the same conventional third-party theming mechanism for Libadwaita that exists for GTK3. WhiteSur itself documents that GTK4/Libadwaita theming requires replacing/linking files under `~/.config/gtk-4.0`. (GitHub)

    Consequently, at first I recommend **not using**:

    ```bash
    ./install.sh -l
    ```

    on any of the eight themes.

    Without `-l`:

    - GNOME Shell gets themed.

    - GTK3/legacy programs get themed.

    - Window elements get themed where supported.

    - Fedora's GTK4/Libadwaita programs remain closer to standard Adwaita.

    - You greatly reduce the chance of Files, Settings, Calculator, etc. looking broken.

    Once you choose your favorite theme, **then** we can apply its GNOME 50-compatible Libadwaita styling.

    ### My ranking for your fresh Fedora system

    I'd start with **MacTahoe → WhiteSur → Orchis → Colloid**. MacTahoe and WhiteSur give the most dramatic transformation; Orchis feels like a sophisticated customized GNOME desktop; and Colloid is the one I would choose if you want Fedora to remain recognizably Linux/GNOME while looking considerably more polished.

    If you want, I can next give you a **single copy-and-paste Fedora 44 script that installs all eight themes plus the best matching icon packs, cursors, Dash-to-Dock, Blur My Shell, and wallpapers**.

    [1]: https://packages.fedoraproject.org/pkgs/gnome-shell-extensions/gnome-shell-extension-user-theme/?utm_source=chatgpt.com "gnome-shell-extension-user-theme - Fedora Packages"

    [2]: https://github.com/vinceliuice/MacTahoe-gtk-theme/releases "Releases · vinceliuice/MacTahoe-gtk-theme · GitHub"

    [3]: https://packages.fedoraproject.org/pkgs/gnome-tweaks/gnome-tweaks/?utm_source=chatgpt.com "gnome-tweaks - Fedora Packages"

    [4]: https://github.com/vinceliuice/WhiteSur-gtk-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/WhiteSur-gtk-theme · GitHub"

    [5]: https://github.com/vinceliuice/WhiteSur-gtk-theme/blob/master/README.md?plain=1&utm_source=chatgpt.com "WhiteSur-gtk-theme/README.md at master · vinceliuice/WhiteSur-gtk-theme · GitHub"

    [6]: https://github.com/vinceliuice/Orchis-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/Orchis-theme · GitHub"

    [7]: https://github.com/vinceliuice/orchis-theme?utm_source=chatgpt.com "GitHub - vinceliuice/Orchis-theme: Orchis is a [Material Design](https://material.io) theme for GNOME/GTK based desktop environments. · GitHub"

    [8]: https://github.com/vinceliuice/Colloid-gtk-theme/blob/main/README.md?utm_source=chatgpt.com "Colloid-gtk-theme/README.md at main · vinceliuice/Colloid-gtk-theme · GitHub"

    [9]: https://github.com/vinceliuice/Fluent-gtk-theme?utm_source=chatgpt.com "GitHub - vinceliuice/Fluent-gtk-theme: Fluent design gtk theme for linux desktops · GitHub"

    [10]: https://github.com/vinceliuice/Graphite-gtk-theme?utm_source=chatgpt.com "GitHub - vinceliuice/Graphite-gtk-theme: Graphite gtk theme · GitHub"

    [11]: https://github.com/vinceliuice/Graphite-gtk-theme/issues/224?utm_source=chatgpt.com "GTK4/Libadwaita theme broken on GNOME Shell 50.1 - "Not a valid image" CSS parser error · Issue #224 · vinceliuice/Graphite-gtk-theme · GitHub"

    [12]: https://github.com/vinceliuice/Qogir-theme?utm_source=chatgpt.com "GitHub - vinceliuice/Qogir-theme: Qogir is a flat Design theme for GTK · GitHub"

    [13]: https://github.com/vinceliuice/Matcha-gtk-theme?utm_source=chatgpt.com "GitHub - vinceliuice/Matcha-gtk-theme: Matcha is a flat Design theme for GTK 3, GTK 2 and Gnome-Shell · GitHub"

    [14]: https://github.com/vinceliuice/Matcha-gtk-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/Matcha-gtk-theme · GitHub"

    [15]: https://github.com/vinceliuice/whitesur-gtk-theme?utm_source=chatgpt.com "GitHub - vinceliuice/WhiteSur-gtk-theme: MacOS like theme for all gtk based desktops · GitHub"

- Install Winboat and dependencies

    ## Recommended method: WinBoat RPM + Docker Engine

    Although Fedora includes Podman, I recommend **Docker Engine** for WinBoat because it offers the fullest compatibility, including WinBoat’s experimental USB passthrough. Do **not** install Docker Desktop; WinBoat explicitly states that Docker Desktop is unsupported. WinBoat remains beta software, so occasional troubleshooting may be necessary. (GitHub)

    WinBoat requires:

    - At least 4 GB RAM

    - At least two CPU threads

    - At least 32 GB free storage

    - Hardware virtualization/KVM

    - Docker Engine and Docker Compose v2

    - FreeRDP 3 with sound support (GitHub)

    ## 1. Update Fedora and install the basic dependencies

    Open Terminal and run:

    ```bash
    sudo dnf upgrade --refresh
    ```

    Then install FreeRDP and Fedora’s DNF repository-management plugin:

    ```bash
    sudo dnf install -y \
      dnf5-plugins \
      freerdp \
      curl
    ```

    Fedora 44 currently provides FreeRDP 3, including both the X11 `xfreerdp` and Wayland `wlfreerdp` clients. (Fedora Packages)

    Verify FreeRDP:

    ```bash
    command -v xfreerdp
    xfreerdp /version
    ```

    You should see a path similar to:

    ```text
    /usr/bin/xfreerdp
    ```

    and a version beginning with `3`.

    ## 2. Verify hardware virtualization

    Run:

    ```bash
    echo "Virtualization information:"
    lscpu | grep -i virtualization
    echo
    echo "KVM device:"
    ls -l /dev/kvm
    echo
    echo "KVM modules:"
    lsmod | grep '^kvm'
    ```

    A working Intel system normally shows:

    ```text
    kvm_intel
    kvm
    ```

    An AMD system normally shows:

    ```text
    kvm_amd
    kvm
    ```

    Fedora documentation recommends checking for `kvm_intel` or `kvm_amd` to confirm that the KVM modules are loaded. (Fedora Project Docs)

    If `/dev/kvm` is missing, reboot into your BIOS/UEFI and enable:

    - **Intel:** Intel Virtualization Technology, VT-x or VMX

    - **AMD:** SVM Mode or AMD-V

    After enabling it, boot Fedora and repeat the checks.

    You can also try loading the appropriate module manually.

    For Intel:

    ```bash
    sudo modprobe kvm
    sudo modprobe kvm_intel
    ```

    For AMD:

    ```bash
    sudo modprobe kvm
    sudo modprobe kvm_amd
    ```

    ## 3. Remove conflicting Docker compatibility packages

    Fedora may have Podman installed. Podman itself can remain installed, but the `podman-docker` compatibility package can interfere by redirecting the `docker` command to Podman.

    Run:

    ```bash
    rpm -q podman-docker >/dev/null 2>&1 && \
    sudo dnf remove -y podman-docker
    ```

    Remove any older or unofficial Docker packages:

    ```bash
    sudo dnf remove -y \
      docker \
      docker-client \
      docker-client-latest \
      docker-common \
      docker-latest \
      docker-latest-logrotate \
      docker-logrotate \
      docker-selinux \
      docker-engine-selinux \
      docker-engine
    ```

    It is normal for Fedora to report that some or all of these packages are not installed. Docker recommends removing these conflicting packages before installing Docker Engine from its official repository. (Docker Documentation)

    ## 4. Add Docker’s official Fedora repository

    Run:

    ```bash
    sudo dnf config-manager addrepo \
      --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
    ```

    Install Docker Engine, the command-line client, containerd and Compose v2:

    ```bash
    sudo dnf install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
    ```

    When asked to approve Docker’s signing key, verify that the fingerprint ends with:

    ```text
    C52F EB6B 621E 9F35
    ```

    These are Docker’s current official installation instructions for Fedora 44. (Docker Documentation)

    ## 5. Start Docker automatically

    Enable Docker now and at every boot:

    ```bash
    sudo systemctl enable --now docker
    ```

    Confirm that it is running:

    ```bash
    systemctl status docker --no-pager
    ```

    You should see:

    ```text
    Active: active (running)
    ```

    ## 6. Give your account access to Docker

    WinBoat must be able to use Docker without `sudo`. Add your account to the Docker group:

    ```bash
    sudo usermod -aG docker "$USER"
    ```

    Now **log out of Fedora completely and log back in**. Restarting the computer is also acceptable.

    Do not merely close Terminal: the GNOME desktop session must reload your group membership. Docker also warns that membership in the `docker` group effectively grants root-level privileges, so only trusted user accounts should belong to it. (Docker Documentation)

    After signing back in, verify membership:

    ```bash
    id -nG
    ```

    The output must include:

    ```text
    docker
    ```

    Test Docker without `sudo`:

    ```bash
    docker version
    docker compose version
    docker run --rm hello-world
    ```

    The final command should display a successful “Hello from Docker!” message.

    ## 7. Download the WinBoat Fedora RPM

    Open the official WinBoat download page and choose:

    **Download → Fedora → RPM**

    The latest upstream release currently listed is **WinBoat 0.9.0**. The project provides an RPM specifically for Fedora-based systems. (GitHub)

    After downloading it, use this command to locate and install the newest WinBoat RPM in your Downloads folder:

    ```bash
    RPM_FILE=$(
        find "$HOME/Downloads" \
          -maxdepth 1 \
          -type f \
          -iname '*winboat*.rpm' \
          -printf '%T@ %p\n' |
        sort -nr |
        head -n1 |
        cut -d' ' -f2-
    )
    if [ -n "$RPM_FILE" ]; then
        echo "Installing: $RPM_FILE"
        sudo dnf install -y "$RPM_FILE"
    else
        echo "No WinBoat RPM was found in $HOME/Downloads"
    fi
    ```

    Confirm installation:

    ```bash
    rpm -qa | grep -i winboat
    ```

    ## 8. Launch WinBoat

    Press the **Super** key, search for **WinBoat**, and open it.

    You can also try:

    ```bash
    winboat
    ```

    WinBoat’s prerequisite screen should now recognize:

    - KVM

    - Docker

    - Docker Compose v2

    - Docker group membership

    - Docker daemon

    - FreeRDP 3

    Do **not** run WinBoat with `sudo`.

    ## 9. Complete the initial Windows setup

    During WinBoat’s setup:

    1. Select **Docker** as the container runtime.

    2. Use the default installation folder:

    ```text
    /home/your-username/winboat
    ```

    For your account, that will probably be:

    ```text
    /home/ben/winboat
    ```

    1. Assign resources while leaving enough for Fedora.

    A reasonable example for a computer with 16 GB RAM is:

    ```text
    Windows RAM: 8 GB
    CPU cores: Half of available physical cores
    Disk: 64–128 GB
    ```

    1. Select the Windows version.

    2. Allow WinBoat to download and install Windows.

    3. Wait for Windows setup and the WinBoat Guest Server to complete.

    4. Open **Windows Desktop** from WinBoat.

    5. Install your Windows applications normally inside Windows.

    WinBoat does not provide a Windows licence. Its default Windows images use an unactivated installation, so you must provide your own valid product key to activate Windows. (WinBoat)

    ## Common Fedora problems

    ### Docker permission denied

    Check:

    ```bash
    id -nG
    ```

    If `docker` is missing, run:

    ```bash
    sudo usermod -aG docker "$USER"
    ```

    Then reboot Fedora.

    ### Docker reports that `iptables` is missing

    Run:

    ```bash
    sudo alternatives --set iptables /usr/bin/iptables-nft
    sudo systemctl restart docker
    ```

    Docker documents this Fedora-specific correction for Docker services that fail because they cannot locate the appropriate iptables implementation. (Docker Documentation)

    ### WinBoat does not detect FreeRDP

    Run:

    ```bash
    command -v xfreerdp
    command -v xfreerdp3
    command -v wlfreerdp
    rpm -q freerdp
    ```

    Then reinstall it:

    ```bash
    sudo dnf reinstall -y freerdp
    ```

    Fedora’s native `freerdp` package contains `xfreerdp`, which WinBoat’s current prerequisite detection supports. (Fedora Packages)

    ### Custom or external installation folder gives permission errors

    First install Windows using:

    ```text
    /home/ben/winboat
    ```

    This avoids external-drive ownership, mount-option and SELinux complications. Do not disable SELinux merely to make WinBoat work.

    ### Podman alternative

    WinBoat 0.9.0 also supports Podman:

    ```bash
    sudo dnf install -y podman podman-compose freerdp
    ```

    However, WinBoat’s USB passthrough is currently unavailable when using Podman, so Docker remains the more complete choice. (GitHub)

    [1]: https://github.com/TibixDev/winboat "GitHub - TibixDev/winboat: Run Windows apps on  Linux with ✨ seamless integration · GitHub"

    [2]: https://packages.fedoraproject.org/pkgs/freerdp/freerdp "freerdp - Fedora Packages"

    [3]: https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/?utm_source=chatgpt.com "Virtualization – Getting Started - Fedora Docs"

    [4]: https://docs.docker.com/engine/install/fedora/ "Install Docker Engine on Fedora | Docker Docs"

    [5]: https://docs.docker.com/engine/install/linux-postinstall "Linux post-installation steps for Docker Engine | Docker Docs"

    [6]: https://github.com/TibixDev/winboat/releases/tag/v0.9.0 "Release v0.9.0 · TibixDev/winboat · GitHub"

    [7]: https://winboat.app/ "WinBoat - Run Windows Apps on Linux with Seamless Integration"
