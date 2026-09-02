---
type: 'Page'
collections: 'Public Pages'
title: Installing Linux Mint
aliases: null
description: null
icon: null
createdAt: '2025-03-17T12:49:10.455Z'
lastUpdated: '2026-08-07T14:01:47.656Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(61).md)'
---

# Installing Linux Mint



## Setting up Linux Mint Cinnamon 22.3

- Setting up NextCloud (from home)

    Building an open, transparent learning hub from scratch is a fantastic project, and having all the steps compiled into one master guide is the best way to ensure everything runs smoothly.

    Here is the complete, start-to-finish master guide for setting up your 1.5 TB teaching library on Linux Mint using Docker. This guide assumes no prior server knowledge and uses the safest, most stable methods we established.

    ---

    ### Phase 1: Prepare the External Drive

    Because your Seagate drive is formatted in BTRFS, it perfectly supports Linux permissions, making this step very clean. We will create a simple shortcut to avoid Docker getting confused by the colons in the drive's default name.

    1. **Open your terminal** (`Ctrl + Alt + T`).

    2. **Create a clean shortcut** for the drive:

    ```bash
    sudo ln -s /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1 /mnt/seagate
    ```

    1. **Grant Nextcloud permission** to read and write to your library (Nextcloud uses the internal system ID `33`):

    ```bash
    sudo chown -R 33:33 /mnt/seagate
    ```

    ### Phase 2: Build the Server Environment

    We will use Docker to neatly package the server and its database without cluttering your Linux Mint system.

    1. **Install the required Docker software:**

    ```bash
    sudo apt update
    sudo apt install docker.io docker-compose-v2
    ```

    1. **Create a dedicated folder** for your server configuration and move inside it:

    ```bash
    mkdir ~/nextcloud-server && cd ~/nextcloud-server
    ```

    1. **Create the configuration recipe:**

    ```bash
    nano docker-compose.yml
    ```

    1. **Paste the following code** exactly as written. This connects the database and maps your clean `seagate` shortcut to a virtual `/mnt/shared_library` folder:

    ```yaml
    services:
      db:
        image: mariadb:10.6
        restart: always
        command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
        volumes:
          - db_data:/var/lib/mysql
        environment:
          - MYSQL_ROOT_PASSWORD=nextcloud
          - MYSQL_PASSWORD=nextcloud
          - MYSQL_DATABASE=nextcloud
          - MYSQL_USER=nextcloud
      app:
        image: nextcloud
        restart: always
        ports:
          - 8080:80
        depends_on:
          - db
        volumes:
          - nextcloud_data:/var/www/html
          - /mnt/seagate:/mnt/shared_library
        environment:
          - MYSQL_PASSWORD=nextcloud
          - MYSQL_DATABASE=nextcloud
          - MYSQL_USER=nextcloud
          - MYSQL_HOST=db
    volumes:
      db_data:
      nextcloud_data:
    ```

    1. **Save and exit** by pressing `Ctrl + O`, `Enter`, and then `Ctrl + X`.

    2. **Turn the server on:**

    ```bash
    sudo docker compose up -d
    ```

    ### Phase 3: Initial Browser Setup

    With the server running in the background, it is time to initialize the platform.

    1. Open your web browser and go to `localhost:8080`.

    2. Create your master **Admin** username and password.

    3. Click the **Storage & database** dropdown.

    4. Select **MySQL/MariaDB**.

    5. Fill in the database details exactly as we set them in the recipe:

    - Database user: `nextcloud`

    - Database password: `nextcloud`

    - Database name: `nextcloud`

    - Database host: `db`

    1. Click **Install**.

    > *Note: If you encounter an error saying "Could not fetch list of apps," ignore it. Simply delete everything after* `8080` *in your address bar and press Enter to reload the main dashboard.*

    ### Phase 4: Bridge the 1.5 TB Library

    Now we make your syllabi, podcast files, and research available inside the Nextcloud interface.

    1. Click your profile icon (top right) and select **Apps**.

    2. Find **External storage support** in the list and click **Enable**.

    3. Click your profile icon again and select **Administration settings**.

    4. On the left sidebar (under the bottom Administration section), click **External storages**.

    5. Fill out the new storage mount:

    - **Folder name:** `Teaching_Library` (or your preferred name)

    - **External storage:** `Local`

    - **Authentication:** `None`

    - **Configuration:** `/mnt/shared_library`

    1. Click the checkmark. A green circle indicates your files are successfully bridged.

    ### Phase 5: Enable Local Wi-Fi Access

    To access the hub from your phone or another laptop while at home, you must tell Nextcloud to trust your local network.

    1. Find your computer's local network IP address by typing this in the terminal:

    ```bash
    hostname -I
    ```

    *(Note the address, it usually looks like* `192.168.x.x`*)*
    2. Open Nextcloud's security configuration file:

    ```bash
    sudo nano /var/lib/docker/volumes/nextcloud-server_nextcloud_data/_data/config/config.php
    ```

    1. Find the `'trusted_domains'` section. Right below `0 => 'localhost:8080',`, add a new line with your IP address:

    ```php
    1 => '192.168.x.x:8080',
    ```

    1. Save (`Ctrl + O`, `Enter`) and exit (`Ctrl + X`).

    2. Open the Nextcloud app on your phone and log in using `http://192.168.x.x:8080`.

    ---

    This gives you a beautifully robust, local foundation. When you are ready to start sharing these resources with the wider network of English language educators, the next logical move is setting up that secure Cloudflare Tunnel.

    Would you like to start looking into securing a professional domain name to get that public tunnel established?

- What happens when I reach Google sync limit?

    When you hit Google's 750 GB daily upload limit, the good news is that you absolutely do not have to start over from scratch. `rclone` is designed specifically to handle network interruptions, errors, and quotas gracefully.

    Here is exactly what to expect and how to handle it.

    ### What Happens When You Hit the Limit?

    Once you transfer 750 GB, Google will temporarily revoke your write permissions.

    - **In the Terminal:** You will suddenly see a flood of error messages in red or yellow text. They will usually say something like `Failed to copy: googleapi: Error 403: User rate limit exceeded` or `quotaExceeded`.

    - **The Process:** `rclone` will not immediately quit. It will stubbornly keep trying to upload the current file, fail, wait a few seconds, and try again. It will sit there in an endless loop of failing until the block is lifted.

    ### How to Stop and Resume

    If you see those 403 quota errors flooding your screen, there is no point in letting your Linux Mint PC spin its wheels.

    1. **Stop the Sync:** Click inside your terminal and press `Ctrl + C`. This safely kills the active `rclone` process.

    2. **Wait:** Google's 750 GB limit typically resets on a 24-hour rolling window, or sometimes universally at midnight Pacific Time. Generally, waiting 12 to 24 hours is required before you can upload again.

    3. **Resume the Sync:** After waiting, simply run the **exact same command** you ran the first time:

    ```bash
    rclone bisync /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1 gdrive: --resync -P
    ```

    ### Why You Aren't Starting Over

    It is critical that you **keep the** `--resync` **flag** in your command until the process reaches 100% completion without errors.

    Even though you are running the initial sync command again, `rclone` **will not re-upload the 750 GB of data you already transferred.** Here is how `rclone` handles the resume process:

    1. It looks at the first file on your external hard drive.

    2. It queries Google Drive: *"Do you have a file with this exact name, size, and modification time?"*

    3. Google Drive says: *"Yes."*

    4. `rclone` skips the file instantly and moves to the next one.

    It will rapidly scan through the 750 GB of files that are already safe in the cloud. This scanning phase is much faster than uploading. Once it reaches the file where it was interrupted the previous day, it will seamlessly resume uploading the remaining data.

    You will repeat this process (Upload 750 GB -> Hit the limit -> `Ctrl + C` -> Wait -> Run the exact same `--resync` command) over the course of a few days until the terminal finally finishes the command cleanly and returns you to your standard command prompt.

    Once that happens, your baseline database is built, and you can drop the `--resync` flag for all future daily synchronizations.

- How do I know if rclone is running?

    Here are the three most effective ways to verify that your background process is actively running and properly attached to your drive.

    ### 1. Check the Systemd Service Status

    The most direct way to see the health of the background user service is to ask systemd for its current status. Run this command:

    ```bash
    systemctl --user status rclone-mount.service
    ```

    - Look for the line that says **Active:**. If everything is working perfectly, it will say `active (running)` in green text.

    - This output also provides the most recent log entries for the service, which is helpful for catching any immediate connection warnings or errors.

    ### 2. Check Running System Processes

    To see the actual background process executing in real-time, you can filter your active system processes:

    ```bash
    ps -ef | grep rclone
    ```

    - This will output a line showing the exact command actively running in memory, confirming that your specific `--vfs-cache-max-size 1500G` flags and the cache paths to your Seagate drive are correctly applied.

    ### 3. Verify the Active Mount Point

    Even if the systemd process is running, it is always good practice to confirm that Linux Mint recognizes the mounted filesystem.

    ```bash
    df -h | grep rclone
    ```

    - This lists your connected filesystems and their disk usage. You should see a line for `gdrive:` showing its total cloud capacity, available space, and confirming the target mount point at `/mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/gdrive_mount`.

- Mount dependency to protect mass deletion if disk becomes dismounted or damaged

    Setting up a mount dependency in `systemd` acts as an automatic kill-switch. If your drives disconnect, `systemd` will instantly terminate Insync before it can notice any missing files and push mass deletions to your Google Drive.

    Since you are running Insync as a background `systemd` user service, you will need to edit its specific configuration file. Here is how to configure it securely.

    ### Step 1: Open Your Insync Service File

    Assuming you created a user-level service for Insync, the file is located in your local `.config` directory. Open your terminal and edit the file (if you named the service something else, adjust the filename accordingly):

    ```bash
    nano ~/.config/systemd/user/insync.service
    ```

    ### Step 2: Add the `RequiresMountsFor` Directive

    You need to add the `RequiresMountsFor=` line under the `[Unit]` section.

    **Crucial detail for** `mergerfs` **users:** You must list the mount points of your *actual physical drives*, not just the combined pool. If a physical drive fails, `mergerfs` might keep the combined pool mounted (just with missing files). By telling `systemd` to monitor the physical drives directly, you guarantee Insync stops if the hardware drops.

    Modify your `[Unit]` section to look like this:

    ```text
    [Unit]
    Description=Insync Background Service
    After=network.target
    # List every drive path separated by a space. 
    # If any of these drop, Insync is immediately killed.
    RequiresMountsFor=/mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1 /mnt/usb-Second_Drive /mnt/Combined_Storage
    [Service]
    ExecStart=/usr/bin/insync start --no-daemon
    Restart=on-failure
    # (Keep the rest of your existing [Service] and [Install] configurations the same)
    ```

    *Note: Ensure the paths exactly match where your drives are mounted.*

    Save the file and exit (`Ctrl+O`, `Enter`, `Ctrl+X` in nano).

    ### Step 3: Apply the Changes

    Tell `systemd` to reload its configuration files so it recognizes the new dependency rule, then restart the Insync service:

    ```bash
    systemctl --user daemon-reload
    systemctl --user restart insync.service
    ```

    ### Step 4: Verify the Dependency

    You can verify that `systemd` correctly registered the dependency by asking it to show the properties of your service. Run this command:

    ```bash
    systemctl --user show insync.service -p RequiresMountsFor
    ```

    The terminal should output the exact paths you entered.

    **How it behaves now:**
    From this moment on, `systemd` will constantly monitor those specific directories. If the USB cable is bumped, power is lost, or the OS forcefully unmounts either the Seagate drive or the second external drive, the `RequiresMountsFor` condition will fail. `systemd` will immediately send a stop signal to Insync, safely neutralizing the sync engine before any data on Google Drive can be touched.

- rclone office setup [[Date/2026-07-01]]

    Here is the adaptation to get everything running smoothly on your Linux Mint Cinnamon 22.3 setup.

    First, I need to offer a gentle, clarifying correction regarding how this data moves. The attached document provides instructions for setting up `rclone bisync`. However, as the document accurately notes, `bisync` does not use a file cache. Instead, it reads a file from Google Drive and writes it directly to your primary hard drive.

    Because you explicitly want to maintain a temporary cache of 1.5 TB for your library, we need to pivot your strategy slightly from a `bisync` setup to an `rclone mount` with Virtual File System (VFS) caching. This will seamlessly mount your Google Drive locally, keeping up to 1.5 TB of your most recently accessed files stored physically on your Seagate drive for instant access.

    To keep your Linux Mint environment perfectly clean and avoid running background tasks as the root user—which the original document suggested by using `sudo` to edit `/etc/systemd/system/` —we will configure this as a background systemd *user* service.

    ### Step 1: Prepare the Seagate Drive

    First, we need to create two folders on your current Seagate drive: one for the mount point (where your cloud files will visibly appear) and one for the 1.5 TB background cache.

    ```bash
    mkdir -p /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/gdrive_mount
    mkdir -p /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/rclone_cache
    ```

    ### Step 2: Create the Background User Service

    Instead of building a system-wide timer and service, we will create a dedicated systemd user service. This is the optimal way to manage a large library sync without requiring root privileges.

    ```bash
    mkdir -p ~/.config/systemd/user/
    nano ~/.config/systemd/user/rclone-mount.service
    ```

    Replace the `bisync` service configuration from the document  with the following block. This configuration initializes the mount and enforces your 1.5 TB cache parameter:

    ```text
    [Unit]
    Description=Rclone VFS Mount with 1.5TB Cache
    After=network-online.target
    [Service]
    Type=notify
    ExecStart=/usr/bin/rclone mount gdrive: /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/gdrive_mount \
      --vfs-cache-mode full \
      --vfs-cache-max-size 1500G \
      --cache-dir /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/rclone_cache \
      --vfs-cache-max-age 72h
    ExecStop=/bin/fusermount -u /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/gdrive_mount
    Restart=on-failure
    RestartSec=5
    [Install]
    WantedBy=default.target
    ```

    Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

    ### Step 3: Enable and Start the Service

    If you had any old rclone services running, you should stop them first as the original guide advised. Then, activate your new user service so it runs automatically in the background.

    ```bash
    # Reload the user systemd daemon
    systemctl --user daemon-reload
    # Enable and start the mount service immediately
    systemctl --user enable --now rclone-mount.service
    ```

    ---

    ### Alternative: Pure Bisync (No Cache)

    If you decide you *do* want the strict two-way mirroring outlined in the original instructions and are willing to forego the 1.5 TB cache limit , you can adapt the original manual `--resync` command  to point to your Seagate drive like this:

    ```bash
    rclone bisync gdrive: /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/MyData \
    --workdir /mnt/usb-Seagate_Portable_NT3FC3FJ-0:0-part1/rclone_workdir \
    --drive-stop-on-upload-limit \
    --resync \
    --verbose
    ```

    (Note: You will need to use `mkdir` to create the `MyData` and `rclone_workdir` folders on your Seagate drive first ).

- rclone home setup [[Date/2026-06-30]]

    Starting from scratch is often the best way to ensure your foundation is rock solid, especially when introducing a new drive to the mix.

    Before we build this, I need to gently correct one piece of terminology so you know exactly how your data is moving: `bisync` **does not use a file cache.** Unlike a virtual mount that buffers files temporarily, `bisync` reads a file from Google Drive and writes it directly to your primary hard drive (`MyData`), or vice versa. However, `bisync` *does* require a **working directory** (a database that tracks file hashes, deletions, and sync history). We will put this database on your ADATA drive to keep your main data drive perfectly clean.

    Since you are comfortable hitting the 750 GB daily limit, we will remove the speed limit and instead add a smart flag: `--drive-stop-on-upload-limit`. This tells rclone to go as fast as possible, and the moment Google blocks you, rclone will gracefully shut down the sync job instead of throwing thousands of errors, and simply try again on its next scheduled run.

    Here is how to wipe the slate clean and build your new setup.

    ### Step 1: Wipe the Slate Clean

    Let's stop any running background tasks and clear out the old working directory so it doesn't confuse the new setup. Run these commands:

    ```bash
    # Stop and disable all previous rclone services and timers
    sudo systemctl stop rclone-bisync.timer rclone-bisync.service rclone-gdrive.service
    sudo systemctl disable rclone-bisync.timer rclone-bisync.service rclone-gdrive.service
    # Delete the old working directory from your primary drive
    rm -rf /media/ben/MyData/.bisync_workdir
    ```

    ### Step 2: Prepare the ADATA Drive

    Create the dedicated folder on your second hard drive to hold the `bisync` database.

    ```bash
    mkdir -p /media/ben/ADATA/backup-CYXPCH-ben/rclone_workdir
    ```

    ### Step 3: The Initial Baseline (Resync)

    We need to run the initial `--resync` manually so `bisync` can map out the current state of Google Drive and your `MyData` drive.

    Run this command. It will run at maximum speed, track its database on the ADATA drive, and stop automatically if it hits the 750 GB limit.

    ```bash
    rclone bisync gdrive: /media/ben/MyData \
      --workdir /media/ben/ADATA/backup-CYXPCH-ben/rclone_workdir \
      --drive-stop-on-upload-limit \
      --resync \
      --verbose
    ```

    *Note: If you have more than 750 GB of data to move right now, this command will eventually stop with a "Fatal Error: upload limit exceeded." If that happens, wait 24 hours, and run the exact same* `--resync` *command again until it finishes successfully.*

    ### Step 4: Automate the Daily Operation

    Once the manual `--resync` finishes successfully, you can hand it over to systemd to run automatically in the background.

    **1. Update the Service File**

    ```bash
    sudo nano /etc/systemd/system/rclone-bisync.service
    ```

    Replace the contents with this updated version (pointing to the new ADATA directory and using the upload limit flag):

    ```text
    [Unit]
    Description=Rclone Two-Way Bisync
    After=network-online.target
    [Service]
    Type=oneshot
    User=ben
    Group=ben
    ExecStart=/usr/bin/rclone bisync gdrive: /media/ben/MyData \
      --workdir /media/ben/ADATA/backup-CYXPCH-ben/rclone_workdir \
      --drive-stop-on-upload-limit
    ```

    Save and exit.

    **2. Turn on the Timer**
    Since we already created the timer file in the previous step, you just need to reload systemd and re-enable it:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable --now rclone-bisync.timer
    ```

    Your system is now configured exactly as you requested: maximum speed mirroring between Google Drive and `MyData`, using the ADATA drive for all operational overhead, and intelligently handling Google's daily limits.

- rclone

    Setting up a seamless, two-way sync with Google Drive using a local hard drive as a cache is a fantastic way to handle large files. First, just a quick clarification: the software is actually called **rclone** (without the first 'e'). It is an incredibly powerful, industry-standard tool for managing cloud storage on Linux.
    Since you are running Linux Mint Cinnamon, we can use a mix of built-in graphical tools and terminal commands to get this done. Because rclone will be managing 1.5 TB of background data, we need to make sure your external hard drive is permanently mounted to your system *before* rclone tries to use it.
    Here is the complete, step-by-step guide designed for a novice.

    ### Phase 1: Prepare Your System and External Drive

    First, we need to install the necessary software and ensure your 2TB external hard drive mounts automatically every time you turn on your PC.
    **1. Install Rclone and FUSE**
    Open your terminal (Ctrl + Alt + T) and paste the following commands, pressing **Enter** after each:

    ```bash
    sudo apt update
    sudo apt install rclone fuse3 -y
    ```

    **2. Automount Your External Hard Drive**
    Linux Mint usually mounts drives only after you log in. We need it mounted at boot time.

    1. Open your Linux Mint menu, type **Disks**, and open the Disks utility.

    2. Select your 2TB external hard drive on the left side.

    3. Click the **Gear icon** below the storage volumes and select **Edit Mount Options**.

    4. Toggle off **User Session Defaults** at the top.

    5. Ensure **Mount at system startup** is checked.

    6. Find the **Mount Point** text box. Change it to something simple, exactly like this: /mnt/ExternalDrive

    7. Click **OK**, enter your password, and then **restart your computer** so the drive mounts to its new permanent location.

    ### Phase 2: Connect Rclone to Google Drive

    Once rebooted, open your terminal again to link your Google account.

    1. Type the following command and press **Enter**:

    ```bash
    rclone config
    ```

    1. You will be presented with a menu. Follow these specific keystrokes:

    - Type n (for New remote) and press Enter.

    - Name it: type gdrive and press Enter.

    - For the storage type, look through the list for Google Drive (usually it is number 18 or 19). Instead of guessing the number, simply type drive and press Enter.

    - **Client ID:** Leave blank, press Enter.

    - **Client Secret:** Leave blank, press Enter.

    - **Scope:** Type 1 (Full access all files) and press Enter.

    - **Service Account file:** Leave blank, press Enter.

    - **Advanced config:** Type n and press Enter.

    - **Use auto config:** Type y and press Enter.

    1. A web browser will pop up. Log in to your Google Account and click **Allow** to grant rclone permission.

    2. Return to your terminal.

    - **Shared drive:** Type n (unless you are specifically mounting a team workspace).

    - **Keep this remote:** Type y.

    - Type q to quit the configuration menu.

    ### Phase 3: Create Your Folders

    We need two folders: one where you will actually view and interact with your Google Drive files, and one on the external hard drive where rclone will quietly cache that 1.5 TB of data.
    In the terminal, run these commands (replace YOUR_USERNAME with your actual Linux Mint username):

    ```bash
    # 1. Create the folder where your Google Drive will appear
    mkdir -p /home/YOUR_USERNAME/GoogleDrive
    # 2. Create the hidden cache folder on your newly mounted external drive
    sudo mkdir -p /mnt/ExternalDrive/rclone_cache
    sudo chown -R YOUR_USERNAME:YOUR_USERNAME /mnt/ExternalDrive/rclone_cache
    ```

    ### Phase 4: Create the Automated Background Service

    To make rclone run continuously in the background and sync bi-directionally, we will create a "systemd service" file.

    1. Open a text editor in the terminal with administrative privileges:

    ```bash
    sudo nano /etc/systemd/system/rclone-gdrive.service
    ```

    1. Copy the code block below. **Before pasting, you must replace every instance of YOUR_USERNAME with your actual Linux Mint user name.**

    ```text
    [Unit]
    Description=Rclone Google Drive Sync
    After=network-online.target
    Wants=network-online.target
    RequiresMountsFor=/mnt/ExternalDrive /home/YOUR_USERNAME/GoogleDrive
    [Service]
    Type=notify
    User=YOUR_USERNAME
    Group=YOUR_USERNAME
    ExecStart=/usr/bin/rclone mount gdrive: /home/YOUR_USERNAME/GoogleDrive \
      --vfs-cache-mode full \
      --cache-dir /mnt/ExternalDrive/rclone_cache \
      --vfs-cache-max-size 1500G \
      --vfs-cache-max-age 72h \
      --log-level INFO
    ExecStop=/bin/fusermount3 -uz /home/YOUR_USERNAME/GoogleDrive
    Restart=on-failure
    RestartSec=10
    [Install]
    WantedBy=multi-user.target
    ```

    1. Paste the edited text into the terminal.

    2. To save and exit the Nano text editor, press Ctrl + O (the letter O), press **Enter** to confirm the file name, and then press Ctrl + X to exit.

    > **What these settings do:** > * --vfs-cache-mode full: Enables bi-directional syncing. When you drag a file into the local folder, it is written to the cache first, then uploaded to Google Drive in the background.

    - --vfs-cache-max-size 1500G: Caps the cache space on your external drive at 1.5 TB.

    - RequiresMountsFor: Prevents rclone from starting if your external drive fails to mount, protecting your main system drive from being flooded with cached data.

    ### Phase 5: Start and Enable the Automation

    Finally, tell your Linux Mint system to recognize the new service, start it right now, and enable it to start on every future boot.
    Run these three commands in your terminal:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start rclone-gdrive.service
    sudo systemctl enable rclone-gdrive.service
    ```

    **You are all set!** You can now open your standard file manager (Nemo), go to your Home folder, and open the GoogleDrive folder. Everything you see there is dynamically linked to your Google Drive, seamlessly using your external hard drive to cache up to 1.5 TB of changes behind the scenes.

- Keyboard Reboot Key Binding

    Key binding command: cinnamon-session-quit --power-off

    - **Fix**: Monitor Instantly Waking from Sleep in Linux Mint

        **Problem:** The system or monitor instantly wakes up immediately after entering sleep mode. This is most commonly caused by overly sensitive ACPI (Advanced Configuration and Power Interface) wake triggers, particularly the USB controller (`XHCI`), which will wake the system at the slightest mouse vibration or phantom keyboard input.

        ### 1. Verify the Wake Culprit

        Check which devices are currently permitted to wake the system by running:

        ```bash
        cat /proc/acpi/wakeup
        ```

        *Look for* `XHCI` *(USB 3.0 Controller). If its status is* `*enabled`*, it is likely causing the issue.*

        ### 2. Temporarily Test the Fix

        Toggle the `XHCI` wake status to disabled for the current session:

        ```bash
        sudo sh -c "echo XHCI > /proc/acpi/wakeup"
        ```

        *Note: Run* `cat /proc/acpi/wakeup` *again to verify* `XHCI` *now reads* `*disabled`*. Put the computer to sleep to confirm the monitor stays off.*

        ### 3. Make the Fix Permanent (Survive Reboots)

        Because `/proc/acpi/wakeup` resets on restart, create a `systemd` service to automatically disable the USB wake trigger on boot.

        **Step A:** Create the service file:

        ```bash
        sudo nano /etc/systemd/system/disable-usb-wake.service
        ```

        **Step B:** Paste the following configuration into the file:

        ```text
        [Unit]
        Description=Disable USB wake triggers in /proc/acpi/wakeup
        After=multi-user.target
        [Service]
        Type=oneshot
        ExecStart=/bin/sh -c "grep -q '^XHCI.*enabled' /proc/acpi/wakeup && echo XHCI > /proc/acpi/wakeup || true"
        RemainAfterExit=yes
        [Install]
        WantedBy=multi-user.target
        ```

        *(To save and exit in nano: Press* `Ctrl+O`*,* `Enter`*, then* `Ctrl+X`*)*

        **Step C:** Enable and start the service:

        ```bash
        sudo systemctl enable disable-usb-wake.service
        sudo systemctl start disable-usb-wake.service
        ```

        ***Optional Troubleshooting:*** *If the issue persists after disabling* `XHCI`*, check the* `cat /proc/acpi/wakeup` *list for enabled PCIe slots (like* `PEG0` *or* `PEG2`*, which connect to the GPU). You can temporarily toggle them using the same echo command in Step 2 to see if the GPU polling the monitor is the culprit.*

    - Remove Thunderbird, LibreOffice, and Drawing

        ### 1. Remove Thunderbird

        Thunderbird is the default mail client. To remove the application and its system-wide settings:

        Bash

        `sudo apt purge thunderbird*`

        ### 2. Remove LibreOffice

        LibreOffice is a suite of multiple applications (Writer, Calc, Impress, etc.). To ensure every component is removed, it is best to use a wildcard:

        Bash

        `sudo apt purge libreoffice*`

        ### 3. Remove Drawing

        Drawing is the simple image editor often pre-installed in Mint.

        Bash

        `sudo apt purge drawing`

        ---

        ### 4. Final Cleanup

        After purging the packages, you should run the following commands to delete any leftover dependencies that are no longer needed and to clear the package cache.

        - **Remove orphan dependencies:**Bash

            `sudo apt autoremove`

        - **Clear the local repository of retrieved package files:**

        Bash

        ```text
        `sudo apt clean
          ```
        ```

        ### Optional: Removing Local User Data

        The commands above remove the software and system-level configurations, but they usually leave your personal data (like emails in Thunderbird or local settings) inside your "Home" folder. If you want a truly "fresh" start, you can manually delete these hidden directories:

        > [!WARNING]
        This will permanently delete your emails, local LibreOffice templates, and app preferences.

        ```bash
        rm -rf ~/.thunderbird
        rm -rf ~/.config/libreoffice
        rm -rf ~/.config/drawing`
        **Pro-tip:** If you ever feel like the terminal is judging your typing speed (it isn't, but it feels like it), you can combine the purge commands into one long line:
        `sudo apt purge thunderbird* libreoffice* drawing -y`
        ```

    - Theming

        [Untitled](https://www.gnome-look.org/browse?cat=133&ord=latest)[Untitled - Notes](../Weblinks/Untitled%20(12).md)

    - Terminal command for bulk conversion from Word (libreoffice) to PDF.

        When you switch from the system-installed (`apt`) version of LibreOffice to the **Flatpak** version, the terminal command changes because Flatpaks run in a sandboxed environment.

        Here is the summarized workflow to get your bulk conversion running again:

        ### 1. The New Command Syntax

        The standard `libreoffice` command is no longer in your "path." You must now call the Flatpak ID.

        - **Old:** `libreoffice --headless ...`

        - **New:** `flatpak run org.libreoffice.LibreOffice --headless --convert-to pdf target_file.docx`

        ### 2. Bulk Conversion Loop (Flatpak Version)

        Because you are using a loop, you need to ensure the Flatpak command is called for every file. Navigate to the folder containing your Word documents and run:

        ```bash
        for f in *.docx; do flatpak run org.libreoffice.LibreOffice --headless --convert-to pdf "$f"; done
        ```

        ### 3. Creating a Permanent Alias (Highly Recommended)

        Since the Flatpak command is long and tedious to type, you should map it back to a simple shortcut. This will make it behave exactly like the version you deleted.

        1. Open your bash configuration:Bash

            `nano ~/.bashrc`

        2. Scroll to the bottom and add this line:Bash

            `alias libreoffice='flatpak run org.libreoffice.LibreOffice'`

        3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

        4. Reload the config:Bash

            `source ~/.bashrc`

        **Now your original command will work again:**

        `libreoffice --headless --convert-to pdf *.docx`

        ---

        ### Troubleshooting: "Source file could not be loaded"

        If you still get the "source file could not be loaded" error while using the Flatpak, it is usually a **sandboxing permission issue**. Flatpaks sometimes cannot "see" files outside of your standard `Documents` folder.

        **The Fix:**

        Give LibreOffice permission to access your entire home directory by running this once:

        Bash

        `flatpak override --user --filesystem=home org.libreoffice.LibreOffice`

        > **Note:** The `javaldx` warning you saw earlier should disappear with the Flatpak version, as Flatpaks bundle all necessary Java dependencies inside their own container.

    - Installing HP LaserJet P1102W Printer

        Here are the complete instructions to install and configure your HP LaserJet P1102W on Linux Mint.

        The HP LaserJet P1102W is a "host-based" printer, which means it requires a proprietary binary plugin (firmware) from HP to function correctly on Linux. Fortunately, Linux Mint's package manager and the HP Linux Imaging and Printing (HPLIP) tool make this process straightforward.

        ### Phase 1: Install Required Software

        First, you need to install the HPLIP drivers and the graphical setup interface.

        1. Open your **Terminal** (`Ctrl` + `Alt` + `T`).

        2. Update your package list by running:

        ```bash
        sudo apt update
        ```

        1. Install HPLIP and its GUI component:

        ```bash
        sudo apt install hplip hplip-gui
        ```

        ---

        ### Phase 2: Initial USB Installation & Plugin Setup

        Even if you plan to use the printer over Wi-Fi, it is highly recommended to perform the initial setup via USB. This ensures the proprietary plugin is successfully downloaded and transferred to the printer.

        1. Connect the HP LaserJet P1102W to your computer using a **USB cable** and ensure the printer is turned **on**.

        2. In the terminal, launch the HP setup utility in interactive mode:

        ```bash
        sudo hp-setup -i
        ```

        1. **Select Connection Type:** Press `0` for **USB** and hit Enter.

        2. **Download the Plugin:** The setup will detect that the P1102W needs a proprietary plugin. When prompted to download and install the plug-in, press `d` (to download) or `y` (for yes).

        3. **Accept the License:** Read through the HP proprietary license agreement and accept it by pressing `y`.

        4. **Complete Setup:** Accept the default names and queues provided by the prompt. When asked if you want to print a test page, enter `y` to confirm the printer is successfully communicating with your system.

        If you only want to use the printer via USB, you are done!

        ---

        ### Phase 3: Wireless Setup (Optional)

        If you want to use the printer over your Wi-Fi network, follow these additional steps after confirming the USB connection works.

        1. Keep the printer connected via USB.

        2. Open the **HP Device Manager** from your Linux Mint application menu (or run `hp-toolbox` in the terminal).

        3. Select your P1102W printer from the list on the left.

        4. Navigate to the **Network** or **Wireless Setup** tab.

        5. Follow the on-screen prompts to select your Wi-Fi network (SSID) and enter your Wi-Fi password. The tool will push these credentials to the printer.

        6. Once the printer's blue wireless light goes solid (indicating a successful network connection), **disconnect the USB cable**.

        7. Open the terminal and run the graphical setup utility to add the wireless queue:

        ```bash
        hp-setup
        ```

        1. Choose **Network/Ethernet/Wireless** as the connection type.

        2. Select your newly networked P1102W from the discovered devices list and finish the wizard to add the wireless printer to Linux Mint. You can safely delete the old USB print queue from your system settings once the wireless queue is functioning.

        ---

        ### Troubleshooting Tips

        - **Plugin Download Fails:** If `hp-setup` fails to download the plugin or gives you a "checksum error," run `hp-plugin -i` in the terminal to force the plugin downloader to run on its own.

        - **Printer Unresponsive After Reboot:** Because the P1102W has no internal memory for the driver, HPLIP pushes the firmware to the printer every time it is powered on. If it stops responding, simply power cycle the printer (turn it off, wait 5 seconds, and turn it back on) to re-trigger the firmware upload. Ensure your user is part of the `lp` group to avoid permission issues.

    - 

- Installing [Winboat](https://www.winboat.app/) dependencies

    ## Hardware & BIOS Prerequisites

    Before installing the software packages, ensure your machine is ready to handle the containerized environment:

    - **Virtualization:** KVM must be enabled in your computer's BIOS/UEFI settings (look for AMD-V, SVM, VT-x, or VMX).

    - **System Resources:** At least 4 GB of RAM (8 GB recommended), 2 CPU threads, and 32 GB of free storage space.

    ---

    ## Software Dependencies

    Winboat relies on Docker to build and run the virtual environment and FreeRDP to display the Windows apps natively on your Linux desktop. While Podman is technically supported, Docker is heavily recommended for the most stable experience—especially if you intend to use USB passthrough.

    1. **Update Your System:**
    Open your terminal and ensure your package lists are entirely up to date:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

    1. **Install Docker and Docker Compose:**
    Linux Mint 22.x (which is based on Ubuntu 24.04) has the required Docker packages available directly in its default repositories. Run the following command:

    ```bash
    sudo apt install -y docker.io docker-compose-v2
    ```

    1. **Start and Enable the Docker Service:** Ensures Docker runs on boot.
    Start the Docker daemon and configure it to launch automatically alongside your system:

    ```bash
    sudo systemctl enable --now docker
    ```

    1. **Add Your User to the Docker Group:** Skipping this will cause permission errors.
    Winboat needs to interact with Docker without root privileges. Add your current user account to the `docker` group:

    ```bash
    sudo usermod -aG docker $USER
    ```

    To apply these permission changes immediately without having to log out and back in, refresh the group:

    ```bash
    newgrp docker
    ```

    1. **Install FreeRDP 3:**
    Winboat requires FreeRDP to seamlessly display the Windows environment with sound support. Install version 3:

    ```bash
    sudo apt install -y freerdp3-x11
    ```

    1. **Load Kernel Modules:** Optional but recommended for network handling.
    To ensure better shared filesystem performance and network autodiscovery, load the necessary `iptables` modules:

    ```bash
    sudo modprobe ip_tables
    sudo modprobe iptable_nat
    ```

    Once these dependencies are fully configured, you can download the latest Winboat `.deb` package directly from their official site and double-click to install it. When you launch Winboat for the first time, it will recognize that your system meets all the prerequisites and automatically begin downloading and optimizing the Windows container in the background.

    [Winboat: Seamlessly Run Windows Apps on Linux](https://www.youtube.com/watch?v=N2nVDXj8GmQ)
    This walkthrough provides a clear visual demonstration of how to configure your virtual machine settings and launch applications once your base system is ready.

- Nemo File Manager Reset

    ### Method 1: The Graphical Way (Folder by Folder)

    If you only want to fix a specific folder that is misbehaving:

    1. Open the directory displaying the wrong size.

    2. Click **Edit** or **View** in the top menu bar.

    3. Select **Reset View to Defaults**. It will instantly snapshot back to your global preference (e.g., your 66% List View default seen in `image_f6f0e9.png`).

    ### Method 2: Reset All Folders Universally (Recommended)

    To wipe out all per-folder layout and zoom memory across your entire system, you can clear Nemo's cached metadata directory.

    1. Close all active Nemo windows.

    2. Open a terminal and run the following command to rename your existing GVFS metadata folder (this is a safe backup precaution):

    ```bash
    mv ~/.local/share/gvfs-metadata ~/.local/share/gvfs-metadata.bak
    ```

    1. Restart Nemo.

    Every single directory will now cleanly obey the global rules you established in the menu shown in `image_f6f0e9.png`. If you ever manually use `Ctrl` + `Scroll Wheel` to resize a specific folder again, Nemo will start remembering that folder's specific size until you reset it.

    - Terminal command for bulk conversion from Word (libreoffice) to PDF.

        When you switch from the system-installed (`apt`) version of LibreOffice to the **Flatpak** version, the terminal command changes because Flatpaks run in a sandboxed environment.

        Here is the summarized workflow to get your bulk conversion running again:

        ### 1. The New Command Syntax

        The standard `libreoffice` command is no longer in your "path." You must now call the Flatpak ID.

        - **Old:** `libreoffice --headless ...`

        - **New:** `flatpak run org.libreoffice.LibreOffice --headless --convert-to pdf target_file.docx`

        ### 2. Bulk Conversion Loop (Flatpak Version)

        Because you are using a loop, you need to ensure the Flatpak command is called for every file. Navigate to the folder containing your Word documents and run:

        ```bash
        for f in *.docx; do flatpak run org.libreoffice.LibreOffice --headless --convert-to pdf "$f"; done
        ```

        ### 3. Creating a Permanent Alias (Highly Recommended)

        Since the Flatpak command is long and tedious to type, you should map it back to a simple shortcut. This will make it behave exactly like the version you deleted.

        1. Open your bash configuration:Bash

            `nano ~/.bashrc`

        2. Scroll to the bottom and add this line:Bash

            `alias libreoffice='flatpak run org.libreoffice.LibreOffice'`

        3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

        4. Reload the config:Bash

            `source ~/.bashrc`

        **Now your original command will work again:**

        `libreoffice --headless --convert-to pdf *.docx`

        ---

        ### Troubleshooting: "Source file could not be loaded"

        If you still get the "source file could not be loaded" error while using the Flatpak, it is usually a **sandboxing permission issue**. Flatpaks sometimes cannot "see" files outside of your standard `Documents` folder.

        **The Fix:**

        Give LibreOffice permission to access your entire home directory by running this once:

        Bash

        `flatpak override --user --filesystem=home org.libreoffice.LibreOffice`

        > **Note:** The `javaldx` warning you saw earlier should disappear with the Flatpak version, as Flatpaks bundle all necessary Java dependencies inside their own container.

    - If HP LaserJet P1102W printer does not print…

        It sounds like you're running into a common driver issue with that printer model on Linux. That error message typically means that a required proprietary plugin is missing. Your HP LaserJet P1102w needs a special piece of software to function correctly, which isn't included in the standard Linux Mint drivers.

        The solution is to install HP's official Linux drivers, known as **HPLIP** (HP Linux Imaging and Printing), and then use its tool to download the necessary plugin.

        ---

        ### The Solution: Install the HPLIP Plugin

        Here is a step-by-step guide to get your printer working. The easiest way is to use the software already available in your system's repository.

        ### Step 1: Install the HPLIP GUI

        First, open a terminal window. You can usually find it in your menu or by pressing `Ctrl+Alt+T`. Then, run the following command to make sure you have the HPLIP software and its graphical user interface installed.

        ```bash
        sudo apt update && sudo apt install hplip-gui
        ```

        Enter your password when prompted. This command updates your software lists and then installs the `hplip-gui` package, which includes all the tools you'll need.

        ### Step 2: Run the HP Device Manager Setup

        With HPLIP installed, you now need to run a setup command that will detect your printer and download the missing plugin. Keep your printer turned on and connected to your computer (either via USB or on the same Wi-Fi network).

        Run this command in the terminal:

        ```bash
        hp-setup
        ```

        ### Step 3: Follow the On-Screen Instructions

        A graphical setup wizard will appear.

        1. **Connection Type:** Choose how your printer is connected (USB or Network/Wireless). Click **Next**.

        2. **Select Device:** The tool will search for your printer. Select the **HP LaserJet P1102w** from the list of discovered devices and click **Next**.

        3. **Plugin Installation:** This is the most important step. The wizard will inform you that the printer requires a proprietary plugin. You must agree to the terms and proceed with the download and installation. An internet connection is required for this.

        4. **Finalize:** Once the plugin is installed, you can give your printer a name and description, and print a test page to confirm it's working.

        After completing these steps, the "problem processing document" error should be resolved, and your printer should work perfectly. You can manage the printer in the future by opening the **HP Device Manager** application from your system menu.

    - Setting up L3560 Epson Printer

        Setting up an **Epson L3560** EcoTank printer on Linux Mint 22.3 (Cinnamon) is a straightforward process. Because Linux Mint 22.3 is built on an **Ubuntu 24.04 LTS (Noble Numbat)** package base, you can easily use official Epson `.deb` driver packages.

        Here is a step-by-step framework to get both your **printing** and **scanning** functions up and running smoothly.

        ---

        ## Step 1: Connect the Printer to Your Network or PC

        Before starting with the drivers, ensure your printer can communicate with your computer:

        - **Wi-Fi Connection (Recommended):** Connect the L3560 to your local Wi-Fi network using its physical control panel. Note down its local IP address if you plan to assign a static lease in your router settings later.

        - **USB Connection:** If you prefer wires, plug the printer directly into an available USB port.

        ---

        ## Step 2: Download and Install the Printer Driver

        Epson uses a centralized download site for Linux drivers.

        1. Go to the official [Epson Download Center](https://download-center.epson.com/).

        2. Type `L3560` into the search bar and select **Linux** as your operating system.

        3. Look for the **Printer Driver** package (typically named `epson-inkjet-printer-escpr` or `escpr2`).

        4. Download the 64-bit Debian package, which will have a `.deb` extension (e.g., `_amd64.deb`).

        5. Open your terminal, navigate to your `Downloads` directory, and install the package using `apt` (which will automatically handle any missing dependencies):

        ```bash
        cd ~/Downloads
        sudo apt install ./epson-inkjet-printer*.deb
        ```

        ---

        ## Step 3: Add the Printer via Linux Mint GUI

        Once the driver package is installed, Mint's CUPS (Common Unix Printing System) will recognize the device.

        1. Open the **Mint Menu** and search for **Printers**.

        2. Click the **Add** button.

        3. **For Network Printers:** Wait a moment for network discovery. Under *Network Printer*, select your **Epson L3560** (it may appear as an `IPP`, `mDNS`, or `Driverless` network device).

        4. **For USB Printers:** Select the L3560 entry under the local ports list.

        5. Click **Forward**. Linux Mint should automatically look for the driver you just installed, match it to the L3560, and complete the setup.

        6. Print a test page to verify it works.

        ---

        ## Step 4: Install the Scanner Driver (Epson Scan 2)

        The L3560 is an all-in-one device, so you'll want to get the flatbed scanner operational.

        1. Go back to the **Epson Download Center** search results for the L3560.

        2. Download the **Epson Scan 2** bundle for Linux (again, grab the 64-bit `.deb` version).

        3. This download is often a `.tar.gz` archive containing an automated installation script. Extract it and run the script in your terminal:

        ```bash
        tar -xvf epson-scan2*.tar.gz
        cd epson-scan2*
        sudo ./install.sh
        ```

        1. Once installed, open Mint's default scanning utility, **Document Scanner** (Simple Scan), or launch **Epson Scan 2** from your application menu.

        > 💡 **Network Scanning Note:** If your scanner isn't detected immediately over Wi-Fi, open the terminal and open the Epson configuration file (`sudo nano /etc/imagescan/imagescan.conf` or the corresponding Epson Scan 2 config tool) to explicitly add your printer's static IP address under the network section.

        ---

        ## Troubleshooting Tips

        - **Missing LSB Dependency:** If the `.deb` package complains about a missing `lsb` package (a legacy dependency occasionally found in older Epson driver builds), you can resolve it by installing the compatibility package:

        ```bash
        sudo apt install lsb-compat
        ```

        - **Firewall Issues:** If Mint cannot find your network printer, check if your local firewall (`ufw`) is blocking network discovery. You can temporarily toggle it off to test:

        ```bash
        sudo ufw disable
        ```

        If it works with the firewall off, turn it back on (`sudo ufw enable`) and ensure ports `631` (CUPS) and `5353` (mDNS/Avahi) are allowed through.

    - Disabling Hibernation (via terminal)

        For users who prefer to disable the hibernation feature in Linux Mint, the most reliable methods involve using the command line. While graphical settings to completely turn off hibernation are generally not available in the standard Power Management options, the following command-line instructions provide a straightforward and effective way to achieve this.

        ---

        ### **Recommended Method: Using systemctl**

        The most direct way to disable hibernation is by using the systemctl command to mask the hibernation service. This prevents the system from being able to enter hibernation.

        1. **Open a terminal:** You can do this by pressing Ctrl+Alt+T on your keyboard.1

        2. **Mask the hibernation service:** Type the following command into the terminal and press Enter. This will prevent the hibernation service from being started.

            ```jsx
            sudo systemctl mask hibernate.target
            ```

        3. **Enter your password** when prompted. Note that you will not see any characters as you type your password.

        After executing this command, the hibernation option will be disabled.

        ---

        ### **How to Verify Hibernation is Disabled**

        To confirm that the hibernation service has been successfully disabled, you can check its status with the following command:

        ```jsx
        sudo systemctl status hibernate.target
        ```

        If it has been successfully masked, you will see output indicating that the service is "masked".

        ---

        ### **Re-enabling Hibernation**

        Should you wish to re-enable hibernation in the future, you can do so by "unmasking" the service.2

        1. **Open a terminal.**

        2. **Unmask the hibernation service:** Enter the following command:

            ```jsx
            sudo systemctl unmask hibernate.target
            ```

        ---

        ### **Alternative Method: Using Polkit Rules**

        Another effective way to disable hibernation is by creating a polkit rule. This method revokes the permission for users to perform hibernation.

        1. **Open a terminal.**

        2. **Create a new polkit rule file:** Use the following command to create and open a new file in a text editor:

            ```jsx
            sudo nano /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla
            ```

        3. **Add the following content** to the file:

            > Ini, TOML

            [Disable hibernate]

            Identity=unix-user:*

            Action=org.freedesktop.login1.hibernate

            ResultActive=no

        4. **Save and close the file:** Press Ctrl+X, then Y, and then Enter to save the changes in the nano text editor.

        After a reboot, the hibernation option should no longer be available. To re-enable hibernation using this method, you would simply delete the file you created.

        - 


    - Uninstalling LibreOffice, Thunderbird, and Drawing

        To completely remove these applications from Linux Mint Cinnamon, you will need to purge the system packages, clear out their orphaned dependencies, and manually delete the hidden user configuration files they leave behind.

        1. **Purge the system packages:** Removes the applications and global settings.
        Run this command in your terminal. Using the quotes and `*` wildcards ensures that all associated language packs, math modules, and extensions are caught:

        ```bash
        sudo apt purge "libreoffice*" "thunderbird*" drawing
        ```

        1. **Remove orphaned dependencies:** Cleans up background libraries.
        Once the main applications are gone, tell the package manager to remove any leftover libraries that those apps previously relied on:

        ```bash
        sudo apt autoremove --purge
        ```

        1. **Delete personal configuration files:** Wipes your local user data.
        The `apt purge` command removes system-wide configurations, but intentionally leaves your personal data intact. To achieve a truly complete removal, delete the hidden folders in your home directory:

        ```bash
        rm -rf ~/.thunderbird ~/.config/libreoffice ~/.local/share/drawing ~/.config/drawing
        ```

        > **Note on Flatpaks:** Linux Mint's Software Manager offers both system packages (DEB) and Flatpaks. The commands above remove the default system packages. If you installed any of these as Flatpaks instead, you can completely remove them by running:
        `flatpak uninstall --delete-data org.libreoffice.LibreOffice org.mozilla.Thunderbird com.github.maoschanz.drawing`

- Formating time and date in toolbar

    ```text
    %A, %B%e, %Y · %l:%M %p
    ```

## Links

[Best Linux Microsoft Office Alternatives](https://www.youtube.com/watch?v=pwWlYdz-qhk)[[Best Linux Microsoft Office Alternatives|Best Linux Microsoft Office Alternatives - Notes]]

[Things that bother me about Linux Mint - still the best Linux distribution?](https://www.youtube.com/watch?v=HhN5z-DPRXQ)[Things that bother me about Linux Mint - still the best Linux distribution? - Notes](../Weblinks/Things%20that%20bother%20me%20about%20Linux%20Mint%20-%20still%20the%20best%20Linux%20distribution.md)

[Untitled](https://www.gnome-look.org/browse?cat=133&ord=latest)[Untitled - Notes](../Weblinks/Untitled%20(10).md)

[Untitled](https://www.opendesktop.org/s/cinnamon/)[Untitled - Notes](../Weblinks/Untitled%20(11).md)

[Themes](https://cinnamon-spices.linuxmint.com/themes)[[Themes|Themes - Notes]]

## Misc

- Issue with second monitor not waking up

    First create a small resume script:

    ```bash
    sudo nano /usr/lib/systemd/system-sleep/monitor-wakeup
    ```

    Paste this:

    ```bash
    #!/bin/bash
    case "$1" in
      post)
        sleep 3
        su - ben -c 'DISPLAY=:0 XAUTHORITY=/home/ben/.Xauthority xrandr --auto'
        ;;
    esac
    ```

    Save with `Ctrl+O`, press Enter, then exit with `Ctrl+X`.

    Make it executable:

    ```bash
    sudo chmod +x /usr/lib/systemd/system-sleep/monitor-wakeup
    ```

    Then test it by suspending the computer normally and waking it again.

    The `sleep 3` is intentional. Some monitors take a couple of seconds to advertise themselves to the graphics driver after resume. If the problem still occasionally happens, try changing it to:

    ```bash
    sleep 5
    ```

    One caveat: this exact script assumes you're running an **X11 Cinnamon session**, which is common on Linux Mint. You can confirm with:

    ```bash
    echo $XDG_SESSION_TYPE
    ```

    If it returns `x11`, this approach is appropriate. If it returns `wayland`, don't use the script above; tell me and I'll give you the Wayland-specific method.

    You can also test the script manually before suspending:

    ```bash
    sudo /usr/lib/systemd/system-sleep/monitor-wakeup post
    ```

    Your screens may briefly refresh.

    Since `xrandr --auto` already solves it reliably, I would use this automatic resume method before changing kernel parameters or graphics drivers.

- Dual Monitor "No Wake" Fix (Linux Mint 22.3)

    - Alternative

        You can make this automatic by running an `xrandr` “re-handshake” script **on resume**. On Linux Mint the most reliable method is a **systemd sleep hook** (runs every time the system wakes), plus a small wrapper that targets your X session.

        Below is a setup that works well on Cinnamon/X11 (most common Mint setup).

        ---

        ## 1) Create the re-handshake script

        ```bash
        mkdir -p ~/.local/bin
        nano ~/.local/bin/monitor-wake.sh
        ```

        Paste (adjust the `--right-of` if your layout differs):

        ```bash
        #!/usr/bin/env bash
        # Re-enable HDMI-1 after resume
        xrandr --output HDMI-1 --off
        sleep 1
        xrandr --output HDMI-1 --auto --right-of HDMI-2
        ```

        Make it executable:

        ```bash
        chmod +x ~/.local/bin/monitor-wake.sh
        ```

        Test it (while logged in, not over SSH):

        ```bash
        ~/.local/bin/monitor-wake.sh
        ```

        ---

        ## 2) Add a systemd “resume” hook (runs after sleep)

        Create a system-sleep hook:

        ```bash
        sudo nano /lib/systemd/system-sleep/monitor-wake
        ```

        Paste this (important: change `ben` to your Linux username if different):

        ```bash
        #!/bin/sh
        # systemd calls this with: pre|post  and suspend|hibernate|...
        # We only want to run AFTER resume:
        if [ "$1" = "post" ]; then
          # Run the command inside the logged-in user session, targeting the X display.
          su - ben -c 'export DISPLAY=:0; export XAUTHORITY=/home/ben/.Xauthority; ~/.local/bin/monitor-wake.sh'
        fi
        ```

        Make it executable:

        ```bash
        sudo chmod +x /lib/systemd/system-sleep/monitor-wake
        ```

        Now suspend and wake to test.

        ---

        ## Notes / common gotchas

        - This approach assumes you’re on **X11** (Cinnamon “normal” session). If you’re on **Wayland**, `xrandr` won’t work the same way.

            - Check:

                ```bash
                echo $XDG_SESSION_TYPE
                ```

        - If `DISPLAY=:0` doesn’t work on your machine (rare, but possible), tell me what that command prints and I’ll adjust it.

        ---

        If you want, paste the output of:

        ```bash
        echo $XDG_SESSION_TYPE
        ```

        and I’ll tailor the hook to your exact session type (X11 vs Wayland) and make sure it’s bulletproof.

    Here is a structured summary of the troubleshooting steps for your dual-monitor sleep issue.

    ---

    ### 1. Reset Monitor Configuration

    Often, the display configuration file becomes corrupted or saves an "off" state for the secondary monitor.

    - **Action:** Delete or rename the Cinnamon-specific monitor XML.

    - **Terminal Command:**Bash

        `mv ~/.config/cinnamon-monitors.xml ~/.config/cinnamon-monitors.xml.bak
          mv ~/.config/cinnamon-monitors.xml~ ~/.config/cinnamon-monitors.xml-temp.bak`

    - **Next Step:** Reboot the system and re-configure displays in **System Settings > Display**.

    ### 2. Manual Handshake (xrandr)

    If the monitor stays black after wake, you can force the OS to re-scan the ports without rebooting.

    - **Check Status:** `xrandr --listmonitors`

    - **Force Turn On:**Bash

        `# Example: If HDMI-1 is the dark monitor
          xrandr --output HDMI-1 --auto --right-of eDP-1`

    ### 3. Session Type Check (Wayland vs. X11)

    Newer Mint bases may default to Wayland, which handles power states differently than the traditional X11.

    - **Check Session:** `echo $XDG_SESSION_TYPE`

    - **Workaround:** If on Wayland, log out and select the standard **"Cinnamon"** (X11) session at the login screen. X11 is generally more stable for persistent multi-monitor wake signals.

    ### 4. GPU & Driver Diagnostics

    The fix often depends on whether you are using NVIDIA, AMD, or Intel drivers.

    - **Identify Hardware:** `lspci -k | grep -EA3 'VGA|3D'`

    - **NVIDIA Fix:** Ensure `nvidia-suspend`, `nvidia-resume`, and `nvidia-hibernate` services are enabled:Bash

        `sudo systemctl enable nvidia-suspend.service nvidia-resume.service`

    ### 5. Log Analysis for "Wake" Failures

    To find the specific error (e.g., "EDID checksum invalid"), run these immediately after a failed wake event:

    - **Kernel Logs:** `dmesg | tail -n 50`

    - **System Logs:** `journalctl -b 0 | grep -iE "drm|display|monitor" | tail -n 20`

    ### 6. Hardware Troubleshooting

    - **Monitor OSD:** Disable "Deep Sleep" or "Power Save" mode in the monitor’s physical button menu.

    - **Cable Swap:** If using DisplayPort, try HDMI (or vice versa). DisplayPort is more prone to "forgetting" the connection state during low-power modes.

    ---

    Does the other PC use the same graphics card, or is it a different brand?

- LibreOffice-Word Compatibility

    Here is a **clean, step‑by‑step LibreOffice → Microsoft Word compatibility setup tutorial** you can paste directly into your Notion notes.

    ---

    # 📝 LibreOffice → Microsoft Word Compatibility Setup (Linux Mint)

    This configuration minimizes formatting drift, page‑count changes, citation movement, and table misalignment when exchanging `.docx` files with Microsoft Word users.

    ---

    # ✅ 1. Fix DOCX File Association in Linux Mint

    Ensure `.docx` files open in **LibreOffice Writer**, not Calibre or another app.

    ### Run in Terminal:

    xdg-mime default libreoffice-writer.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document

    ---

    # ✅ 2. Set DOCX as Default Save Format

    Open:

    ```text
    Tools → Options → Load/Save → General
    ```

    Set:

    ```text
    Document Type: Text Document
    Always Save As: Microsoft Word 2007–365 (.docx)
    ```

    Click **OK**

    ---

    # ✅ 3. Enable Microsoft Office Compatibility Options

    Go to:

    ```text
    Tools → Options → Load/Save → Microsoft Office
    ```

    Enable:

    - ✔ Load user‑defined styles from Word documents

    - ✔ Import Word spacing as Word does

    - ✔ Export bookmarks as Word bookmarks

    - ✔ Use OOXML strict format

    ---

    # ✅ 4. Enable Word Layout Compatibility Mode

    Go to:

    ```text
    Tools → Options → LibreOffice Writer → Compatibility
    ```

    Enable:

    - ✔ Use printer metrics for document formatting

    - ✔ Add spacing between paragraphs and tables

    - ✔ Use Word‑compatible line spacing

    - ✔ Treat outline numbering as Word does

    - ✔ Expand word space on justified lines

    - ✔ Do not add leading (extra spacing)

    Click **OK**

    ---

    # ✅ 5. Install Microsoft‑Compatible Fonts (Critical)

    Install Word‑metric‑compatible fonts to prevent layout shifts.

    ### Run:

    sudo apt install ttf-mscorefonts-installer

    sudo apt install fonts-crosextra-carlito fonts-crosextra-caladea

    ---

    # ✅ 6. Match Word’s Layout Engine Using Font Substitutes

    LibreOffice needs to match Word’s internal theme fonts:

    | Word Theme Role | Word Font | LibreOffice Substitute |
    | :-------------- | :-------- | :--------------------- |
    | Body Text       | Cambria   | Caladea                |
    | Headings        | Calibri   | Carlito                |

    ---

    # ✅ 7. Set LibreOffice Default Fonts

    Go to:

    ```text
    Tools → Options → LibreOffice Writer → Basic Fonts
    ```

    Set:

    | Category | Font    |
    | :------- | :------ |
    | Default  | Caladea |
    | Heading  | Carlito |
    | List     | Carlito |
    | Caption  | Caladea |
    | Index    | Caladea |

    Click **OK**

    ---

    # ✅ 8. Apply Word Layout Mode Per Document

    After opening a `.docx` file:

    ```text
    File → Properties → Compatibility
    ```

    Enable:

    ```text
    Use Word 2007/2010/2013 layout mode
    ```

    Save the document.

    ---

    # ✅ 9. Disable ODF Format Warning (Optional)

    To stop warnings when working in DOCX:

    ```text
    Tools → Options → LibreOffice → Warnings
    ```

    Uncheck:

    ```text
    Not using ODF format
    ```

    ---

    # ✅ 10. Always Use “Save As” for DOCX Exchange

    Use:

    ```text
    File → Save As → .docx
    ```

    Avoid:

    ```text
    File → Export As
    ```

    Export is one‑way and may introduce formatting drift.

    ---

    # ✅ Result

    LibreOffice will now:

    - Preserve Word pagination

    - Maintain table widths

    - Prevent citation and caption movement

    - Maintain heading spacing

    - Reduce DOCX round‑trip layout changes

    ---

    You can now reliably exchange `.docx` files between LibreOffice and Microsoft Word with minimal formatting loss.

- Connecting Bose speaker via bluetoothTus próximos informes deben tener las siguientes fechas (si trabaja de forma continua): 10/06/2026 y 09/07/2026, etc.

    No worries—let’s wipe the slate clean and set this up on **Linux Mint** from scratch. We’ll (1) pair & trust the Bose, (2) make BlueZ auto-enable, (3) create a robust connect script that waits for Bluetooth to be ready, switches audio to A2DP, and (4) run it at login with a **systemd user** service. This approach is reliable whether your Mint is using PulseAudio or PipeWire.

    ---

    # Step 0 — Clean up any previous attempts (safe)

    If you tried other guides, remove/disable them so nothing conflicts.

    ```bash
    # Remove any Startup Applications entry you created (do it in the GUI as well)
    # Disable any previous systemd user service you added
    systemctl --user disable --now bose-autoconnect.service 2>/dev/null || true
    rm -f ~/.config/systemd/user/bose-autoconnect.service
    # Remove any old script if present
    rm -f ~/connect_bose.sh
    ```

    ---

    # Step 1 — Install the right Bluetooth/audio bits

    Mint works with both PulseAudio and PipeWire; these commands cover both.

    ```bash
    sudo apt update
    # Core Bluetooth + audio control tools
    sudo apt install -y bluez pulseaudio-utils pavucontrol
    # If your Mint uses PipeWire (many do), ensure BT pieces are present:
    sudo apt install -y pipewire-audio-client-libraries libspa-0.2-bluetooth
    ```

    > You don’t need to switch audio servers—these just make sure the Bluetooth profiles/sinks are available.

    ---

    # Step 2 — Pair & trust the Bose (one-time setup)

    1. Put your **Bose Flex SE SoundLink** in pairing mode.

    2. Run:

    ```bash
    bluetoothctl
    ```

    Inside the `bluetoothctl` prompt, do this (copy/paste lines one by one):

    ```text
    power on
    agent on
    default-agent
    scan on
    # wait until you see "AC:BF:71:AD:C5:92" appear (your Bose), then:
    pair AC:BF:71:AD:C5:92
    trust AC:BF:71:AD:C5:92
    connect AC:BF:71:AD:C5:92
    scan off
    quit
    ```

    > If “pair” fails because the speaker is connected elsewhere (phone, etc.), disconnect it from other devices or clear the Bose pairing list (usually hold the Bluetooth button ~10 sec until you hear it say the list is cleared), then retry.

    ---

    # Step 3 — Make BlueZ auto-enable Bluetooth at boot

    ```bash
    sudo mkdir -p /etc/bluetooth
    sudo sed -i 's/^#\?AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf || echo 'AutoEnable=true' | sudo tee -a /etc/bluetooth/main.conf
    sudo systemctl restart bluetooth
    ```

    ---

    # Step 4 — Create a robust connect script (with retries + audio switch)

    This script waits until Bluetooth is actually powered, connects to your Bose, switches to **A2DP sink**, sets it as default, and moves any playing audio.

    ```bash
    mkdir -p ~/.local/bin
    nano ~/.local/bin/connect_bose.sh
    ```

    Paste this entire script, then save (Ctrl+O, Enter) and exit (Ctrl+X):

    ```bash
    #!/usr/bin/env bash
    # Connect Bose Flex SE SoundLink on login and set as default sink.
    # Device MAC:
    MAC="AC:BF:71:AD:C5:92"
    LOG="$HOME/.cache/bose-autoconnect.log"
    mkdir -p "$(dirname "$LOG")"
    log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG"; }
    # Ensure bluetoothctl exists
    command -v bluetoothctl >/dev/null || { log "bluetoothctl not found"; exit 1; }
    log "=== Bose autoconnect start ==="
    # Wait for bluetooth service to be powered
    for i in {1..20}; do
      if bluetoothctl show | grep -q "Powered: yes"; then
        log "Bluetooth powered."
        break
      fi
      bluetoothctl power on >/dev/null 2>&1
      sleep 1
    done
    # Trust device (harmless if already trusted)
    bluetoothctl trust "$MAC" >/dev/null 2>&1
    # Try to connect up to 10 times
    CONNECTED=0
    for i in {1..10}; do
      if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
        CONNECTED=1
        log "Already connected."
        break
      fi
      log "Connect attempt $i..."
      if bluetoothctl connect "$MAC"; then
        sleep 2
        if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
          CONNECTED=1
          log "Connected successfully."
          break
        fi
      fi
      sleep 3
    done
    if [ "$CONNECTED" -ne 1 ]; then
      log "Failed to connect after retries."
      exit 0  # Don't spam errors; service stays 'successful' but logs the failure.
    fi
    # Try to set A2DP profile and default sink using pactl (works for PulseAudio or PipeWire-pulse)
    # Normalized MAC (colons -> underscores)
    MAC_U=$(echo "$MAC" | tr ':' '_')
    # Prefer A2DP profile if available
    CARD="bluez_card.$MAC_U"
    if pactl list cards short | awk '{print $2}' | grep -qx "$CARD"; then
      pactl set-card-profile "$CARD" a2dp-sink >/dev/null 2>&1 && log "Set card profile to a2dp-sink."
    fi
    # Find the Bose A2DP sink
    SINK=$(pactl list short sinks | awk -v mac="$MAC_U" '/bluez_output\.'mac'.*a2dp/ {print $2; exit}')
    if [ -z "$SINK" ]; then
      # fallback: any bluez_output sink
      SINK=$(pactl list short sinks | awk -v mac="$MAC_U" '/bluez_output\.'mac'/ {print $2; exit}')
    fi
    if [ -n "$SINK" ]; then
      pactl set-default-sink "$SINK" >/dev/null 2>&1 && log "Default sink set to $SINK."
      # Move existing audio streams to the Bose sink
      pactl list short sink-inputs | awk '{print $1}' | while read -r INPUT; do
        pactl move-sink-input "$INPUT" "$SINK" >/dev/null 2>&1 && log "Moved sink-input $INPUT."
      done
    else
      log "No matching bluez sink found."
    fi
    log "=== Bose autoconnect done ==="
    ```

    Make it executable:

    ```bash
    chmod +x ~/.local/bin/connect_bose.sh
    ```

    ---

    # Step 5 — Create a **systemd user** service to run the script on login

    Make the directory (this fixes your previous “No such file or directory” error):

    ```bash
    mkdir -p ~/.config/systemd/user
    nano ~/.config/systemd/user/bose-autoconnect.service
    ```

    Paste this unit, then save and exit:

    ```text
    [Unit]
    Description=Auto-connect Bose Flex SE SoundLink and set as default sink
    # Run after your graphical session has started; the script itself waits for BT readiness
    After=graphical-session.target
    Wants=graphical-session.target
    [Service]
    Type=oneshot
    ExecStart=%h/.local/bin/connect_bose.sh
    RemainAfterExit=yes
    [Install]
    WantedBy=default.target
    ```

    Enable and start it:

    ```bash
    systemctl --user daemon-reload
    systemctl --user enable bose-autoconnect.service
    systemctl --user start bose-autoconnect.service
    ```

    Reboot and it should auto-connect after you log in.

    ---

    # Step 6 — Verify / Troubleshoot

    Useful checks:

    ```bash
    # Status + recent logs for the user service
    systemctl --user status bose-autoconnect.service
    journalctl --user -u bose-autoconnect.service -b
    # Script’s own log
    sed -n '1,200p' ~/.cache/bose-autoconnect.log
    # See if the device is connected
    bluetoothctl info AC:BF:71:AD:C5:92 | grep Connected
    # See current sinks and default
    pactl info | grep "Default Sink"
    pactl list short sinks
    ```

    Common fixes:

    - **Connected to your phone?** Bose often refuses a second connection. Disconnect the phone (or clear pairings on the speaker: hold the **Bluetooth** button ~10 seconds until you hear the prompt), then try:

        ```bash
        bluetoothctl disconnect AC:BF:71:AD:C5:92
        bluetoothctl connect AC:BF:71:AD:C5:92
        ```

    - **rfkill blocked?**

        ```bash
        rfkill list bluetooth
        sudo rfkill unblock bluetooth
        ```

    - **No audio despite “Connected: yes”?** The script tries to switch to A2DP. If it still uses HSP/HFP, open **pavucontrol** → *Playback*/*Output Devices* tabs and set the Bose to **A2DP** once; Mint will remember.

    ---

    ## Optional: Auto-reconnect when the speaker turns on later

    If you often power the Bose on *after* login, the above service will have already run. You can add a small **user timer** to retry every few minutes:

    ```bash
    # Timer unit
    nano ~/.config/systemd/user/bose-autoconnect.timer
    ```

    Paste:

    ```text
    [Unit]
    Description=Periodic Bose connect attempts
    [Timer]
    OnBootSec=2min
    OnUnitActiveSec=5min
    Persistent=true
    [Install]
    WantedBy=timers.target
    ```

    Enable it:

    ```bash
    systemctl --user daemon-reload
    systemctl --user enable --now bose-autoconnect.timer
    ```

    This will re-run the script every 5 minutes (harmless if already connected).

    ---

    Try the steps exactly in order. If anything fails, copy the **two outputs** below and I’ll pinpoint the fix:

    ```bash
    systemctl --user status bose-autoconnect.service
    sed -n '1,200p' ~/.cache/bose-autoconnect.log
    ```

    You’ve got this—once paired & trusted, the service + script combo makes Bose speakers on Mint behave like they should. 💪🔊

    - Automatic updates

        - Use timeshift to revert back to yesterday (March 19, 2025) at 1:00 PM. @

        - GenAI Prompt


        - Instructions (GenAI)

            Alright, let's configure your Linux Mint 22.1 system for automatic, silent updates on a weekly schedule. We'll achieve this using a combination of `apt` configuration and systemd timers.

            Here's a step-by-step guide:

            **1. Configure Automatic Updates with** `unattended-upgrades`

            - **Install** `unattended-upgrades`**:**

                Bash

                ```text
                sudo apt update
                sudo apt install unattended-upgrades
                ```

            - **Configure** `unattended-upgrades`**:**

                - Edit the configuration file:Bash

                    ```text
                    sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
                    ```

                - Make the following changes:

                    - Ensure the `Unattended-Upgrade::Origins-Pattern` section includes the repositories you want to update. Typically, you'll want to include `"${distro_id}:${distro_codename}-security"` and `"${distro_id}:${distro_codename}-updates"`:```
                    Unattended-Upgrade::Origins-Pattern {
                    "origin=Ubuntu,codename=${distro_codename}-security";
                            "origin=Ubuntu,codename=${distro_codename}-updates";
                    "origin=linuxmint,codename=${distro_codename}-security";
                            "origin=linuxmint,codename=${distro_codename}-updates";
                    };

                        ```text
                        
                        ```

                    - To disable automatic reboots, set:```
                    Unattended-Upgrade::Automatic-Reboot "false";

                        ```text
                        
                        ```

                    - To disable automatic reboots if logged in users are present:```
                    Unattended-Upgrade::Automatic-Reboot-WithUsers "false";

                        ```text
                        
                        ```

                    - Save the file (Ctrl+X, Y, Enter).1

            - **Enable Automatic Updates:**

                - Create a configuration file to enable `unattended-upgrades`:Bash

                    ```text
                    sudo nano /etc/apt/apt.conf.d/20auto-upgrades
                    ```

                - Add the following lines:```
                APT::Periodic::Update-Package-Lists "1";
                APT::Periodic::Unattended-Upgrade "1";

                    ```text
                    
                    ```

                - Save the file.

            **2. Configure a Weekly Systemd Timer**

            - **Create a systemd service file:**

                - Create a file for the unattended upgrade service:Bash

                    ```text
                    sudo nano /etc/systemd/system/weekly-unattended-upgrade.service
                    ```

                - Add the following content:```
                [Unit]
                Description=Weekly unattended upgrades

                    [Service]
                    Type=oneshot
                    ExecStart=/usr/bin/unattended-upgrade -v

                    ```text
                    
                    ```

                - Save the file.

            - **Create a systemd timer file:**

                - Create a file for the weekly timer:Bash

                    ```text
                    sudo nano /etc/systemd/system/weekly-unattended-upgrade.timer
                    ```

                - Add the following content:```
                [Unit]
                Description=Weekly unattended upgrade timer

                    [Timer]
                    OnCalendar=weekly
                    Persistent=true

                    [Install]
                    WantedBy=timers.target

                    ```text
                    
                    ```

                - Save the file.

            - **Enable and start the timer:**

                Bash

                ```text
                sudo systemctl enable weekly-unattended-upgrade.timer
                sudo systemctl start weekly-unattended-upgrade.timer
                ```

            - **Verify the timer is running:**

                Bash

                ```text
                systemctl list-timers
                ```

                - You should see your `weekly-unattended-upgrade.timer` listed.

            **3. Suppress Update Notifications**

            - **Disable Update Manager Notifications:**

                - Open the Update Manager.

                - Go to Edit -> Preferences.

                - In the "Auto-Refresh" tab, uncheck "Check for updates".

                - In the "Levels" tab, uncheck all of the boxes.

                - In the "Options" tab, uncheck "Show tray icon".

                - Close the preferences window.

            - **Disable** `mintupdate` **systemd service:**

                - Bash

                    ```text
                    sudo systemctl disable mintupdate.service
                      sudo systemctl stop mintupdate.service
                    ```

            **Explanation**

            - `unattended-upgrades` automatically installs security updates and other updates specified in its configuration.

            - The systemd timer schedules the `unattended-upgrade` command to run weekly.

            - Disabling the Update Manager's notifications and the `mintupdate` service prevents any user-facing prompts for updates.

            **Important Notes**

            - **Reboots:** If kernel updates are installed, you'll still need to reboot your system for them to take effect.

            - **Log Files:** To check if updates are being installed correctly, check the `unattended-upgrades` log file:Bash

                ```text
                sudo less /var/log/unattended-upgrades/unattended-upgrades.log
                ```

            - **Testing:** After setting up the timer, you can test it by manually running the service:Bash

                ```text
                sudo systemctl start weekly-unattended-upgrade.service
                ```

            - **Customization:** You can adjust the `OnCalendar` setting in the timer file to change the update schedule (e.g., daily, specific days of the week). Refer to the `systemd.time` documentation for details.

            - **Risk:** Automatic updates can sometimes cause issues.2 While generally safe for security updates, be aware that package updates can occasionally introduce problems. Regularly check your system's functionality.

            - **Snap and Flatpak:** This configuration only handles `apt` updates. If you use Snap or Flatpak, you'll need to configure their automatic update settings separately.

            - **Mintupdate:** Disabling Mintupdate will prevent you from using the graphical update manager. You will have to use the terminal to install any desired packages.

            By following these steps, you'll have a system that automatically updates each week without any intrusive notifications. Remember to monitor your system logs occasionally to ensure everything is working as expected.



- Icons not fully appearing in panel

    > This solution is when icons do not fully appear in the panel. The issue came up when new web apps were created in Chrome, and then attempting to pin the app to the panel. The icon used was not one that comes with Linux Mint (22.1), but one that was subsequently installed.

    - Quick solution

        - **Clear the XDG Icon Cache (Less Common, but worth trying):**

            Bash

            ```text
            find ~/.local/share/icons/ -name "*.cache" -delete
            ```

            This removes any icon cache files in your user's local icon directory.

        - **Restart Cinnamon (Your Desktop Environment):** The easiest way to do this is to press `Alt` + `F2`, type `r`, and press `Enter`. This restarts the Cinnamon shell, which should force it to reload icons. You can also log out and log back in, or reboot.

        - **Test:** After these steps, unpin and re-pin the Outlook web app to see if the icon displays correctly.

    - Full solution

        This sounds like a frustrating problem with the Chrome web app icon display in Linux Mint's panel. Here's a breakdown of potential causes and solutions, working from the most likely and easiest to check to more complex debugging:

        **1. Icon Cache Issues (Most Likely)**

        - **The Problem:** The most common reason for icon glitches like this is a corrupted or outdated icon cache. Linux Mint (and most Linux desktop environments) maintain a cache of icons for quicker access. Sometimes this cache gets out of sync with the actual icons.

        - **The Solution:**

            - **Clear the GTK Icon Cache:**

                Bash

                ```text
                gtk-update-icon-cache -f /usr/share/icons/your-icon-theme-name/
                ```

                Replace `your-icon-theme-name` with your actual icon theme. You can usually find this in your system settings (Appearance or similar). Common themes include `Mint-Y`, `Adwaita`, etc. If you're unsure, try running:

                Bash

                ```text
                gtk-update-icon-cache -f /usr/share/icons/*
                ```

                This is less precise but will try to update all themes. It may take a little longer.

            - **Clear the XDG Icon Cache (Less Common, but worth trying):**

                Bash

                ```text
                find ~/.local/share/icons/ -name "*.cache" -delete
                ```

                This removes any icon cache files in your user's local icon directory.

            - **Restart Cinnamon (Your Desktop Environment):** The easiest way to do this is to press `Alt` + `F2`, type `r`, and press `Enter`. This restarts the Cinnamon shell, which should force it to reload icons. You can also log out and log back in, or reboot.

            - **Test:** After these steps, unpin and re-pin the Outlook web app to see if the icon displays correctly.

        **2. Incorrect Icon Path in the .desktop File**

        - **The Problem:** When Chrome creates a web app, it generates a `.desktop` file. This file tells the system how to launch the app, where the icon is, and other details. If the icon path is incorrect or points to a low-resolution icon, you'll get problems.

        - **The Solution:**

            1. **Find the .desktop file:** Chrome web apps usually place their `.desktop` files in `~/.local/share/applications/`. Look for a file with a name like `chrome-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-Default.desktop` (the `x`'s will be a long, random string). You can use the file manager or the terminal (e.g., `ls ~/.local/share/applications/ | grep chrome`) to find it.

            2. **Open the .desktop file:** Use a text editor (like Xed, the default in Mint) to open the file. For example:

                Bash

                ```text
                xed ~/.local/share/applications/chrome-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-Default.desktop
                ```

            3. **Check the** `Icon=` **line:** Look for a line that starts with `Icon=`. This line specifies the icon to use.

                - **If it's a full path:** Ensure that the path is *absolutely correct* and points to a valid icon file (e.g., `.png`, `.svg`). If the file is missing or the path is wrong, that's your problem.

                - **If it's just an icon name:** This means the system should look for the icon in the standard icon theme directories. If the icon theme doesn't have an icon with that name, you'll get a fallback or a broken icon.

                - **Correct Icon name:** The correct icon name for outlook is usually `outlook`. Change the line to reflect this `Icon=outlook`

            4. **Correct the path or icon name:**

                - **Option 1 (Best): Use a generic icon name:** If you're using a standard icon theme, changing `Icon=` to a generic name like `Icon=outlook` or `Icon=office-outlook` (if your theme provides it) is often the best solution. This allows the theme to provide the appropriate icon.

                - **Option 2 (If Option 1 doesn't work): Find a good icon:** You can download a high-resolution Outlook icon (e.g., a `.png` or `.svg` file) and place it in a suitable location (e.g., `~/.local/share/icons/` or a subdirectory within it). Then, set the `Icon=` line to the *full path* to this icon file. For example:```
                Icon=/home/yourusername/.local/share/icons/outlook.png

                    ```text
                    
                    ```

                - **Option 3 (Use the Chrome-provided icon):** Examine other `.desktop` files created by Chrome. You *might* find that one of them points to a usable Outlook icon within Chrome's own data directory. If you find one, you can copy that full path to your problematic `.desktop` file. However, this is generally less reliable than options 1 and 2.

            5. **Save the .desktop file.**

            6. **Update the icon cache (again):** Run `gtk-update-icon-cache` (as described in step 1) after modifying the `.desktop` file.

            7. **Restart Cinnamon (again):** Press `Alt` + `F2`, type `r`, and press `Enter`.

            8. **Test:** Unpin and re-pin the web app.

        **3. Icon Theme Issues**

        - **The Problem:** It's *possible*, though less likely, that your chosen icon theme has a problem with the Outlook icon specifically or is incomplete.

        - **The Solution:**

            1. **Switch Icon Themes:** Temporarily switch to a different icon theme (e.g., Adwaita, which is a standard GNOME theme) in your system settings (Appearance or Themes).

            2. **Test:** See if the Outlook web app icon displays correctly with the new theme.

            3. **If it works:** If the icon works with a different theme, it indicates a problem with your original icon theme. You might need to reinstall your preferred icon theme, find an updated version, or choose a different one.

        **4. Chrome Web App Bugs**

        - **The Problem:** There could be a bug in Chrome's web app creation process itself, especially with a very recent Chrome version.

        - **The Solution:**

            1. **Try a Different Browser (for testing):** Create the Outlook web app using a different browser (e.g., Firefox) if possible. This helps determine if the issue is specific to Chrome. If it works in Firefox, the problem is almost certainly Chrome-related.

            2. **Report the Bug:** If you suspect a Chrome bug, consider reporting it to Google. You can do this through Chrome's "Help" menu ("Report an issue").

            3. **Downgrade Chrome (Temporary Workaround - Use with Caution):** As a *temporary* measure, if the issue is critical and you've confirmed it's Chrome-specific, you could try downgrading to a slightly older version of Chrome. *However, this is generally not recommended for security reasons,* as older versions may have unpatched vulnerabilities. Only do this if you absolutely must, and revert to the latest version as soon as possible. You would need to find a `.deb` package for an older Chrome version and install it manually.

        **5. Panel Configuration (Less Likely)**

        - **The Problem:** There's a small chance that the panel configuration itself is somehow corrupted.

        - **The Solution:**

            1. **Reset the Panel (Caution - Will Reset All Panel Settings):** You can reset the Cinnamon panel to its default settings. This will remove any customizations you've made. The easiest way is to open a terminal and run:

                Bash

                ```text
                dconf reset -f /org/cinnamon/
                ```

                Then, restart Cinnamon (`Alt` + `F2`, `r`, `Enter`).

            2. **Create a New User Account (For Testing):** Create a new user account on your system. Log in to that account and see if the problem persists. If the icon works in the new user account, it indicates a problem with your original user account's configuration.

        **Troubleshooting Steps (Order of Importance):**

        1. **Clear Icon Cache:** (gtk-update-icon-cache, XDG icon cache removal, restart Cinnamon) - This is the first and most important step.

        2. **Check and Correct .desktop File:** (Find the file, verify/correct the `Icon=` line, update cache, restart Cinnamon)

        3. **Try a Different Icon Theme.**

        4. **Test with a Different Browser.**

        5. **Reset the Panel (Last Resort).**

        6. **Create a New User Account (For thorough testing).**

        7. **Report the Bug to Chrome (If you suspect a Chrome issue).**

        8. **Downgrade Chrome (Temporary, Risky Workaround).**

        By systematically going through these steps, you should be able to identify the cause of the problem and fix the Outlook web app icon issue. Remember to test after each significant change. Good luck!

- Fix ALT Peek View in Notion

    On Linux Mint with Vivaldi, the problem is that the **Alt key** is intercepted by the browser (and the desktop environment) before Notion can use it. That’s why `Alt + Click` (or `Alt + Enter`) doesn’t work in Notion. You can fix it in two steps:

    ---

    ### 1. Change Vivaldi’s Alt key behavior

    1. Open Vivaldi.

    2. Go to **Settings** → **Keyboard**.

    3. Look for **“Menu Key”** (sometimes called *Focus on Menu with Alt*).

    4. Change it from **Alt** to **Alt+Shift**, or disable it completely.

        - This prevents Vivaldi from grabbing the Alt key for menus.

    ---

    ### 2. Adjust Linux Mint (Cinnamon) settings

    Cinnamon also uses the **Alt key** for moving windows:

    1. Go to **System Settings** → **Windows** → **Behavior** tab.

    2. Find **“Special key to move and resize windows”**.

    3. Change it from **Alt** to **Super** (the Windows key).

        - Now Alt is free for applications like Notion.

    ---

    ### After doing both

    Restart Vivaldi, and `Alt + Click` (or `Alt + Enter`) should work in Notion as intended.

    ---

    👉 Do you want me to also show you how to set a **custom Notion shortcut in Vivaldi** (so you can override or remap it directly inside the browser)?

- Setting Up Two-Way Sync using FreeFileSync and Google Drive

    Here is a beginner-friendly, step-by-step guide to setting up a two-way sync between an external hard drive and Google Drive using FreeFileSync on Linux Mint.

    FreeFileSync has a brilliant built-in Google Drive connector. This means you don't need to mess with complex Linux terminal commands or background mounting scripts—the application handles the cloud connection directly.

    ### Step 1: Select Your External Drive (The "Left" Side)

    FreeFileSync uses a simple "Left" and "Right" panel layout. Think of these as the two locations you want to keep perfectly matched.

    1. Open **FreeFileSync**.

    2. On the **Left** side of the screen, click the standard **Browse** button (it looks like a yellow folder).

    3. Navigate to your external hard drive. In Linux Mint, external drives usually mount in your file system under `/media/your_username/Drive_Name`. You can usually just click your drive's name in the left sidebar of the file picker.

    4. Select the specific folder you want to sync, or select the root of the drive to sync everything. Click **Open**.

    ### Step 2: Connect to Google Drive (The "Right" Side)

    Now we will tell the right side to look at your Google Drive.

    1. On the **Right** side panel, do *not* click the standard folder icon. Instead, click the **Cloud icon** (it looks like a little cloud with a gear or plug next to it).

    2. A new configuration window will pop up. From the drop-down menu at the top, select **Google Drive**.

    3. Click the **Add Connection** button.

    4. Your default web browser (like Firefox or Chrome) will open automatically. Google will ask you to sign in to your account and grant FreeFileSync permission to access your Drive. Click **Allow**.

    5. Once you see a "Success" or "Authentication completed" message in your browser, you can close the browser tab and go back to FreeFileSync.

    6. In the FreeFileSync cloud window, you will now see your Google Drive folders. Browse to the specific folder you want to use as your sync destination and click **OK**.

    ### Step 3: Configure the "Two-Way" Sync

    Now we need to tell the software *how* to handle the files.

    1. Look at the top center of the FreeFileSync window. You will see a button with a green gear icon. Click that **gear icon**.

    2. A Synchronization Settings menu will appear. Select the **Two way** option.

        - **What Two-Way means:** The software will make both sides identical based on the newest changes. If you add, change, or delete a file on your external drive, that exact change will happen on Google Drive. If you add, change, or delete a file on Google Drive, it will happen on your external drive.

    3. Click **OK** to save the setting and close the menu.

    ### Step 4: The Golden Rule – Compare First!

    Never hit sync blindly, especially when using a Two-Way sync, as it can delete files.

    1. Click the big blue **Compare** button at the top left of the main screen.

    2. FreeFileSync will scan both your external drive and your Google Drive.

    3. It will generate a detailed list showing you *exactly* what is about to happen.

        - A **Green Arrow** means a file is being copied or updated.

        - A **Red Trash Can** means a file is going to be deleted.

    4. **Take a moment to review this list.** Make sure the files it wants to delete or overwrite make sense to you.

    ### Step 5: Run the Sync

    1. Once you are fully satisfied with the planned changes shown in the comparison list, click the big green **Synchronize** button at the top right.

    2. A final confirmation box will pop up summarizing the data transfer. Click **Start**.

    3. Sit back and let it work! Depending on your internet speed and the amount of data, this could take a few seconds or a few hours.

    ### Step 6: Save Your Setup (Highly Recommended)

    To save yourself from having to configure the folders and log into Google Drive all over again next time:

    1. Go to the top left menu and click **File > Save as...**

    2. Give your sync job a recognizable name (e.g., `External_to_GoogleDrive`).

    3. The next time you plug in your external drive and open FreeFileSync, you can just load this file, click "Compare," and you are ready to go.

- Opening apps automatically maximized

    The tendency for windows to open in their "normal" (restored) state rather than maximized is a common quirk in Cinnamon and other X11-based desktop environments. While some apps remember their last state via their own configuration files, many—especially web apps—rely on the window manager, which often defaults to a specific placement logic.

    Here are the most effective ways to force your apps to open maximized on Linux Mint.

    ---

    ### 1. The "Devilspie2" Method (The Power User Choice)

    Since you're comfortable with technical configurations, **Devilspie2** is the most robust solution. It’s a window-matching daemon that runs in the background and executes Lua scripts when a window is created.

    **Installation:**

    Bash

    `sudo apt update && sudo apt install devilspie2`

    **Configuration:**

    1. Create the config directory: `mkdir -p ~/.config/devilspie2`

    2. Create a script file: `nano ~/.config/devilspie2/maximize.lua`

    3. Add the following logic (this will maximize specific apps by name):

    Lua

    - `- Maximize specific appsif (get_window_class() == "Google-chrome" or get_window_class() == "Firefox" or get_window_class() == "WebApp-Example") then maximize();
      end- Or, to maximize EVERYTHING (not recommended for dialogs)- maximize();`

    **Note:** You can find the "window_class" of an app by running `xprop WM_CLASS` in a terminal and clicking on the target window.

    1. Add `devilspie2` to your **Startup Applications** in the Mint System Settings.

    ---

    ### 2. Using Command Line Flags (Best for Web Apps)

    If you are using the Mint **Web App Manager**, these apps are essentially instances of a browser (Firefox, Chrome, or Chromium). You can often force them to start maximized by editing the launcher command.

    1. Open the **Main Menu** editor (right-click the Mint Menu icon -> Configure -> Menu -> Open the menu editor).

    2. Find your Web App under the "Web Apps" or "Internet" category.

    3. Edit the **Command** field.

    4. If it uses a Chromium-based browser (Chrome, Brave, Vivaldi), append the following flag to the end of the command:

        - `-start-maximized`

    5. If it’s a standard package, check if it supports a `-maximized` or `maximize` flag (though this varies by app).

    ---

    ### 3. The `wmctrl` Scripting Approach

    If you prefer a lightweight bash script to run after your reboot, you can use `wmctrl` to manipulate existing windows.

    **Installation:**

    Bash

    `sudo apt install wmctrl`

    **Usage:**

    You can create a small script that waits for the desktop to load and then forces specific windows to maximize:

    Bash

    `#!/bin/bash

    # Wait for apps to launch

    sleep 5

    # Maximize a window with "Firefox" in the title

    wmctrl -r "Firefox" -b add,maximized_vert,maximized_horz`

    ---

    ### 4. Check Cinnamon Window Settings

    Sometimes the window placement mode interferes with how apps "remember" their state.

    - Go to **System Settings** -> **Windows**.

    - Under the **Behavior** tab, look at **Window placement**.

    - Try changing it to **Automatic** if it is set to "Manual" or "Center". This often allows apps that have an internal "remember state" feature to function correctly.

    ### Which one should you use?

    - If you have **many different apps** to manage: Use **Devilspie2**.

    - If it's just **Web Apps**: Use the `-start-maximized` flag in the launcher.

    - If you want a **quick fix** without extra daemons: Use the `wmctrl` script.

- Installing LM Debian

    - Adding Snap packages

        The Linux Mint team intentionally disables Snap by default across all their editions, but they make it easy to reverse if you want to use it.
        Here is how you can enable and install snapd on LMDE:

        1. Remove the Snap block file
        Linux Mint uses an APT preference file to prevent Snap from being installed as a dependency. You need to either delete this file or move it. To back it up (just in case you want to restore the block later), run this command in your terminal:
        sudo mv /etc/apt/preferences.d/nosnap.pref ~/Documents/nosnap.backup

        2. Update your package list
        Tell your system to refresh its software cache so it recognizes that Snap is now allowed:
        sudo apt update

        3. Install Snapd
        Now you can install the Snap daemon, which handles the package management:
        sudo apt install snapd

        4. Install the Snap core
        It is highly recommended to install the core runtime right away to ensure your environment is set up properly for other applications:
        sudo snap install core

        5. Reboot your system
        Restarting your computer ensures that the Snap paths are correctly added to your environment variables. Without a reboot, applications you install via Snap might not show up in your application menu right away.
        Once rebooted, you are fully set up to install Snap packages via the terminal using the sudo snap install  command.

- Disabling Hibernation (via terminal)

    ## **Disabling Hibernation in Linux Mint**

    For users who prefer to disable the hibernation feature in Linux Mint, the most reliable methods involve using the command line. While graphical settings to completely turn off hibernation are generally not available in the standard Power Management options, the following command-line instructions provide a straightforward and effective way to achieve this.

    ---

    ### **Recommended Method: Using systemctl**

    The most direct way to disable hibernation is by using the systemctl command to mask the hibernation service. This prevents the system from being able to enter hibernation.

    1. **Open a terminal:** You can do this by pressing Ctrl+Alt+T on your keyboard.1

    2. **Mask the hibernation service:** Type the following command into the terminal and press Enter. This will prevent the hibernation service from being started.

        ```jsx
        sudo systemctl mask hibernate.target
        ```

    3. **Enter your password** when prompted. Note that you will not see any characters as you type your password.

    After executing this command, the hibernation option will be disabled.

    ---

    ### **How to Verify Hibernation is Disabled**

    To confirm that the hibernation service has been successfully disabled, you can check its status with the following command:

    ```jsx
    sudo systemctl status hibernate.target
    ```

    If it has been successfully masked, you will see output indicating that the service is "masked".

    ---

    ### **Re-enabling Hibernation**

    Should you wish to re-enable hibernation in the future, you can do so by "unmasking" the service.2

    1. **Open a terminal.**

    2. **Unmask the hibernation service:** Enter the following command:

        ```jsx
        sudo systemctl unmask hibernate.target
        ```

    ---

    ### **Alternative Method: Using Polkit Rules**

    Another effective way to disable hibernation is by creating a polkit rule. This method revokes the permission for users to perform hibernation.

    1. **Open a terminal.**

    2. **Create a new polkit rule file:** Use the following command to create and open a new file in a text editor:

        ```jsx
        sudo nano /etc/polkit-1/localauthority/90-mandatory.d/disable-hibernate.pkla
        ```

    3. **Add the following content** to the file:

        > Ini, TOML

        [Disable hibernate]

        Identity=unix-user:*

        Action=org.freedesktop.login1.hibernate

        ResultActive=no

    4. **Save and close the file:** Press Ctrl+X, then Y, and then Enter to save the changes in the nano text editor.

    After a reboot, the hibernation option should no longer be available. To re-enable hibernation using this method, you would simply delete the file you created.

- Installing MediaTek MT7902 (ASUS Vivobook)

    Installing the **MediaTek MT7902** wireless card on Linux can be a bit of a challenge because, unlike its siblings (the MT7921 or MT7922), it is a "Soft MAC" device that requires specific proprietary firmware and a kernel version that supports it.

    Here is the most reliable path to getting this card running on **Linux Mint**.

    ## **1. Update Your Kernel**

    The MT7902 requires modern drivers. Linux Mint (especially the LTS versions) often ships with older kernels. You should aim for **Kernel 6.5 or higher**.

    1. Open the **Update Manager**.

    2. Go to **View** -> **Linux Kernels**.

    3. Select the latest available kernel (e.g., 6.5 or 6.8 series).

    4. Install it and **reboot** your computer.

    ## **2. Secure Boot (The Most Common Culprit)**

    The MT7902 driver often fails to load if **Secure Boot** is enabled in your BIOS. This is because the driver/firmware might not be signed in a way that your hardware trusts during the boot process.

    - **Action:** Restart your ASUS Vivobook, enter the BIOS (usually by tapping **F2** or **Del**), and set **Secure Boot** to **Disabled**.

    ## **3. Install the MediaTek Firmware**

    If the card still isn't recognized after a kernel update, you may be missing the specific firmware files. You can pull the latest versions directly from the Linux firmware tree.

    Open your Terminal and run the following commands:

    Bash

    # Create a temporary folder

    mkdir ~/fw_temp && cd ~/fw_temp

    # Download the specific MT7902 firmware files

    wget [https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7902/WIFI_MT7902_patch_mcu_1_1_hdr.bin](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7902/WIFI_MT7902_patch_mcu_1_1_hdr.bin)

    wget [https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7902/WIFI_RAM_CODE_MT7902_1_1.bin](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7902/WIFI_RAM_CODE_MT7902_1_1.bin)

    # Move them to the system firmware directory

    sudo cp WIFI* /lib/firmware/mediatek/mt7902/

    # Reload the driver module

    sudo modprobe -r mt7921e && sudo modprobe mt7921e

    *(Note: Despite the name, the mt7921e module often handles the 7902/7922 family chips).*

    ## **4. Verification**

    After performing the steps above, check if the system sees the hardware by running:

    Bash

    iwconfig

    If you see wlan0 (or similar) listed with "No Wireless Extensions," the driver is loaded. If it still says "no wireless extensions," check the logs for errors:

    Bash

    dmesg | grep mt7902

    ## **Summary Table of Compatibility**

    | **Component**     | **Requirement**                |
    | :---------------- | :----------------------------- |
    | **Kernel**        | 6.5+ recommended               |
    | **BIOS Settings** | Secure Boot: **Disabled**      |
    | **Firmware Path** | /lib/firmware/mediatek/mt7902/ |
    | **Driver Module** | mt7921e or mt7902              |

    **Tech Tip:** If you find the MT7902 remains unstable (a common complaint with this specific MediaTek chip), many users opt to swap it for an **Intel AX210** M.2 card. It is a drop-in replacement that works natively in Linux without any extra configuration.

- Setting up Caddy

    - Initial tutorial

        > **Syncthing is great for syncing between your own trusted devices, but it does not provide “public links” by itself** because it only connects devices you explicitly approve. syncthing.net([https://syncthing.net/](https://syncthing.net/))

        So the common pattern is:

        1. **Use Syncthing** to keep a “Share” folder identical on home + office, then

        2. **Use a web server** (on one machine, or a small VPS) to publish *only that folder* to the internet, optionally with passwords.

        Below is a practical setup that gives you:

        - **Public** access for some files

        - **Password/hidden** access for others

        - Works well on **Linux Mint Cinnamon 22.3**

        ---

        ## What “port forwarding” means (and why you may or may not need it)

        Most home/office networks have a router that blocks **incoming** connections by default. If you want the internet to reach a service inside your network (your file server), you typically create a router rule called **port forwarding** that sends inbound traffic (e.g., to ports 80/443) to your specific PC. kb.netgear.com([https://kb.netgear.com/20917/What-is-port-forwarding](https://kb.netgear.com/20917/What-is-port-forwarding))

        In simple terms:

        - Internet users go to `https://files.yourdomain…`

        - Your router receives that request

        - **Port forwarding** tells it: “Send this to my Linux Mint PC running the server” kb.netgear.com([https://kb.netgear.com/20917/What-is-port-forwarding](https://kb.netgear.com/20917/What-is-port-forwarding))

        ### Important gotcha: CGNAT (may prevent port-forwarding)

        Some ISPs put customers behind **Carrier-Grade NAT (CGNAT)**, which often makes inbound connections (and therefore port forwarding) fail because the ISP is doing NAT *before* your router.

        If you’re behind CGNAT, the “host-it-at-home/office” plan can be frustrating, and a small VPS becomes the simplest solution. ipaddressl...cation.net([https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp](https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp)), xda-developers.com([https://www.xda-developers.com/cgnat-port-forwarding-workarounds/](https://www.xda-developers.com/cgnat-port-forwarding-workarounds/))

        **Fast check:** Compare your router’s **WAN/Internet IP** with the public IP shown by a site like “what’s my IP”. If they don’t match (or your router WAN is in `100.64.0.0/10`), CGNAT is likely. ipaddressl...cation.net([https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp](https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp)), ip-trackers.com([https://www.ip-trackers.com/blog/port-forwarding-not-working-cgnat](https://www.ip-trackers.com/blog/port-forwarding-not-working-cgnat))

        ---

        ## Best-fit approach for you (small files + two domains): Caddy file server + Syncthing

        ### Why Caddy?

        Caddy is a modern web server that makes it easy to:

        - Serve a folder as a website (`file_server`) caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/file_server](https://caddyserver.com/docs/caddyfile/directives/file_server))

        - Add **Basic Auth** password protection (`basic_auth`) and requires hashed passwords caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth)), notes.plc.one([https://notes.plc.one/docs/command-line](https://notes.plc.one/docs/command-line))

        ---

        # Option A (no monthly cost): Host from one of your PCs (home *or* office)

        ### 1) Create two synced folders: “public” and “protected”

        On your external drive (example paths):

        - `/mnt/EXT/Share/public/` → anyone can access

        - `/mnt/EXT/Share/protected/` → password required (or “hidden link” style)

        In Syncthing, share `/mnt/EXT/Share` (or two separate folders) between home and office.

        **Tip:** Consider setting the “publishing” machine as the authoritative copy using Syncthing folder types:

        - **Send Only** on the machine you edit on (authoritative) docs.syncthing.net([https://docs.syncthing.net/users/foldertypes.html](https://docs.syncthing.net/users/foldertypes.html))

        - **Receive Only** on the other machine (mirror) docs.syncthing.net([https://docs.syncthing.net/users/foldertypes.html](https://docs.syncthing.net/users/foldertypes.html))

        This reduces accidental edits propagating back the wrong way.

        ---

        ### 2) Install Caddy (Mint is Ubuntu-based, so this is typically straightforward)

        Usually:

        sudo apt update

        sudo apt install caddy

        (If Mint’s repo doesn’t have a recent Caddy, you can use Caddy’s official install instructions — but try the above first.)

        Enable and start it:

        sudo systemctl enable --now caddy

        ---

        ### 3) Configure Caddy to serve public + password-protected paths

        Caddy’s `file_server` serves static files from a `root`.

        Caddy’s `basic_auth` protects paths with username + **hashed** password, and it warns basic auth should be used over HTTPS (not plain HTTP). caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/file_server](https://caddyserver.com/docs/caddyfile/directives/file_server)) caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth))

        Create/edit:

        sudo nano /etc/caddy/Caddyfile

        Example Caddyfile (adjust paths and domain):

        files.benjaminlstewart.net {

        # Public files

        handle_path /public/* {

        root * /mnt/EXT/Share/public

        file_server browse

        }

        # Password-protected files

        handle_path /protected/* {

        basic_auth {

        benjamin  $2a$14$REPLACE_WITH_HASH_FROM_CADDY

        }

        root * /mnt/EXT/Share/protected

        file_server browse

        }

        # Nice default landing

        redir / /public/ 302

        }

        Notes:

        - `file_server browse` enables directory browsing. caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/file_server](https://caddyserver.com/docs/caddyfile/directives/file_server))

        - `basic_auth` must use a **hash**, not a plaintext password. caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth))

        - Caddy’s `handle/handle_path` lets you apply rules in the order written, which is important when mixing handlers. i.scwy.net([https://i.scwy.net/doc/caddy/docs/caddyfile/patterns](https://i.scwy.net/doc/caddy/docs/caddyfile/patterns)), caddyserver.com([https://caddyserver.com/docs/caddyfile/directives](https://caddyserver.com/docs/caddyfile/directives))

        Reload:

        sudo caddy fmt --overwrite /etc/caddy/Caddyfile

        sudo systemctl reload caddy

        ---

        ### 4) Generate the password hash for `basic_auth`

        Caddy provides `caddy hash-password`. caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth)), notes.plc.one([https://notes.plc.one/docs/command-line](https://notes.plc.one/docs/command-line))

        Run:

        caddy hash-password

        Paste the resulting hash into the Caddyfile next to your username. caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth)), manpages.debian.org([https://manpages.debian.org/experimental/caddy/caddy-hash-password.1.en.html](https://manpages.debian.org/experimental/caddy/caddy-hash-password.1.en.html))

        ---

        ### 5) DNS + Port forwarding (the “internet can reach you” part)

        ### DNS

        At your domain registrar (or wherever DNS is hosted), create:

        - **A record**: `files` → your public IPv4 address
        (Optionally AAAA record for IPv6 if you have it.)

        So students will use:

        `https://files.benjaminlstewart.net/public/...`

        ### Port forwarding (router setting)

        You forward:

        - **TCP 80** → your Mint PC’s LAN IP

        - **TCP 443** → your Mint PC’s LAN IP

        This is what allows inbound traffic to reach your web server. kb.netgear.com([https://kb.netgear.com/20917/What-is-port-forwarding](https://kb.netgear.com/20917/What-is-port-forwarding)), geeksforgeeks.org([https://www.geeksforgeeks.org/computer-networks/port-forwarding-on-router-and-why-do-we-need-it/](https://www.geeksforgeeks.org/computer-networks/port-forwarding-on-router-and-why-do-we-need-it/))

        Also make sure your OS firewall allows it (if you use UFW):

        sudo ufw allow 80/tcp

        sudo ufw allow 443/tcp

        ---

        ## Hidden link vs password: what’s realistic?

        ### “Hidden link”

        A “hidden link” is basically **an unguessable URL** (security by obscurity). It’s fine for low-risk sharing (e.g., you don’t mind if it leaks), but it’s not real access control.

        Simple method:

        - Put items in a folder like `/public/spring-2026-9F3kQ/`

        - Share that URL only

        ### “Password”

        Password is real access control, and Caddy’s `basic_auth` is designed for this.

        Just be sure you’re using **HTTPS** (Caddy can automatically manage TLS for real domain names). caddyserver.com([https://caddyserver.com/docs/caddyfile/directives/basic_auth](https://caddyserver.com/docs/caddyfile/directives/basic_auth))

        ---

        # Option B (most reliable): Host on a small VPS (recommended if CGNAT or office router restrictions)

        If:

        - you can’t port-forward (CGNAT or admin restrictions), or

        - you want reliable uptime,

        then do this:

        1. Rent a small VPS (often $5–$10/mo)

        2. Install **Syncthing** on the VPS (third device)

        3. Sync only `/Share` to the VPS

        4. Run **Caddy** on the VPS exactly as above

        This avoids home/office networking complexity entirely. And you can still author at home/office with Syncthing.

        ---

        ## Which domain should you use?

        A clean approach is:

        - `files.benjaminlstewart.net` → file server

        - Keep your main sites on `benjaminlstewart.net` / `.com` as usual

        You can also do:

        - `.net` for public

        - `.com` for protected
        …but one subdomain is usually enough.

        ---

        ## Quick questions (so I can tell you whether Option A will work instantly)

        1. **Which location is better to host from (home or office)?** (i.e., which PC is on more often)

        2. Do you have access to your **router settings** at that location?

        3. Can you check your router’s **WAN/Internet IP** and tell me whether it matches your public IP? (That tells us if CGNAT is likely.) ipaddressl...cation.net([https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp](https://ipaddresslocation.net/articles/cgnat-explained-why-you-cannot-port-forward-with-your-isp)), ip-trackers.com([https://www.ip-trackers.com/blog/port-forwarding-not-working-cgnat](https://www.ip-trackers.com/blog/port-forwarding-not-working-cgnat))

        If you answer those, I’ll give you a “do this, then this” checklist tailored to your exact situation (including a Caddyfile that matches your preferred URL structure).

- No Sound (PipeWire)

    # ✅ **1. Restart PipeWire (the audio engine you actually have)**

    Run these commands:

    systemctl --user restart pipewire

    systemctl --user restart pipewire-pulse

    systemctl --user restart wireplumber

    Then test sound again.

    ---

    # ✅ **2. Check output devices with the correct mixer (PipeWire/PulseAudio GUI)**

    Install `pavucontrol` (if not installed):

    sudo apt install pavucontrol

    Then run:

    pavucontrol

    Inside **pavucontrol**, check:

    ### **Output Devices tab**

    - Make sure nothing is muted

    - Select the correct device (not HDMI unless you really want HDMI audio)

    ### **Playback tab**

    - Ensure applications are not sending audio to the wrong device
    (PipeWire sometimes pushes apps to HDMI automatically.)

    This is often the fastest way to restore sound.

    ---

    # ✅ **3. Make sure the correct audio device is selected**

    Your screenshot shows the system output is set to:

    > **HDMI / DisplayPort Built‑in Audio**

    This is **very often wrong** if your speakers/headphones are plugged into:

    - the PC analog audio jack

    - a USB interface (like your RØDECaster Duo)

    - a USB headset

    - the monitor with no speakers

    Try switching to:

    - **Analog Output (USB Audio)**

    - **Analog Output (RODECaster Duo)**

    - **Built‑In Audio Analog Stereo** (if present)

    - **HDMI/DP Port 2** (sometimes only one HDMI actually carries audio)

    Then click **Test Sound**.

    ---

    # ✅ **4. Check if the sound server is active**

    Run:

    systemctl --user status pipewire

    ``

    You should see “active (running).”

    If not:

    systemctl --user enable --now pipewire pipewire-pulse wireplumber

    ``

    ---

    # ✅ **5. If audio is still missing, reload ALSA**

    (ALSA is the hardware layer under PipeWire.)

    sudo alsa force-reload

    Then reboot.

    ---

    # ⚠️ If *nothing* works, show me this info:

    Please run:

    pactl list short sinks

    and:

    inxi -A

    Paste the output here — those two commands tell me exactly:

    - which sound cards your system sees

    - whether HDMI, analog, or USB is the default

    - whether PipeWire is detecting the real devices

    With that, I can give you the exact fix in one step.

    ---

    Would you like me to diagnose using those two commands?

- Installing Prospect Mail (Outlook)

    Since Linux Mint is based on Ubuntu/Debian but disables Snap packages by default, the most straightforward way to install **Prospect Mail** (the unofficial Outlook client) via the terminal is by using the `.deb` package.

    Here are the two best methods to get it running.

    ### Method 1: Installing via `.deb` Package (Recommended)

    This is the "native" way for Linux Mint and avoids the overhead of Snaps.

    1. **Open your terminal** (Ctrl+Alt+T).

    2. **Download the latest package** (currently version 1.2.1) directly from GitHub:Bash

        `wget https://github.com/julian-alarcon/prospect-mail/releases/download/v1.2.1/prospect-mail_1.2.1_amd64.deb`

    3. **Install the package**:

    Bash

    ```text
    `sudo apt install ./prospect-mail_1.2.1_amd64.deb
      ```
      *Note: Using `apt` instead of `dpkg` automatically handles any missing dependencies for you.*
    ```

    ---

    ### Method 2: Installing via Snap

    If you prefer Snaps because they auto-update, you first have to re-enable Snap support, as Mint blocks it out of the box.

    1. **Remove the block file**:

        ```bash
        sudo rm /etc/apt/preferences.d/nosnap.pref
        ```

    2. **Update your package list and install snapd**:

        ```bash
        sudo apt update
        sudo apt install snapd
        ```

    3. **Install Prospect Mail**:

        ```bash
        sudo snap install prospect-mail
        ```

    ---

    ### Troubleshooting: "Sandbox" Errors

    If you are on a newer version of Linux Mint (like Mint 22) and the app fails to open or shows a "permission denied" error regarding shared memory, it is likely due to tightened security in the underlying Ubuntu kernel.

    You can bypass this by launching the app from the terminal with the sandbox disabled:

    ```bash
    prospect-mail --no-sandbox`
    > [!TIP]
    > 
    > 
    > **Pro Tip:** Prospect Mail is specifically optimized for **Work or School (Office 365)** accounts. If you are trying to use a personal Outlook.com account, you might find some features are limited or require a specific URL configuration in the app settings.
    > 
    Which version of Linux Mint are you currently running?
    ```

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

- Setting up RealTime

    By default, the main FreeFileSync application does not run in the background; it is an on-demand manual tool. However, the developers built a companion application specifically for this purpose called **RealTimeSync**, which is included automatically when you install FreeFileSync.

    RealTimeSync sits quietly in your system tray, monitors your designated folders for changes, and automatically triggers FreeFileSync in the background whenever a file is added, modified, or deleted.

    Here is the recommended way to set up a continual, automated sync in Linux Mint.

    ### Step 1: Create a "Batch Job" (Silent Sync)

    Before you can automate the process, you have to tell FreeFileSync to run without asking for human permission (like clicking "Compare" or "Start").

    1. Open **FreeFileSync** and set up your Two-Way sync exactly as we did before (External Drive on the Left, Google Drive on the Right).

    2. Run it manually once to ensure both sides are perfectly matched.

    3. Instead of the standard "Save", click **File > Save as batch job...**

    4. A new window will appear with batch settings:

        - **Handling errors:** Set this to **Ignore** (so a single locked file doesn't freeze the whole background process with a popup).

        - **Completion:** Check the box for **Auto-close** (this hides the progress window when the sync finishes).

    5. Click **Save As** and name it something like `GoogleDriveSync.ffs_batch`. Save it somewhere safe, like your Documents folder.

    ### Step 2: Configure RealTimeSync

    Now we hand that batch file over to the background monitor.

    1. Open your Linux Mint application menu and search for **RealTimeSync**.

    2. Open the application. You will see a very simple, minimalist window.

    3. Click **File > Open...** and select the `GoogleDriveSync.ffs_batch` file you just created.

    4. RealTimeSync will automatically read the batch file and populate the "Folders to watch" section with your `/media/ben/...` external drive path.

    5. **Idle time:** This is how long RealTimeSync waits after detecting a change before starting the sync. The default is usually `10` seconds, which is perfect. It prevents the system from triggering a sync 50 times in a row if you are saving a document constantly.

    6. Click the **Start** button. RealTimeSync will minimize to your system tray (a small icon with two red arrows) and begin watching your files.

    ### Step 3: Make it Start on Boot

    To ensure your sync is always running without you having to manually launch RealTimeSync every time you turn on your computer:

    1. Open the Linux Mint menu and search for **Startup Applications**.

    2. Click the **+** (Add) button at the bottom and choose **Custom command**.

    3. Fill in the details:

        - **Name:** `Background Drive Sync` (or whatever you prefer).

        - **Command:** Click the Browse button, find the `RealTimeSync` executable (usually `/usr/bin/RealTimeSync` or `/opt/FreeFileSync/RealTimeSync`), select it, and then add a space followed by the path to your batch file. It should look something like this:

            `RealTimeSync /home/ben/Documents/GoogleDriveSync.ffs_batch`

        - **Comment:** `Automated sync to Google Drive`.

    4. Click **Add** or **Save**.

    Now, whenever you boot up, RealTimeSync will quietly launch in the background. If your external drive is plugged in, it will immediately start monitoring it.

    ---

    ### A Crucial Warning Regarding Automated Two-Way Syncs

    While automating a two-way sync is incredibly convenient, it removes your human safety net. If you accidentally delete a critical research folder on your external drive, RealTimeSync will notice the change 10 seconds later and instantly delete that same folder from Google Drive.

    Because of this, I highly recommend configuring a safety net within the FreeFileSync settings before you generate your final batch file.

    Would you like me to walk through how to configure the "Versioning" setting so that deleted files are moved to a temporary archive folder instead of being permanently erased?

- Setting up FreeFileSync

    - Installing FreeFileSync directly (FreeFileSync_14.10_Linux_x86_64)

        Now that your system is prepped, installing FreeFileSync from that specific Linux file is a straightforward process.

        The file you downloaded is likely a compressed archive (a `.tar.gz` file), even if your web browser or file manager hid the extension. FreeFileSync packages a dedicated installer inside this archive that handles putting the files in the right place and creating your application shortcuts.

        Here is the most reliable way to install it using the terminal. I will break down exactly what each command does to keep the process completely transparent.

        ### Step 1: Open the Terminal and Locate the File

        First, we need to point the terminal to the folder where you downloaded the file. Assuming it is in your default Downloads folder:

        1. Open your **Terminal**.

        2. Type the following command and press Enter to navigate to the Downloads directory:

        ```bash
        cd ~/Downloads
        ```

        ### Step 2: Extract the Installer

        Next, we will unpack the compressed archive to access the installer script inside.

        1. Run this command to extract the files:

        ```bash
        tar -xvf FreeFileSync_14.10_Linux_x86_64.tar.gz
        ```

        *(Note: The* `-xvf` *flags tell the system to e****x****tract, be* ***v****erbose by listing the files it is extracting, and process the specific* ***f****ile you named).*

        ### Step 3: Run the Installation Script

        Extracting the archive will output a new file named `FreeFileSync_14.10_Install.run`. This is the actual installer, but Linux requires you to explicitly grant it permission to execute as a program before it can run.

        1. Grant the file execution permissions:

        ```bash
        chmod +x FreeFileSync_14.10_Install.run
        ```

        1. Launch the installer script:

        ```bash
        ./FreeFileSync_14.10_Install.run
        ```

        ### Step 4: Follow the Visual Prompts

        Once you run that final command, a graphical window will pop up on your screen.

        1. Read and accept the End User License Agreement.

        2. The installer will ask where to install the software. The default location (`/opt/FreeFileSync`) is the standard, correct location for this type of software on Linux.

        3. Click **Install**.

        The script will automatically copy the core application files to the `/opt` directory and generate the clickable icons for both FreeFileSync and RealTimeSync in your application menu. Once the visual installer finishes, you can safely delete both the original downloaded file and the extracted `.run` file from your Downloads folder.

    - Removing rclone

        Getting rid of unused tools is a great way to ensure a clean slate before setting up your new sync system.

        Because `rclone` can be installed in a few different ways on Linux, the removal process depends on how it was originally added to your system. To make this completely transparent, we will walk through the three most common methods. You can try them in order—if one doesn't work, simply move to the next.

        Here is how to completely remove `rclone` from your system:

        ### Method 1: The Package Manager (APT)

        If you installed `rclone` using Ubuntu or Mint's default software repositories, you can remove it using the standard package manager.

        1. Open your **Terminal**.

        2. Type the following command and press Enter:

        ```bash
        sudo apt remove rclone
        ```

        1. Type your password when prompted (the screen won't show characters as you type).

        2. To clean up any leftover dependencies that were installed with it but are no longer needed, run:

        ```bash
        sudo apt autoremove
        ```

        ### Method 2: The Official Installation Script

        If you used the official installation script from the `rclone` website, the software was placed directly into your system's binary folders. We just need to delete those specific files.

        1. Open your **Terminal**.

        2. Remove the main executable file:

        ```bash
        sudo rm /usr/bin/rclone
        ```

        1. Remove the manual (help) page file:

        ```bash
        sudo rm /usr/local/share/man/man1/rclone.1
        ```

        ### Method 3: Snap Package

        If you installed it via Canonical's Snap store, the removal is a single command.

        1. Open your **Terminal**.

        2. Run the following command:

        ```bash
        sudo snap remove rclone
        ```

        ### How to Verify the Removal

        To ensure the software is completely gone from your system, you can ask your terminal to check for its version.

        In your terminal, type:

        ```bash
        rclone version
        ```

        If the system responds with a message like `Command 'rclone' not found`, you have successfully removed the software and your system is clean and ready for your dedicated FreeFileSync setup.

    Creating a reliable, automated sync system is a great way to protect your files. Let's make this entire setup process completely transparent, breaking down exactly how the software behaves behind the scenes so you feel entirely in control of your data.

    Before we dive into the steps, we need to clarify how FreeFileSync handles storage to ensure it meets your expectations.

    FreeFileSync is a direct file synchronization tool, meaning it does not use a "temporary cache" system. Unlike virtual drive software (which stores a small cached amount locally while keeping the rest in the cloud), FreeFileSync will keep actual, full-sized copies of your files on both sides. Your 2TB external hard drive will physically store up to 2TB of your Google Drive data. If your goal is specifically to have a 1.5TB rotating cache where older files are offloaded to the cloud but remain visible on your computer, you would need a mounting tool like `rclone` instead of FreeFileSync.

    Assuming you want genuine offline access to your files via a straightforward two-way sync, FreeFileSync is an excellent choice. The file path `/media/ben/MyData` indicates you are using a Linux system (likely Ubuntu or Linux Mint).

    Here is how to set up your automated two-way mirror.

    ### Phase 1: Configuring the Two-Way Sync

    1. Open **FreeFileSync**.

    2. Click the **Browse** button next to the left-hand text field and navigate to your external drive at `/media/ben/MyData`.

    3. Click the **Cloud icon** next to the right-hand text field.

    4. Select **Google Drive** from the connection type menu and click **Add Connection**. This will open your web browser, prompting you to log into your Google account and grant FreeFileSync permission to access your files.

    5. Click the green **Gear icon** (Synchronization Settings) at the top of the window.

    6. Select **Two way** as the synchronization variant and click **OK**.

    7. Click the **Compare** button to let the software scan both your local drive and your Google Drive.

    8. Go to **File** in the top menu and select **Save as Batch Job**.

    9. Check the boxes for **Run minimized** and **Auto-Close** in the pop-up window so it runs quietly in the background in the future.

    10. Save this file as `GoogleDriveSync.ffs_batch` in a safe, permanent location on your computer (like your Documents folder).

    ### Phase 2: Automating with RealTimeSync

    FreeFileSync comes bundled with a companion application called RealTimeSync, which watches your folders for changes and automatically triggers the batch job you just created.

    1. Open the **RealTimeSync** application on your computer.

    2. Drag and drop the `GoogleDriveSync.ffs_batch` file you just saved directly into the RealTimeSync window.

    3. Verify that `/media/ben/MyData` automatically populates in the "Folders to watch" section. *Note: RealTimeSync cannot monitor Google Drive for instant cloud-side changes. It will trigger a sync whenever you change a file on your local hard drive, and during that sync, it will pull down any new changes made on the Google Drive side.*

    4. Set the **Idle time** to your preference (e.g., 10 seconds). This dictates how long the software waits after detecting a change before starting the sync, preventing it from syncing half-saved files.

    5. Go to **File** and click **Save As**, saving this configuration as `GoogleDriveWatcher.ffs_real` in the same safe location.

    ### Phase 3: Starting Automatically on Boot

    To ensure this runs the moment you turn on your computer, we need to add RealTimeSync to your startup sequence. **Note: Add custom command with path below.**

    1. Open your computer's application launcher and search for **Startup Applications** (or "Session and Startup", depending on your exact Linux layout).

    2. Click **Add** to create a new startup program.

    3. Type "Google Drive Sync" in the **Name** field.

    4. Type `RealTimeSync /home/ben/Documents/GoogleDriveWatcher.ffs_real` into the **Command** field. Replace the path if you saved the `.ffs_real` file in a different folder.

    5. Click **Save** and close the startup manager.

    Your external drive and Google Drive are now successfully paired and will sync automatically in the background.

    Are you running Ubuntu, or are you using a different Linux distribution that might require slightly different steps for the startup configuration?

