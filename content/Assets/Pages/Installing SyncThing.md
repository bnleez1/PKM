---
type: Page
collections: Public Pages
title: "Installing SyncThing "
aliases:
description:
icon: ✴️
createdAt: 2025-03-19T12:14:20.046Z
lastUpdated: 2026-07-22T14:54:46.641Z
tags:
  - Linux
coverImage: "[Untitled](../Images/Untitled%20(250).md)"
---

# Installing SyncThing 

- Chat instructions

    # Syncthing setup for two Siduction PCs and two external drives

    I am treating this as your intended arrangement:

    - **Home PC Syncthing folder:** `/mnt/MyData/MyData_Home`

    - **Office PC Syncthing folder:** `/mnt/MyData/MyData_Home`

    - The Home drive initially contains the authoritative files.

    - After the initial transfer, both locations should support normal two-way synchronization.

    The challenge is that Syncthing requires both devices to approve one another. The recommended solution is to prepare secure remote access to the Home PC through **Tailscale plus SSH**. You can then open the Home Syncthing interface securely from the Office PC without exposing Syncthing’s web interface to the public internet.

    Syncthing is available directly from Debian sid, so Siduction can use the Debian package rather than adding a third-party Syncthing repository. (Debian Packages)

    ---

    # Part 1: Prepare the external drive on the Home PC

    ## 1. Confirm where the external drive is mounted

    Open Konsole and set a variable for the folder:

    ```bash
    SYNC_FOLDER="/mnt/MyData/MyData_Home"
    ```

    Check which filesystem contains that folder:

    ```bash
    findmnt -T "$SYNC_FOLDER" -o TARGET,SOURCE,FSTYPE,OPTIONS
    ```

    Also run:

    ```bash
    lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
    ```

    You should see an external-drive partition associated with either:

    ```text
    /mnt/MyData
    ```

    or:

    ```text
    /mnt/MyData/MyData_Home
    ```

    ### Important warning

    If `findmnt` shows this:

    ```text
    TARGET
    /
    ```

    the external drive is **not mounted**. Your folder is currently pointing to the internal system drive. Do not configure Syncthing until the external drive is mounted correctly.

    ---

    ## 2. Give the drive a permanent mount location

    First back up your current mount configuration:

    ```bash
    sudo cp /etc/fstab /etc/fstab.backup-before-syncthing
    ```

    Identify the external drive’s UUID and filesystem using:

    ```bash
    lsblk -f
    ```

    Suppose the output looks similar to:

    ```text
    sda1  btrfs  MyData  12345678-abcd-1234-abcd-123456789abc
    ```

    Create the mount point:

    ```bash
    sudo mkdir -p /mnt/MyData
    ```

    Edit `/etc/fstab`:

    ```bash
    sudo nano /etc/fstab
    ```

    Add **one** appropriate line.

    ### For Btrfs

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData btrfs defaults,nofail,x-systemd.automount,x-systemd.device-timeout=15s 0 0
    ```

    ### For ext4

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData ext4 defaults,nofail,x-systemd.automount,x-systemd.device-timeout=15s 0 2
    ```

    ### For NTFS

    Determine your numeric user and group IDs:

    ```bash
    id -u
    id -g
    ```

    They will commonly both be `1000`. Then use:

    ```text
    UUID=YOUR-UUID-HERE /mnt/MyData ntfs3 defaults,nofail,x-systemd.automount,uid=1000,gid=1000,umask=0022,x-systemd.device-timeout=15s 0 0
    ```

    If your drive is mounted directly at `/mnt/MyData/MyData_Home`, substitute that full path for `/mnt/MyData`.

    Save in nano with:

    1. `Ctrl+O`

    2. Press `Enter`

    3. `Ctrl+X`

    Reload systemd and test the entry:

    ```bash
    sudo systemctl daemon-reload
    sudo mount -a
    ls /mnt/MyData
    findmnt -T "$SYNC_FOLDER"
    ```

    Using UUIDs gives the drive a stable mount point, while `x-systemd.automount` activates the mount when the path is accessed. Debian recommends reloading systemd after editing `/etc/fstab`. (Debian Manpages)

    ---

    ## 3. Create and test the synchronization folder

    Only do this after confirming that `/mnt/MyData` is the external drive:

    ```bash
    sudo mkdir -p "$SYNC_FOLDER"
    ```

    For Btrfs or ext4, give your account ownership of the top-level folder:

    ```bash
    sudo chown "$USER":"$(id -gn)" "$SYNC_FOLDER"
    ```

    Test writing:

    ```bash
    touch "$SYNC_FOLDER/.syncthing-write-test"
    rm "$SYNC_FOLDER/.syncthing-write-test"
    ```

    If the `touch` command works, permissions are suitable.

    If it fails on Btrfs or ext4 and all files on this drive are supposed to belong to your account, you can use:

    ```bash
    sudo chown -R "$USER":"$(id -gn)" "$SYNC_FOLDER"
    ```

    Do **not** use recursive `chown` casually on NTFS or exFAT. Ownership for those filesystems is normally controlled by the `/etc/fstab` mount options.

    ---

    # Part 2: Install Syncthing on the Home PC

    ## 4. Install the Debian package

    ```bash
    sudo apt update
    sudo apt install syncthing
    ```

    Check the installed version:

    ```bash
    syncthing --version
    apt policy syncthing
    ```

    Do not run Syncthing using `sudo syncthing`. It should run as your normal user so that its configuration and files belong to your account.

    ---

    ## 5. Enable Syncthing as a system service

    Because the Home PC must remain available even when you are not logged in, use Syncthing’s system service:

    ```bash
    sudo systemctl enable --now "syncthing@${USER}.service"
    ```

    Check it:

    ```bash
    systemctl status "syncthing@${USER}.service"
    ```

    Press `q` to exit the status display.

    Syncthing officially supports both user and system services. A system service starts at boot even when the user has no active graphical session, making it appropriate for an unattended Home PC. (Syncthing Documentation)

    ### If the service unit is not found

    Use the user-service alternative:

    ```bash
    systemctl --user enable --now syncthing.service
    sudo loginctl enable-linger "$USER"
    ```

    Check it with:

    ```bash
    systemctl --user status syncthing.service
    ```

    The lingering setting allows an enabled user service to run without requiring you to log in first. (Syncthing Documentation)

    ---

    ## 6. Make Syncthing depend on the external drive

    This prevents Syncthing from starting against an empty directory on your internal drive when the external drive is missing.

    Run:

    ```bash
    sudo systemctl edit "syncthing@${USER}.service"
    ```

    Paste:

    ```text
    [Unit]
    RequiresMountsFor=/mnt/MyData/MyData_Home
    After=network-online.target
    Wants=network-online.target
    ```

    Save and exit. Then run:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart "syncthing@${USER}.service"
    ```

    Verify:

    ```bash
    systemctl status "syncthing@${USER}.service"
    ```

    `RequiresMountsFor=` causes systemd to add the required mount dependencies for the specified path. If the external disk is unavailable, Syncthing should fail rather than synchronize against the wrong storage location. (Debian Manpages)

    ---

    # Part 3: Configure Syncthing on the Home PC

    ## 7. Open the Syncthing interface

    Open Firefox and enter:

    ```text
    http://127.0.0.1:8384
    ```

    Syncthing normally keeps its interface available only on localhost, which is the safer setting. (Syncthing Documentation)

    ---

    ## 8. Secure the web interface

    Select:

    **Actions → Settings → GUI**

    Configure:

    - **GUI Authentication User:** your preferred username

    - **GUI Authentication Password:** a strong, unique password

    - **GUI Listen Address:** leave as `127.0.0.1:8384`

    Save and sign in again.

    Do not change the address to `0.0.0.0:8384`, and do not forward port 8384 through your router. We will access it through an SSH tunnel instead. Syncthing specifically documents SSH tunneling as a way to reach the GUI while leaving it bound to localhost. (Syncthing Documentation)

    ---

    ## 9. Name the Home device

    Go to:

    **Actions → Settings → General**

    Set:

    ```text
    Device Name: Home-PC
    ```

    Save.

    ---

    ## 10. Remove the unused default folder

    Syncthing may have created a folder named **Default Folder**, usually pointing to `~/Sync`.

    If you are not using it:

    1. Expand **Default Folder**.

    2. Select **Edit**.

    3. Select **Remove**.

    4. Confirm removal.

    This removes the folder from Syncthing’s configuration. It should not be confused with deleting your external-drive files.

    ---

    ## 11. Add the external-drive folder

    Select **Add Folder** and enter:

    ### General tab

    ```text
    Folder Label: MyData Home
    Folder ID: mydata-home
    Folder Path: /mnt/MyData/MyData_Home
    ```

    The **Folder ID** is especially important. It must be the same on both devices.

    ### Folder Type

    For the initial setup, choose:

    ```text
    Send Only
    ```

    This makes the Home PC the reference copy while the initial synchronization is completed. A Send Only folder does not apply changes received from another device, which reduces the risk of an Office-side mistake changing the Home copy during setup. (Syncthing Documentation)

    ### File Versioning

    Select:

    ```text
    Staggered File Versioning
    ```

    A reasonable maximum age is:

    ```text
    180 days
    ```

    Leave the versions path blank so Syncthing uses:

    ```text
    .stversions
    ```

    Versioning archives files replaced or deleted because of changes received from another device. It does not preserve a file that you modify locally on the same computer, so it is protection against some synchronization mistakes—not a complete backup system. (Syncthing Documentation)

    ### Advanced settings

    For Btrfs or ext4:

    ```text
    Ignore Permissions: Off
    ```

    For NTFS or exFAT:

    ```text
    Ignore Permissions: On
    ```

    Save the folder and allow Syncthing to begin scanning it.

    Do not delete the hidden `.stfolder` directory that Syncthing creates.

    ---

    # Part 4: Prepare secure remote access to the Home PC

    This is the part that lets you finish the setup from the Office without returning home.

    ## 12. Install OpenSSH on the Home PC

    ```bash
    sudo apt install openssh-server
    sudo systemctl enable --now ssh
    ```

    Confirm that it is running:

    ```bash
    systemctl status ssh
    ```

    Press `q` to exit.

    ---

    ## 13. Permit SSH tunneling

    Create a small SSH configuration file:

    ```bash
    sudo nano /etc/ssh/sshd_config.d/60-syncthing-remote.conf
    ```

    Enter:

    ```text
    PermitRootLogin no
    PasswordAuthentication yes
    AllowTcpForwarding yes
    ```

    Save and validate the configuration:

    ```bash
    sudo sshd -t
    ```

    If that command produces no output, restart SSH:

    ```bash
    sudo systemctl restart ssh
    ```

    Use a strong password for your Siduction account:

    ```bash
    passwd
    ```

    Do not configure router port forwarding for port 22. SSH will be reached through Tailscale’s private network.

    ---

    ## 14. Install Tailscale on the Home PC

    Install curl if necessary:

    ```bash
    sudo apt install curl
    ```

    Install Tailscale:

    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    ```

    Connect the Home PC:

    ```bash
    sudo tailscale up
    ```

    A login address will appear. Open it in your browser and authenticate with Google, Microsoft, GitHub, Apple, or another offered identity provider.

    Tailscale officially supports Debian-based distributions through this installer. Each connected device receives a private Tailscale address. (Tailscale)

    Display the Home PC’s Tailscale address:

    ```bash
    tailscale ip -4
    ```

    It will look similar to:

    ```text
    100.85.42.17
    ```

    Record this address in a safe place as:

    ```text
    HOME_TAILSCALE_IP=100.85.42.17
    ```

    Also record your Linux username:

    ```bash
    whoami
    ```

    For you, this will probably be:

    ```text
    ben
    ```

    Check Tailscale:

    ```bash
    tailscale status
    ```

    Tailscale connects devices across different networks and NAT without needing conventional router port forwarding. (Tailscale)

    ---

    ## 15. Test SSH access through Tailscale

    On the Home PC, try connecting to its own Tailscale address:

    ```bash
    ssh "$USER@$(tailscale ip -4 | head -n1)"
    ```

    The first time, type:

    ```text
    yes
    ```

    Enter your normal Siduction password.

    Once connected, run:

    ```bash
    hostname
    ```

    Then exit:

    ```bash
    exit
    ```

    If that succeeds, your remote SSH route is prepared.

    ---

    ## 16. Record the Home Syncthing Device ID

    In the Home Syncthing interface select:

    **Actions → Show ID**

    Copy the full device ID and save it somewhere you can access at the Office.

    It will resemble:

    ```text
    AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH
    ```

    Device IDs do not have to be secret, but you should verify them when accepting a device. Syncthing requires both devices to configure each other’s device ID before they connect. (Syncthing Documentation)

    ---

    ## 17. Prevent the Home PC from sleeping

    In KDE Plasma open:

    **System Settings → Power Management**

    While connected to AC power, configure:

    - Turn off screen: permitted

    - Automatically sleep or suspend: **Never**

    - Power button behavior: your preference

    - Lid close behavior, for a laptop: **Do nothing** while plugged in

    The Home PC, external drive, router and internet connection must remain powered on during the Office setup and initial synchronization.

    ---

    ## 18. Reboot and perform the final Home check

    Reboot:

    ```bash
    sudo reboot
    ```

    After the machine restarts, check:

    ```bash
    findmnt -T /mnt/MyData/MyData_Home
    systemctl is-enabled "syncthing@${USER}.service"
    systemctl is-active "syncthing@${USER}.service"
    systemctl is-active ssh
    tailscale status
    ```

    Expected results include:

    ```text
    enabled
    active
    active
    ```

    Confirm that Syncthing is listening locally:

    ```bash
    ss -ltn | grep 8384
    ```

    You should see `127.0.0.1:8384`.

    Create a test file in the Home folder:

    ```bash
    printf 'Created on Home PC: %s\n' "$(date -Is)" \
      > /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_HOME.txt
    ```

    At this stage, leave the Home PC powered on.

    ---

    # Part 5: Set up the Office PC

    ## 19. Prepare the Office external drive

    On the Office PC, repeat the drive-identification process:

    ```bash
    SYNC_FOLDER="/mnt/MyData/MyData_Home"
    lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
    findmnt -T "$SYNC_FOLDER" -o TARGET,SOURCE,FSTYPE,OPTIONS
    ```

    Configure the Office drive in its own `/etc/fstab` using that drive’s UUID.

    Even though the mount path is the same, the Office disk will almost certainly have a different UUID.

    After configuring it:

    ```bash
    sudo systemctl daemon-reload
    sudo mount -a
    ls /mnt/MyData
    findmnt -T "$SYNC_FOLDER"
    ```

    Create the folder if necessary:

    ```bash
    sudo mkdir -p "$SYNC_FOLDER"
    ```

    For Btrfs or ext4:

    ```bash
    sudo chown "$USER":"$(id -gn)" "$SYNC_FOLDER"
    ```

    Test writing:

    ```bash
    touch "$SYNC_FOLDER/.office-write-test"
    rm "$SYNC_FOLDER/.office-write-test"
    ```

    ---

    ## 20. Install and start Syncthing on the Office PC

    ```bash
    sudo apt update
    sudo apt install syncthing
    sudo systemctl enable --now "syncthing@${USER}.service"
    ```

    Add the external-drive dependency:

    ```bash
    sudo systemctl edit "syncthing@${USER}.service"
    ```

    Paste:

    ```text
    [Unit]
    RequiresMountsFor=/mnt/MyData/MyData_Home
    After=network-online.target
    Wants=network-online.target
    ```

    Then run:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart "syncthing@${USER}.service"
    ```

    Check:

    ```bash
    systemctl status "syncthing@${USER}.service"
    ```

    ---

    ## 21. Configure the Office Syncthing interface

    Open:

    ```text
    http://127.0.0.1:8384
    ```

    Configure:

    - GUI username and password

    - GUI listen address remains `127.0.0.1:8384`

    - Device name: `Office-PC`

    Remove the unused **Default Folder**.

    Do not add the external folder manually yet. The Home PC will offer the correctly identified folder after the two devices are paired.

    ---

    ## 22. Install Tailscale on the Office PC

    ```bash
    sudo apt install curl openssh-client
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up
    ```

    Authenticate using the **same Tailscale account** used on the Home PC.

    Check:

    ```bash
    tailscale status
    tailscale ip -4
    ```

    Record the Office Tailscale IP:

    ```text
    OFFICE_TAILSCALE_IP=100.x.y.z
    ```

    Test the connection to Home:

    ```bash
    tailscale ping HOME_TAILSCALE_IP
    ```

    Replace `HOME_TAILSCALE_IP` with the actual `100.x.y.z` address you recorded.

    ---

    # Part 6: Open the Home Syncthing interface remotely

    ## 23. Create the secure SSH tunnel

    On the Office PC, open a new terminal and run:

    ```bash
    ssh -N \
      -o ServerAliveInterval=30 \
      -L 8385:127.0.0.1:8384 \
      ben@HOME_TAILSCALE_IP
    ```

    Replace:

    - `ben` with the Home PC’s username

    - `HOME_TAILSCALE_IP` with the Home Tailscale address

    Example:

    ```bash
    ssh -N \
      -o ServerAliveInterval=30 \
      -L 8385:127.0.0.1:8384 \
      ben@100.85.42.17
    ```

    Enter the Home PC’s Siduction password.

    The terminal will appear to do nothing. That is normal. Leave it open.

    Syncthing’s official firewall documentation recommends this kind of SSH tunnel when you want remote GUI access without opening the GUI port to outside networks. (Syncthing Documentation)

    ---

    ## 24. Open both Syncthing interfaces at the Office

    You now have two different browser addresses:

    ### Office PC Syncthing

    ```text
    http://127.0.0.1:8384
    ```

    ### Home PC Syncthing through the SSH tunnel

    ```text
    http://127.0.0.1:8385
    ```

    The second address displays the Home PC interface even though you are physically at the Office.

    Sign in using the Home Syncthing GUI username and password.

    ---

    # Part 7: Connect the two Syncthing devices

    ## 25. Obtain the Office Device ID

    In the Office interface at port 8384, select:

    **Actions → Show ID**

    Copy the Office Device ID.

    ---

    ## 26. Add the Office PC to the Home PC

    In the tunneled Home interface at port 8385:

    1. Select **Add Remote Device**.

    2. Paste the Office Device ID.

    3. Set the name to:

    ```text
    Office-PC
    ```

    1. Under **Sharing**, select:

    ```text
    MyData Home
    ```

    1. Save.

    Syncthing requires mutual approval: both devices must contain the other device’s ID before the connection is fully established. (Syncthing Documentation)

    ---

    ## 27. Approve the Home PC on the Office PC

    Return to the Office interface at:

    ```text
    http://127.0.0.1:8384
    ```

    A notification should appear indicating that a new device wants to connect.

    1. Select **Add Device**.

    2. Verify that the displayed ID matches the Home Device ID you recorded.

    3. Set the name to:

    ```text
    Home-PC
    ```

    1. Save.

    If no notification appears after a minute or two, manually select **Add Remote Device** and paste the Home Device ID.

    ---

    ## 28. Accept the shared folder on the Office PC

    The Office interface should show a notification that Home is sharing the folder `mydata-home`.

    Select **Add** or **Accept**.

    Configure:

    ```text
    Folder Label: MyData Home
    Folder ID: mydata-home
    Folder Path: /mnt/MyData/MyData_Home
    Folder Type: Receive Only
    ```

    For versioning, select:

    ```text
    Staggered File Versioning
    Maximum Age: 180 days
    ```

    For ext4 or Btrfs, leave **Ignore Permissions** off. For NTFS or exFAT, enable it.

    Save.

    A Receive Only folder accepts cluster changes but does not send local Office changes back to Home. This is useful during the first replication because it temporarily treats the Office disk as a destination copy. (Syncthing Documentation)

    ---

    # Part 8: Prefer direct synchronization through Tailscale

    Syncthing can discover and relay connections automatically. However, because both computers now have stable Tailscale addresses, you can explicitly add those addresses.

    ## 29. Configure the Home address on the Office PC

    In the Office Syncthing interface:

    1. Expand **Home-PC**.

    2. Select **Edit**.

    3. Open **Advanced**.

    4. Change **Addresses** to:

    ```text
    tcp://HOME_TAILSCALE_IP:22000, dynamic
    ```

    Example:

    ```text
    tcp://100.85.42.17:22000, dynamic
    ```

    Save.

    ## 30. Configure the Office address on the Home PC

    In the tunneled Home interface:

    1. Expand **Office-PC**.

    2. Select **Edit**.

    3. Open **Advanced**.

    4. Change **Addresses** to:

    ```text
    tcp://OFFICE_TAILSCALE_IP:22000, dynamic
    ```

    Save.

    Syncthing supports combining a specific address with `dynamic`, allowing it to try the specified connection while retaining automatic discovery as a fallback. (Syncthing Documentation)

    ---

    ## 31. Firewall check

    Check whether UFW is active:

    ```bash
    sudo ufw status
    ```

    If the result is:

    ```text
    Status: inactive
    ```

    do nothing.

    If UFW is active, allow Syncthing specifically on the private Tailscale interface on **both PCs**:

    ```bash
    sudo ufw allow in on tailscale0 to any port 22000 proto tcp
    sudo ufw allow in on tailscale0 to any port 22000 proto udp
    ```

    Do not open port 8384.

    Syncthing uses TCP 22000 and UDP 22000 for synchronization; UDP 21027 is used for local-network discovery. (Syncthing Documentation)

    ---

    # Part 9: Complete and verify the first synchronization

    ## 32. Allow the initial scan and transfer to complete

    During the first synchronization:

    - Home should show **Send Only**.

    - Office should show **Receive Only**.

    - Both devices should show **Connected**.

    - The folder may show **Scanning**, **Syncing** or **Up to Date**.

    - The file `SYNCTHING_TEST_FROM_HOME.txt` should appear on the Office drive.

    Check at the Office:

    ```bash
    ls -l /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_HOME.txt
    cat /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_HOME.txt
    ```

    Do not click **Override Changes** on Home or **Revert Local Changes** on Office during the first transfer unless you fully understand what it will do. The Home **Override Changes** option can enforce Home’s state across the cluster, including deleting files that do not exist on Home. (Syncthing Documentation)

    ---

    ## 33. Compare basic folder information

    On the Office PC:

    ```bash
    du -sh /mnt/MyData/MyData_Home
    find /mnt/MyData/MyData_Home -type f | wc -l
    ```

    To check Home remotely:

    ```bash
    ssh ben@HOME_TAILSCALE_IP \
      'du -sh /mnt/MyData/MyData_Home; find /mnt/MyData/MyData_Home -type f | wc -l'
    ```

    The results may not be perfectly identical if `.stversions`, temporary files or filesystem metadata differ, so the Syncthing interface’s **Up to Date** status is the more important indication.

    ---

    # Part 10: Change to normal two-way synchronization

    Once the initial synchronization has completed and the Office files look correct:

    ## 34. Change Home to Send & Receive

    In the tunneled Home interface:

    1. Expand **MyData Home**.

    2. Select **Edit**.

    3. Change **Folder Type** to:

    ```text
    Send & Receive
    ```

    1. Save.

    ## 35. Change Office to Send & Receive

    In the Office interface:

    1. Expand **MyData Home**.

    2. Select **Edit**.

    3. Change **Folder Type** to:

    ```text
    Send & Receive
    ```

    1. Save.

    Send & Receive is Syncthing’s normal two-way mode: each device sends and applies changes. (Syncthing Documentation)

    ---

    ## 36. Test Office-to-Home synchronization

    On the Office PC:

    ```bash
    printf 'Created on Office PC: %s\n' "$(date -Is)" \
      > /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_OFFICE.txt
    ```

    Wait until the Office interface says **Up to Date**.

    Check remotely on Home:

    ```bash
    ssh ben@HOME_TAILSCALE_IP \
      'cat /mnt/MyData/MyData_Home/SYNCTHING_TEST_FROM_OFFICE.txt'
    ```

    If the contents appear, two-way synchronization is working.

    ---

    # Regular operation

    ## Starting and stopping Syncthing

    Check:

    ```bash
    systemctl status "syncthing@${USER}.service"
    ```

    Stop:

    ```bash
    sudo systemctl stop "syncthing@${USER}.service"
    ```

    Start:

    ```bash
    sudo systemctl start "syncthing@${USER}.service"
    ```

    Restart:

    ```bash
    sudo systemctl restart "syncthing@${USER}.service"
    ```

    View recent logs:

    ```bash
    journalctl -u "syncthing@${USER}.service" -n 100 --no-pager
    ```

    Follow logs live:

    ```bash
    journalctl -fu "syncthing@${USER}.service"
    ```

    ---

    # Safely disconnecting an external drive

    Before unplugging a drive:

    ```bash
    sudo systemctl stop "syncthing@${USER}.service"
    ```

    Then unmount the actual mount point, probably:

    ```bash
    sudo umount /mnt/MyData
    ```

    After reconnecting the drive:

    ```bash
    ls /mnt/MyData
    sudo systemctl start "syncthing@${USER}.service"
    ```

    Confirm:

    ```bash
    findmnt -T /mnt/MyData/MyData_Home
    systemctl status "syncthing@${USER}.service"
    ```

    ---

    # Important safety rules

    1. **Syncthing is not a backup.** Once both devices use Send & Receive, a deletion on one PC is normally replicated to the other. Versioning offers limited recovery for remotely received changes but is not a substitute for a separate backup. (Syncthing Documentation)

    2. **Do not synchronize the same exact folder simultaneously with pCloud or another bidirectional synchronization application.** Overlapping synchronization systems can create conflicts, repeated renaming or deletion loops.

    3. **Do not delete** `.stfolder`**.** If Syncthing reports “folder marker missing,” first confirm that the correct external drive is mounted.

    4. **Do not open port 8384 on your router.** Continue using the SSH tunnel for remote Home administration.

    5. **Keep both PCs online for synchronization.** Syncthing exchanges files directly between your devices rather than storing the primary data in a cloud account. (Debian Packages)

    6. **Keep the Home PC awake.** Screen blanking is fine, but suspend or hibernation stops synchronization and remote access.

    ---

    # Compact Office checklist

    When you arrive at the Office:

    1. Mount the Office external drive at `/mnt/MyData`.

    2. Confirm `/mnt/MyData/MyData_Home` is writable.

    3. Install and start Syncthing.

    4. Install Tailscale and authenticate with the same account.

    5. Open Office Syncthing at `http://127.0.0.1:8384`.

    6. Run the SSH tunnel to Home.

    7. Open Home Syncthing at `http://127.0.0.1:8385`.

    8. Exchange and approve both Device IDs.

    9. Share `mydata-home`.

    10. Begin with Home Send Only and Office Receive Only.

    11. Wait for **Up to Date**.

    12. Change both folders to Send & Receive.

    13. Create and verify an Office test file.

    [1]: https://packages.debian.org/sid/syncthing?utm_source=chatgpt.com "Debian -- Details of package syncthing in sid"

    [2]: https://manpages.debian.org/unstable/systemd/systemd.automount.5.en.html?utm_source=chatgpt.com "systemd.automount(5) — systemd — Debian unstable — Debian Manpages"

    [3]: https://docs.syncthing.net/users/autostart.html "Starting Syncthing Automatically — Syncthing documentation"

    [4]: https://manpages.debian.org/bullseye/systemd/systemd.unit.5.en.html?utm_source=chatgpt.com "systemd.unit(5) — systemd — Debian bullseye — Debian Manpages"

    [5]: https://docs.syncthing.net/intro/getting-started.html "Getting Started — Syncthing documentation"

    [6]: https://docs.syncthing.net/users/firewall.html "Firewall Setup — Syncthing documentation"

    [7]: https://docs.syncthing.net/users/foldertypes.html "Folder Types — Syncthing documentation"

    [8]: https://docs.syncthing.net/users/versioning.html "File Versioning — Syncthing documentation"

    [9]: https://tailscale.com/kb/1031/install-linux "Install Tailscale on Linux · Tailscale Docs"

    [10]: https://tailscale.com/docs/concepts/what-is-tailscale?utm_source=chatgpt.com "What is Tailscale?"

- Work Instructions (CachyOS)

    The procedure below installs Syncthing on both PCs while keeping the synchronized data on external drives.

    The important part is the “Office identity seed”: while still at Home, you will create the Office PC’s Syncthing identity and pre-authorize both computers. At the Office, you import that identity, accept the offered folder, and synchronization begins—no return trip or remote access to Home is required.

    Syncthing device identities are based on a private key, so protect the transfer archive carefully. [Syncthing device-ID explanation](https://docs.syncthing.net/v1.23.1/dev/device-ids.html)

    ## Before starting

    A few important points:

    - Syncthing synchronizes changes, including deletions. It is not, by itself, a backup.

    - I recommend synchronizing a subdirectory named `Syncthing` rather than the entire partition. That avoids `lost+found`, filesystem metadata, and unrelated files.

    - Both PCs should initially use **Send & Receive** unless you specifically want one-way replication.

    - Leave the Home PC powered on, connected to the internet, with its external drive attached.

    - If this is a company network or company-owned Office PC, get IT approval. Do not bypass the company firewall or software policy.

    - Do not expose Syncthing’s web interface, port `8384`, to the internet.

    ---

    # Part 1 — Prepare the Home external drive

    Your Home mount point is:

    ```text
    /mnt/wwn-0x5000c500cf6eb47a-part1
    ```

    Open a terminal and define the locations:

    ```bash
    SYNC_MOUNT_HOME='/mnt/wwn-0x5000c500cf6eb47a-part1'
    SYNC_DIR_HOME="$SYNC_MOUNT_HOME/Syncthing"
    ```

    ## 1. Confirm that the external drive is actually mounted

    ```bash
    mountpoint "$SYNC_MOUNT_HOME"
    findmnt -M "$SYNC_MOUNT_HOME"
    findmnt -no SOURCE,FSTYPE,OPTIONS -M "$SYNC_MOUNT_HOME"
    ```

    The first command should say that the path is a mount point. In the options printed by the last command, look for `rw`, meaning read/write.

    If it says the directory is not a mount point, stop here. Mount the drive before continuing.

    ## 2. Make sure the mount is persistent

    Check whether the path is configured in `/etc/fstab`:

    ```bash
    grep -F "$SYNC_MOUNT_HOME" /etc/fstab
    ```

    If a line appears, it is probably already configured for startup.

    If nothing appears, configure the drive to mount at this exact location during boot using KDE Partition Manager or an appropriate `/etc/fstab` entry based on its UUID and filesystem type. Do not use a temporary path under `/run/media/...` for an unattended Home PC.

    After any `/etc/fstab` change, test it before leaving Home:

    ```bash
    sudo findmnt --verify
    sudo mount -a
    mountpoint "$SYNC_MOUNT_HOME"
    ```

    Do not continue until the final command confirms that the drive is mounted.

    ## 3. Create the synchronized subdirectory

    ```bash
    sudo mkdir -p "$SYNC_DIR_HOME"
    sudo chown "$(id -u):$(id -g)" "$SYNC_DIR_HOME"
    chmod 700 "$SYNC_DIR_HOME"
    ```

    Test writing:

    ```bash
    touch "$SYNC_DIR_HOME/.syncthing-write-test"
    rm "$SYNC_DIR_HOME/.syncthing-write-test"
    ```

    If either command returns “Permission denied,” fix the drive’s ownership or mount options before proceeding.

    If you truly want to synchronize the entire partition instead, use:

    ```bash
    SYNC_DIR_HOME="$SYNC_MOUNT_HOME"
    ```

    That is less desirable because Syncthing may encounter system-created directories such as `lost+found`.

    ## 4. Note the filesystem type

    Run:

    ```bash
    findmnt -no FSTYPE -M "$SYNC_MOUNT_HOME"
    ```

    - For `ext4`, `btrfs`, or `xfs`, leave Syncthing’s **Ignore Permissions** option disabled.

    - For `exfat`, `vfat`, or `ntfs3`, enable **Ignore Permissions** later in that computer’s folder settings.

    - A Linux-native filesystem such as ext4 or Btrfs is preferable when both computers run Linux.

    “Ignore Permissions” does not cure ordinary write-permission errors; Syncthing still needs permission to create, change, and delete files.

    ---

    # Part 2 — Install and configure Syncthing at Home

    CachyOS is Arch-based, and Syncthing is available in the Arch/CachyOS repositories. [CachyOS](https://cachyos.org/) recommends full system updates with Pacman, and Syncthing is in Arch’s Extra repository. [Arch Syncthing package](https://archlinux.org/packages/extra/x86_64/syncthing/)

    ## 5. Install Syncthing and GnuPG

    GnuPG will encrypt the Office identity while you carry it.

    ```bash
    sudo pacman -Syu syncthing gnupg
    ```

    Reboot first if this performs a major kernel or system update.

    Confirm installation:

    ```bash
    syncthing version
    ```

    ## 6. Start Syncthing temporarily as your desktop user

    ```bash
    systemctl --user enable --now syncthing.service
    systemctl --user status syncthing.service
    ```

    Press `q` to leave the status screen.

    Arch’s package provides both user and system services. The user service is appropriate during initial desktop configuration. [Official Syncthing systemd instructions](https://docs.syncthing.net/users/autostart)

    ## 7. Open the Home Syncthing interface

    Open this address in a browser:

    [http://127.0.0.1:8384](http://127.0.0.1:8384)

    If it does not open, inspect the logs:

    ```bash
    journalctl --user-unit=syncthing.service -e
    ```

    ## 8. Secure and name the Home interface

    In Syncthing:

    1. Open **Actions → Settings**.

    2. Under **General**, set the device name to `Home PC`.

    3. Under **GUI**, set a username and strong password.

    4. Leave the GUI listen address as:

        ```text
        127.0.0.1:8384
        ```

    5. Save and sign in again if prompted.

    Keep the GUI bound to localhost. Remote GUI access is unnecessary for this procedure.

    ## 9. Add the Home folder

    Click **Add Folder** and enter:

    - **Folder Label:** `Home-Office Data`

    - **Folder ID:** `home-office-data`

    - **Folder Path:**

        ```text
        /mnt/wwn-0x5000c500cf6eb47a-part1/Syncthing
        ```

    - **Folder Type:** `Send & Receive`

    Under **File Versioning**, I recommend:

    - **Versioning:** `Staggered File Versioning`

    - **Maximum Age:** `180` days, or another retention period appropriate for the available space.

    Versioning is configured separately on each computer and only archives changes received from another device. [Syncthing versioning documentation](https://docs.syncthing.net/users/versioning?version=v2.0.0)

    Under **Advanced**:

    - Enable **Ignore Permissions** only if this drive uses NTFS, exFAT, or FAT.

    - Leave filesystem watching enabled.

    - Leave the remaining settings at their defaults.

    Click **Save**.

    Wait until the folder says **Up to Date**.

    ## 10. Record the Home Device ID

    Choose **Actions → Show ID**.

    Copy the full Home Device ID into a password manager, printed page, or offline note. Label it:

    ```text
    HOME DEVICE ID
    ```

    Do not rely only on a screenshot stored inside the folder you are about to synchronize.

    ---

    # Part 3 — Create the Office identity while still at Home

    This is what eliminates the need to approve the Office PC later from Home.

    ## 11. Generate a separate Office identity

    In the Home terminal:

    ```bash
    SEED_DIR="$HOME/.local/state/syncthing-office-seed"
    install -d -m 700 "$SEED_DIR"
    syncthing generate --home="$SEED_DIR"
    ```

    Display the identity:

    ```bash
    syncthing device-id --home="$SEED_DIR"
    ```

    The current Syncthing command supports generating a separate configuration and printing its device ID this way. [Current Arch Syncthing manual](https://man.archlinux.org/man/syncthing.1.en)

    Record this ID as:

    ```text
    OFFICE DEVICE ID
    ```

    ## 12. Pre-authorize the Office device on Home

    Return to the normal Home interface at:

    [http://127.0.0.1:8384](http://127.0.0.1:8384)

    Click **Add Remote Device** and enter:

    - **Device ID:** the Office Device ID you just generated

    - **Device Name:** `Office PC`

    - **Addresses:** `dynamic`

    On the folder-sharing tab, select:

    ```text
    Home-Office Data
    ```

    Save.

    The Office device should show **Disconnected**. That is expected because the identity has not yet been installed on the Office PC.

    ## 13. Stop the normal Home instance temporarily

    ```bash
    systemctl --user stop syncthing.service
    ```

    ## 14. Open the staged Office instance

    Run this command and leave its terminal open:

    ```bash
    syncthing serve --home="$SEED_DIR" \
      --gui-address=http://127.0.0.1:8385 \
      --no-browser
    ```

    Open a second browser tab:

    [http://127.0.0.1:8385](http://127.0.0.1:8385)

    This is the future Office identity, temporarily running on the Home computer.

    ## 15. Configure the staged Office identity

    In the interface on port `8385`:

    1. Set its device name to `Office PC`.

    2. Set an Office GUI username and password.

    3. If a default folder named `Sync` or `Default Folder` exists, remove it from Syncthing. Removing a folder from the interface does not delete its files.

    4. Click **Add Remote Device**.

    5. Enter the previously recorded **Home Device ID**.

    6. Name it `Home PC`.

    7. Leave its address as `dynamic`.

    8. Save.

    Do not add the shared folder manually here. The Home PC will offer it after the Office identity is installed and connects.

    Choose **Actions → Shutdown** in the staged interface. The terminal command should then exit.

    ## 16. Restart the normal Home instance

    ```bash
    systemctl --user start syncthing.service
    ```

    Verify:

    ```bash
    systemctl --user status syncthing.service
    ```

    ---

    # Part 4 — Put the Office identity on encrypted removable media

    ## 17. Insert a transfer USB drive

    Find its mount path:

    ```bash
    lsblk -f
    ```

    It will commonly be somewhere under:

    ```text
    /run/media/YOUR-USERNAME/USB-LABEL
    ```

    Set the actual location:

    ```bash
    TRANSFER_DIR='/run/media/YOUR-USERNAME/USB-LABEL'
    ```

    Verify it:

    ```bash
    findmnt --target "$TRANSFER_DIR"
    ```

    ## 18. Create the encrypted archive

    ```bash
    SEED_ARCHIVE="$TRANSFER_DIR/office-syncthing-seed.tar.gz.gpg"
    tar -C "$SEED_DIR" -czf - . |
      gpg --symmetric --cipher-algo AES256 --output "$SEED_ARCHIVE"
    ```

    GnuPG will ask you to create a passphrase. Store that passphrase separately from the USB drive.

    Verify the archive can be decrypted and listed:

    ```bash
    gpg --decrypt "$SEED_ARCHIVE" | tar -tzf - | head
    ```

    You should see entries including approximately:

    ```text
    ./config.xml
    ./cert.pem
    ./key.pem
    ```

    The `key.pem` file is the Office PC’s identity. Anyone who obtains it can impersonate that device, which is why the archive is encrypted.

    Flush writes before unplugging:

    ```bash
    sync
    ```

    Then safely unmount/eject the transfer drive through KDE.

    Do not run the staged Office identity on the Home PC again after the real Office PC starts using it. Two active installations with the same identity will cause serious connection problems.

    ---

    # Part 5 — Make the Home PC operate unattended

    A user service normally starts after login. Because you do not want to return Home after a reboot, switch the Home PC to Syncthing’s system service, which still runs as your unprivileged user but starts during boot.

    ## 19. Stop and disable the Home user service

    ```bash
    SYNC_USER="$(id -un)"
    systemctl --user disable --now syncthing.service
    ```

    ## 20. Require the external drive before starting Syncthing

    Open a service override:

    ```bash
    sudo systemctl edit "syncthing@${SYNC_USER}.service"
    ```

    Paste exactly:

    ```text
    [Unit]
    RequiresMountsFor=/mnt/wwn-0x5000c500cf6eb47a-part1
    After=local-fs.target network-online.target
    Wants=network-online.target
    ```

    Save and exit.

    Now enable the unattended service:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable --now "syncthing@${SYNC_USER}.service"
    sudo systemctl status "syncthing@${SYNC_USER}.service"
    ```

    Reopen [http://127.0.0.1:8384](http://127.0.0.1:8384) and confirm that your folder and Office device are still listed.

    ## 21. Prevent Home from sleeping

    In CachyOS/KDE:

    1. Open **System Settings → Power Management**.

    2. For AC power, disable automatic sleep/suspend.

    3. Screen locking and screen blanking are fine.

    4. Leave the external drive connected.

    5. Leave the PC powered on and connected to the internet.

    You can test unattended startup before leaving:

    ```bash
    sudo reboot
    ```

    After it boots, without logging into the graphical desktop, the system Syncthing service should start. If you do log in to verify it, run:

    ```bash
    SYNC_USER="$(id -un)"
    sudo systemctl status "syncthing@${SYNC_USER}.service"
    mountpoint "$SYNC_MOUNT_HOME"
    ```

    ---

    # Part 6 — What to take to the Office

    Bring all of the following:

    - The Office external drive.

    - The USB containing `office-syncthing-seed.tar.gz.gpg`.

    - The archive’s GPG passphrase.

    - The Office Syncthing GUI username/password.

    - The recorded Home Device ID.

    - The recorded Office Device ID.

    - The folder ID: `home-office-data`.

    - These instructions, saved offline or printed.

    - The Office PC administrator password.

    - Confirmation that Office IT permits Syncthing.

    ---

    # Part 7 — Set up the Office PC

    ## 22. Prepare the Office external drive

    Attach the Office drive and determine its permanent mount location:

    ```bash
    lsblk -f
    findmnt
    ```

    Choose a stable mount under `/mnt`, for example:

    ```text
    /mnt/office-external
    ```

    Do not use that example blindly; use the actual persistent mount point you configure.

    Set variables using the real path:

    ```bash
    SYNC_MOUNT_OFFICE='/mnt/YOUR-OFFICE-MOUNT'
    SYNC_DIR_OFFICE="$SYNC_MOUNT_OFFICE/Syncthing"
    ```

    Confirm it is mounted:

    ```bash
    mountpoint "$SYNC_MOUNT_OFFICE"
    findmnt -no SOURCE,FSTYPE,OPTIONS -M "$SYNC_MOUNT_OFFICE"
    ```

    Make sure this drive is also mounted persistently through `/etc/fstab` if you expect Syncthing to survive reboots.

    Create the folder:

    ```bash
    sudo mkdir -p "$SYNC_DIR_OFFICE"
    sudo chown "$(id -u):$(id -g)" "$SYNC_DIR_OFFICE"
    chmod 700 "$SYNC_DIR_OFFICE"
    ```

    Test it:

    ```bash
    touch "$SYNC_DIR_OFFICE/.syncthing-write-test"
    rm "$SYNC_DIR_OFFICE/.syncthing-write-test"
    ```

    For the safest initial synchronization, the Office directory should be empty. If it already contains files, Syncthing will merge them into the Home folder rather than treating Home as automatically authoritative.

    ## 23. Install the same software

    ```bash
    sudo pacman -Syu syncthing gnupg
    ```

    Reboot first if a major system update requires it.

    Do not start Syncthing yet.

    ## 24. Insert and locate the transfer USB

    ```bash
    lsblk -f
    ```

    Set the archive’s real path:

    ```bash
    SEED_ARCHIVE='/run/media/YOUR-USERNAME/USB-LABEL/office-syncthing-seed.tar.gz.gpg'
    ```

    Confirm:

    ```bash
    ls -lh "$SEED_ARCHIVE"
    ```

    ## 25. Import the pre-authorized Office identity

    Ensure no Syncthing service is running:

    ```bash
    systemctl --user disable --now syncthing.service 2>/dev/null
    sudo systemctl disable --now "syncthing@$(id -un).service" 2>/dev/null
    ```

    Set the normal configuration location:

    ```bash
    CONFIG_OFFICE="$HOME/.local/state/syncthing"
    ```

    If that directory already exists, preserve it rather than overwriting it:

    ```bash
    if [ -e "$CONFIG_OFFICE" ]; then
      mv "$CONFIG_OFFICE" "${CONFIG_OFFICE}.before-office-seed"
    fi
    ```

    Create the destination and decrypt:

    ```bash
    install -d -m 700 "$CONFIG_OFFICE"
    gpg --decrypt "$SEED_ARCHIVE" |
      tar -xzf - -C "$CONFIG_OFFICE"
    chmod -R go-rwx "$CONFIG_OFFICE"
    ```

    Enter the archive passphrase when prompted.

    ## 26. Verify the imported identity before starting

    ```bash
    syncthing device-id --home="$CONFIG_OFFICE"
    ```

    This must exactly match the **Office Device ID** recorded at Home.

    If it does not match, do not continue. The wrong configuration was imported, and Home will not recognize it.

    ## 27. Start the Office user service

    Make sure the Office external drive is mounted first, then run:

    ```bash
    systemctl --user enable --now syncthing.service
    systemctl --user status syncthing.service
    ```

    Open:

    [http://127.0.0.1:8384](http://127.0.0.1:8384)

    Sign in using the Office GUI credentials configured at Home.

    ## 28. Accept the shared folder from Home

    After the devices connect, Syncthing should display a notification that `Home PC` wants to share `Home-Office Data`.

    Click **Add** and enter:

    - **Folder Label:** `Home-Office Data`

    - **Folder ID:** leave as `home-office-data`

    - **Folder Path:** your Office path, such as:

        ```text
        /mnt/YOUR-OFFICE-MOUNT/Syncthing
        ```

    - **Folder Type:** `Send & Receive`

    - **File Versioning:** `Staggered`, maximum age `180` days

    - **Ignore Permissions:** enable only for NTFS/exFAT/FAT

    Save.

    The initial scan and transfer should now begin.

    ---

    # Part 8 — Firewall configuration

    Syncthing normally uses:

    - TCP `22000` for synchronization

    - UDP `22000` for QUIC synchronization

    - UDP `21027` for local discovery

    These are the official default ports. Port `8384` is only the local web interface and does not need to be opened. [Official firewall documentation](https://docs.syncthing.net/v2.0.0/users/firewall.html)

    Only apply the section matching an already-active firewall.

    For Firewalld:

    ```bash
    sudo firewall-cmd --zone=public --add-service=syncthing --permanent
    sudo firewall-cmd --reload
    ```

    For UFW:

    ```bash
    sudo ufw allow 22000/tcp
    sudo ufw allow 22000/udp
    sudo ufw allow 21027/udp
    sudo ufw status verbose
    ```

    Router port-forwarding is not normally required. Syncthing can use encrypted relays when a direct connection cannot be established, although relayed transfers may be slower.

    ---

    # Part 9 — Verify that Home really received the Office changes

    On the Office PC, wait until:

    - The Home device says **Connected**.

    - The connection may say `TCP`, `QUIC`, or `Relay`; all can work.

    - The shared folder says **Up to Date**.

    - The Home remote device also reports **Up to Date**.

    Create a test file:

    ```bash
    date > "$SYNC_DIR_OFFICE/SYNCTHING-OFFICE-TEST.txt"
    ```

    Watch the Syncthing interface. Once both the folder and the Home device return to **Up to Date**, Home has acknowledged the synchronized state. You can then delete the test file if desired; remember that its deletion will also synchronize.

    ---

    # Critical external-drive warning

    Syncthing creates a hidden `.stfolder` directory in every synchronized folder. It uses this marker to detect a missing or unmounted external drive and stop synchronization rather than interpreting the missing drive as mass file deletion. [Official  explanation](https://docs.syncthing.net/users/faq.html)

    If Syncthing reports **folder marker missing**:

    1. Stop and check whether the external drive is mounted.

    2. Confirm that your real files are visible.

    3. Remount the drive.

    4. Do **not** create `.stfolder` in an empty underlying `/mnt/...` directory while the external drive is absent.

    5. Do not delete the existing `.stfolder` directory.

    ## Common problems

    - **Home says “Unknown Device”:** The imported Office identity does not match the pre-authorized Office Device ID.

    - **Connected, but no folder offer:** Verify that Home shared `home-office-data` with `Office PC` and that the staged Office configuration contains the Home Device ID.

    - **Permission denied:** Fix drive ownership or mount options. “Ignore Permissions” does not grant write access.

    - **Home remains disconnected:** Confirm it is powered on, its external drive is mounted, and `syncthing@USERNAME.service` is active.

    - **Very slow transfer:** The connection is probably using a relay. Check firewall rules or arrange direct connectivity with IT.

    - **Folder marker missing:** Remount the real external drive; never populate the empty mount-point directory underneath it.

    - **Office data unexpectedly appears at Home:** Send & Receive merges files already present on both sides. Begin with an empty Office destination if Home should supply the initial dataset.
