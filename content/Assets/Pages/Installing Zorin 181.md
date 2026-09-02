---
type: 'Page'
collections: 'Public Pages'
title: Installing Zorin 18.1
aliases: null
description: null
icon: ☄️
createdAt: '2026-06-04T12:23:36.261Z'
lastUpdated: '2026-08-26T16:47:48.107Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(10).md)'
---

# Installing Zorin 18.1

- System

    ![fastfetch3](../Images/Media/fastfetch3.png)
    [[fastfetch3|fastfetch3 - Notes]]

- Installing Zorin Wallpapers

    Yes. Since you’re running **Zorin OS 18.1**, the best “batch download” is actually better than downloading random ZIP files: **install the official wallpaper packages from previous Zorin releases**. Zorin maintains separate packages for releases 12, 15, 16, 17, and 18. (Zorin Forum)

    ### 1. Install the complete official Zorin collection

    Try:

    ```bash
    sudo apt update
    sudo apt install \
      zorin-os-wallpapers-12 \
      zorin-os-wallpapers-15 \
      zorin-os-wallpapers-16 \
      zorin-os-wallpapers-17 \
      zorin-os-wallpapers-18
    ```

    This is the option I recommend. The historical packages are substantial—roughly **25–46 MB per release**—and contain the original full-resolution files rather than compressed webpage copies.

    Zorin 18.1 itself uses `zorin-os-wallpapers-18`, and Zorin confirms these wallpaper packages are installed under the system wallpaper infrastructure. (Zorin Forum)

    After installation, look in:

    ```text
    /usr/share/backgrounds/
    ```

    They should also appear automatically under:

    **Settings → Appearance → Background**

    ### 2. Put all of them into one personal folder

    If you'd rather browse them from your Pictures directory:

    ```bash
    mkdir -p "$HOME/Pictures/Zorin Wallpapers"
    find /usr/share/backgrounds \
      -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
      -exec cp -n {} "$HOME/Pictures/Zorin Wallpapers/" \;
    ```

    That gives you one large folder containing the installed Zorin backgrounds.

    ### 3. There's also a downloadable Zorin 17 ZIP

    The Zorin community has put together a **Zorin OS 17 Wallpaper Pack ZIP** with a Google Drive download. The Zorin Forum thread provides the pack directly. (Zorin Forum)

    [Zorin OS 17 Default Backgrounds – download pack](https://forum.zorin.com/t/zorin-os-17-default-backgrounds/32368?utm_source=chatgpt.com)

    There's also a community-created set of Zorin accent-color wallpapers—green, orange, red, purple and grey—with a **high-quality ZIP download**. (Zorin Forum)

    [Zorin accent-colored wallpaper pack](https://forum.zorin.com/t/accent-colored-zorin-wallpapers-presented-in-z17/33108?utm_source=chatgpt.com)

    ### 4. Large unofficial Zorin collection

    The Zorin Forum also has a long-running **Unofficial ZorinOS Wallpapers Collection**, including dark, blue, purple, glowing, retro, galaxy and abstract Zorin-logo designs.

    [Image](https://images.openai.com/static-rsc-4/1W9o-sHPg7v4p9WgeEcohu8DkY_LDwLP_TnKoG-kMxRXC42y6F7MxEj6YtOkvlIa2u48nJUddpacBSzCRVphfPFOu1KCDFv9gZSxyDD08L9Ak7V9E4lmYE-Q1oQiSiCyD24DNKxufHYZ2CGNmkT9GfOGtBBHgLcErwG2U8ToYnf-N_gS4FMlG5iD6A3A3Sy2?purpose=fullsize)

    [Image](https://images.openai.com/static-rsc-4/NtQkJbcgcOG_3H7P5c-0mz55TEtyeNFd55CXL_miXWKeA3H3cI5Vuz-B_fBtiES5yAusBJx43quGvMwwtFo74Jb_a940Kol0-tbx4caDzRsgZxYZoRUDT3WJAWTnrrrwGExmzlmJ2KZ4j-WcUXIB3AQlN__vKMEmz-IAL8afl9yoxkuSmbw4Awy8idrSBN9k?purpose=fullsize)

    [Image](https://images.openai.com/static-rsc-4/zDoQlr5zKISt4PAyxfaEuRXlStHfATIH2krIl-cPp9VGNJ8kX03kwuezwX3m349CkmaFjpkdD9wCGF78D3LiEbPnudCPS2_9o1DtKtgQ6-nJLlSIJVE-Hcz7x_DLGHT7CNPRGyudmHUBDK8Kno5flE5n43SF1mRvTGUS5brJknCv8b5TlAMI7b-5QjN281TC?purpose=fullsize)

    [Unofficial ZorinOS Wallpapers Collection](https://forum.zorin.com/t/unofficial-zorinos-wallpapers-collection/17415?utm_source=chatgpt.com)

    ### What I'd install

    For a fresh Zorin 18.1 system, I'd install **12 + 15 + 16 + 17 + 18** with the first command. That gives you a large curated collection that matches Zorin's visual style, without having to hunt through wallpaper websites.

    If you want, I can also find you a **single 1–5 GB batch pack of 4K/5K/8K wallpapers specifically suited to Zorin's blue/dark aesthetic**—nature, abstract, minimal, and Windows-11-style backgrounds rather than just the official Zorin wallpapers.

    [1]: https://forum.zorin.com/t/zorin-wallpapers/49023?utm_source=chatgpt.com "Zorin Wallpapers - Customization - Zorin Forum"

    [2]: https://forum.zorin.com/t/semi-broken-18-upgrade-repair-install/54600?utm_source=chatgpt.com "Semi-broken 18 Upgrade - repair install? - Installing Zorin OS - Zorin Forum"

    [3]: https://forum.zorin.com/t/zorin-os-17-default-backgrounds/32368?utm_source=chatgpt.com "Zorin OS 17: Default Backgrounds - Customization - Zorin Forum"

    [4]: https://forum.zorin.com/t/accent-colored-zorin-wallpapers-presented-in-z17/33108?utm_source=chatgpt.com "Accent colored ZORIN wallpapers presented in Z17 - Customization - Zorin Forum"

- Installing Qualcoder package

    Installing QualCoder on Ubuntu is straightforward. Since it is a Python-based application, you have two primary ways to set it up: using a standalone executable (the easiest route) or installing it from the source code via the terminal (best for maximum system compatibility and media support).

    Here is exactly how to do both.

    ### Method 1: Using the Pre-built Executable (Easiest)

    This method doesn't require any command-line knowledge and functions much like a standard portable app.

    1. Navigate to the [QualCoder Releases page on GitHub](https://github.com/ccbogel/QualCoder/releases).

    2. Download the latest Linux executable file (it will typically look something like `QualCoder_3.8.2_ubuntu`).

    3. Once downloaded, you need to grant the file permission to run.

    - **Using the GUI:** Right-click the downloaded file, select **Properties**, go to the **Permissions** tab, and check the box that says "Allow executing file as program."

    - **Using the Terminal:** ```bash
    cd ~/Downloads
    chmod +x QualCoder_*_ubuntu

    ```text
    
    ```

    1. Double-click the file to launch the application.

    ---

    ### Method 2: Installing from Source (Best for Compatibility)

    If you are running an older or newer version of Ubuntu where the standalone executable acts up, or if you plan to code audio and video files, compiling from source inside a Python virtual environment is the recommended path.

    **1. Install System Dependencies**
    Open your terminal and ensure you have Python 3, `pip`, the virtual environment module, and VLC (required if you intend to analyze audio/video files) installed:

    ```bash
    sudo apt update
    sudo apt install python3 python3-pip python3-venv vlc
    ```

    **2. Download the QualCoder Code**
    Clone the repository to your machine and move into the newly created directory:

    ```bash
    git clone https://github.com/ccbogel/QualCoder.git
    cd QualCoder
    ```

    **3. Set Up a Virtual Environment**
    Creating a virtual environment ensures that QualCoder’s dependencies don’t conflict with your core Ubuntu system packages:

    ```bash
    python3 -m venv env
    source env/bin/activate
    ```

    **4. Install Python Dependencies & Build**
    With your virtual environment active (you will see `(env)` at the start of your terminal prompt), install the required modules and the package itself:

    ```bash
    python3 -m pip install --upgrade pip
    pip install -r requirements.txt
    python3 -m pip install .
    ```

    **5. Launch QualCoder**
    Once the installation finishes, you can start the application by running:

    ```bash
    python3 -m qualcoder
    ```

    > **Note for Future Use:** Whenever you want to use QualCoder again using this method, open your terminal, navigate to the `QualCoder` folder, reactivate the environment (`source env/bin/activate`), and run the launch command (`python3 -m qualcoder`).

- Setting up HP LaserJet P1102w printer

    For a fresh Zorin OS 18.1 installation, use this order: **update Zorin → connect by USB first → let Zorin detect the printer → install HPLIP Toolbox only if automatic setup fails**. Zorin includes HP’s HPLIP drivers, and its own documentation recommends `hplip-gui` rather than downloading an installer from HP. 

    ## 1. Update the system

    Open **Zorin Menu → Utilities → Terminal** and run:

    ```bash
    sudo apt update
    sudo apt full-upgrade
    sudo reboot
    ```

    After restarting, connect the printer’s USB cable and turn the printer on. Wait about 30 seconds.

    ## 2. Try automatic USB installation

    Open:

    **Zorin Menu → Settings → Printers**

    If **HP LaserJet Professional P1102w** or a similar name appears:

    1. Select it.

    2. Click **Add**.

    3. Open the printer’s settings.

    4. Choose **Print Test Page**.

    If it prints successfully, no additional driver installation is needed.

    You can also confirm that Zorin sees the USB device:

    ```bash
    lpstat -t
    ```

    A successfully configured printer normally appears in the output as a printer queue.

    ## 3. Install HPLIP Toolbox

    If the printer does not appear, install the graphical HP utility:

    ```bash
    sudo apt update
    sudo apt install hplip-gui
    ```

    If prompted to install additional dependencies, accept them.

    Then open:

    **Zorin Menu → System Tools → HPLIP Toolbox**

    In HPLIP Toolbox:

    1. Open **Device**.

    2. Choose **Setup Device…**

    3. Select **USB**.

    4. Select the P1102w when it appears.

    5. Accept the suggested printer model and driver.

    6. Give the printer a short name, such as `HP-P1102w`.

    7. Select **Set as default printer** if desired.

    8. Finish the setup and print a test page.

    The equivalent terminal command is:

    ```bash
    hp-setup
    ```

    For a USB printer, try:

    ```bash
    hp-setup -i
    ```

    When asked for the connection type, choose the USB device shown by HPLIP.

    ## 4. If HPLIP requests a proprietary plug-in

    Some P1102w units require HP’s firmware plug-in. Install the helper tools:

    ```bash
    sudo apt install hplip hplip-data printer-driver-hpcups
    ```

    Then run:

    ```bash
    hp-plugin
    ```

    Follow the prompts to download and install the plug-in. After it completes, restart the printer and run:

    ```bash
    hp-setup
    ```

    If `hp-plugin` cannot download the plug-in, check that the computer is online and try again. Avoid using an old `.run` installer downloaded from HP unless the repository version fails; distribution packages are generally better integrated with Zorin.

    ## 5. Set up the printer over Wi‑Fi

    The P1102w often needs to be configured over USB before it can join Wi‑Fi. Keep the USB cable connected during this step.

    First, ensure the computer is connected to the Wi‑Fi network you want the printer to use. Then run:

    ```bash
    hp-setup
    ```

    Choose:

    1. **Wireless/802.11**

    2. The P1102w

    3. Your Wi‑Fi network name

    4. The Wi‑Fi password

    If HPLIP does not show a wireless option, use the USB setup first and open the HP device configuration in HPLIP Toolbox.

    After wireless configuration:

    1. Disconnect the USB cable.

    2. Restart the printer.

    3. Open **Settings → Printers**.

    4. Click **Add a Printer…**

    5. Wait for the wireless P1102w to appear.

    6. Add it and print a test page.

    The computer and printer must be connected to the same network. HP also indicates that a USB cable is required when initially configuring this model’s wireless connection. 

    ## 6. If the wireless printer is not discovered

    Print a network configuration page from the printer or use your router’s connected-device list to find the printer’s IP address. Then open:

    **Settings → Printers → Additional Printer Options… → Add**

    Enter the printer’s network address. You can also use the terminal:

    ```bash
    lpinfo -v
    ```

    Look for a URI containing the printer’s IP address. A common HP network URI is:

    ```text
    socket://PRINTER-IP-ADDRESS:9100
    ```

    For example:

    ```text
    socket://192.168.1.45:9100
    ```

    You can create a queue manually with:

    ```bash
    sudo lpadmin -p HP-P1102w \
      -E \
      -v socket://192.168.1.45:9100 \
      -m drv:///hpcups.drv/hp-laserjet_professional_p1102w.ppd
    ```

    Replace `192.168.1.45` with the printer’s actual IP address. Set it as the default printer if required:

    ```bash
    sudo lpadmin -d HP-P1102w
    ```

    Check the queue:

    ```bash
    lpstat -p -d
    ```

    ## 7. Remove duplicate or failed printer entries

    If several incorrect entries appear, remove them from **Settings → Printers**, or use:

    ```bash
    lpstat -p
    ```

    Then delete an unwanted queue:

    ```bash
    sudo lpadmin -x PRINTER-NAME
    ```

    For example:

    ```bash
    sudo lpadmin -x HP-P1102w
    ```

    After deleting failed queues, restart the print service:

    ```bash
    sudo systemctl restart cups
    ```

    Then repeat the automatic or HPLIP setup.

    ## 8. Common problems

    **Printer appears but will not print**

    ```bash
    sudo systemctl restart cups
    cancel -a
    ```

    Then power-cycle the printer and retry.

    **“Driverless” or AirPrint does not work**

    The P1102w is an older model, and some units do not support modern driverless printing without a firmware update. Use the HPLIP/hpcups driver instead. Some versions of this printer may require a firmware update performed from Windows before certain network features work. 

    **HPLIP says the device is not found**

    Try a different USB port and avoid a USB hub. Confirm detection with:

    ```bash
    lsusb
    ```

    Then restart the printer and run:

    ```bash
    hp-setup -i
    ```

    **Jobs remain stuck**

    ```bash
    cancel -a
    sudo systemctl restart cups
    ```

    If necessary, delete and recreate the printer queue.

    **Printer works by USB but not Wi‑Fi**

    Configure wireless while connected by USB, confirm that the printer received an IP address, and ensure both devices are on the same network—not a guest network or isolated Wi‑Fi network.

    The simplest reliable path is therefore:

    ```bash
    sudo apt update
    sudo apt install hplip-gui
    hp-setup -i
    ```

    Use **USB** in the setup wizard first. Once USB printing works, configure Wi‑Fi through HPLIP and then add the discovered network printer in **Settings → Printers**.

- System Resources

    - Auto-connect Bose Flex SE Bluetooth speaker on boot

        These steps make Zorin OS (18.1 / Ubuntu-based) automatically connect your **Boxe Flex SE** speaker after you log in (on every boot).

        ## 0) Prereqs

        - Make sure Bluetooth is enabled and working.

        - Do the initial pairing once (steps below).

        ## 1) Pair + trust the speaker (one time)

        1. Put the speaker into pairing mode.

        2. On Zorin: **Settings → Bluetooth** → turn Bluetooth **On** → select **Boxe Flex SE** → **Pair**.

        3. Verify it shows as **Paired** and **Connected** at least once.

        ## 2) Get the speaker’s MAC address

        Open a terminal and run:

        ```bash
        bluetoothctl devices
        ```

        You’ll see something like:

        ```text
        Device AA:BB:CC:DD:EE:FF Boxe Flex SE
        ```

        Copy the MAC address (e.g., `AA:BB:CC:DD:EE:FF`).

        ## 3) Mark it as trusted + enable auto-connect (recommended)

        Run:

        ```bash
        bluetoothctl
        ```

        Then (replace the MAC address):

        ```text
        power on
        agent on
        default-agent
        trust AA:BB:CC:DD:EE:FF
        pair AA:BB:CC:DD:EE:FF
        connect AA:BB:CC:DD:EE:FF
        quit
        ```

        Notes:

        - `trust` helps BlueZ allow reconnection without prompting.

        - If it’s already paired, `pair` may say it’s already paired — that’s fine.

        ## 4) Create an auto-connect script

        ```bash
        mkdir -p ~/.local/bin
        nano ~/.local/bin/bt-connect-boxe-flex-se.sh
        ```

        Paste (replace MAC):

        ```bash
        #!/usr/bin/env bash
        set -euo pipefail
        MAC="AA:BB:CC:DD:EE:FF"
        # Give Bluetooth + the desktop a moment to come up after login
        sleep 8
        # Try a few times in case the speaker is still waking up
        for i in {1..8}; do
          bluetoothctl connect "$MAC" && exit 0
          sleep 2
        done
        exit 1
        ```

        Make it executable:

        ```bash
        chmod +x ~/.local/bin/bt-connect-boxe-flex-se.sh
        ```

        ## 5) Run it automatically on boot (at login) via Startup Applications (easy)

        1. Open **Startup Applications** (search in the Zorin menu).

        2. Click **Add**.

        3. Name: `Bluetooth speaker auto-connect`

        4. Command:

            ```text
            /home/ben/.local/bin/bt-connect-boxe-flex-se.sh
            ```

        5. Save.

        ## 6) (More robust) Run it automatically via systemd user service

        This is usually more reliable than Startup Applications.

        ### 6.1 Create the service file

        ```bash
        mkdir -p ~/.config/systemd/user
        nano ~/.config/systemd/user/bt-connect-boxe-flex-se.service
        ```

        Paste:

        ```text
        [Unit]
        Description=Auto-connect Boxe Flex SE Bluetooth speaker
        After=bluetooth.target
        Wants=bluetooth.target
        [Service]
        Type=oneshot
        ExecStart=%h/.local/bin/bt-connect-boxe-flex-se.sh
        [Install]
        WantedBy=default.target
        ```

        Enable it:

        ```bash
        systemctl --user daemon-reload
        systemctl --user enable --now bt-connect-boxe-flex-se.service
        ```

        Check status:

        ```bash
        systemctl --user status bt-connect-boxe-flex-se.service
        ```

        ## Troubleshooting

        - If the speaker doesn’t connect, ensure it’s powered on before (or soon after) login.

        - If it connects but audio still plays through the laptop: **Settings → Sound → Output** and select the speaker once; Zorin usually remembers it.

        - To debug connection attempts:

            ```bash
            journalctl --user -u bt-connect-boxe-flex-se.service --no-pager
            ```

    - Avoid system log eating up disk space

        Zorin OS, like many Ubuntu-based distributions, can experience rapid disk space consumption due to a few specific "hidden" culprits. Most of these are part of standard system maintenance that isn't always automated for aggressive space-saving.

        Here are the primary causes and the settings you can adjust to prevent it.

        ## 1. Runaway System Logs (`/var/log`)

        This is the most common reason for sudden, massive disk usage. If a system process or a hardware driver encounters a recurring error, it can write to the `syslog` or `kern.log` thousands of times per second.

        - **The Cause:** Logs that aren't "rotated" or deleted quickly enough.

        - **The Prevention:** Limit the size of the system journal.

            1. Open the terminal and edit the configuration:

            ```bash
            sudo nano /etc/systemd/journald.conf
            ```

            1. Find the line `#SystemMaxUse=` and change it to:

                `SystemMaxUse=500M` (or your preferred limit).

            2. Remove the `#` at the start of the line to enable it, then save (**Ctrl+O**, **Enter**) and exit (**Ctrl+X**).

            3. Apply the change:

                ```bash
                sudo systemctl restart systemd-journald
                ```

        ## 2. Flatpak and Snap Runtimes

        Zorin OS heavily integrates **Flatpak** and **Snap**, which are great for app compatibility but are notorious for "storage bloat." They often keep old versions of runtimes (libraries) that are no longer needed.

        - **The Cause:** Every time an app updates, the old version or its dependencies might stay on the disk.

        - **The Prevention:** Run periodic cleanup commands.

            - **For Flatpaks:** `flatpak uninstall --unused`

            - **For Snaps:** By default, Snaps keep 3 versions of every app. You can reduce this to 2:

                `sudo snap set system refresh.retain=2`

        ## 3. Package Manager Cache (`APT`)

        Every time you update your software, Zorin downloads `.deb` files to `/var/cache/apt/archives/`. These files stay there even after the software is installed.

        - **The Cause:** Accumulation of old installation files.

        - **The Prevention:** Clear the cache regularly.

            - `sudo apt clean` (Removes all cached packages).

            - `sudo apt autoremove` (Removes dependencies that were installed for apps you've since deleted).

        ## 4. Old Kernel Versions

        When Zorin updates your system kernel for security, it keeps the old ones as a "fail-safe" in case the new one doesn't boot. Over time, these can take up several gigabytes.

        - **The Prevention:** Use `sudo apt autoremove --purge` regularly. This will safely remove old kernels while keeping the current one and one backup.

        ---

        ### Pro-Tip: Identifying the Culprit

        If your disk is filling up right now and you don't know why, use the built-in **Disk Usage Analyzer** (search for "Baobab" in the menu). It provides a visual map of your folders.

        - **Check** `/var/log`**:** If it's over 2GB, your logs are the problem.

        - **Check** `/var/lib/flatpak`**:** If this is huge, you have too many "Universal" apps.

        - **Check** `~/.cache`**:** This is your user cache (browser data, thumbnails). You can safely clear this by running `rm -rf ~/.cache/*`.

    - Installing Preload - [https://pkgs.org/download/preload](https://pkgs.org/download/preload)

        ```bash
        sudo apt install preload
        ```

    - Enabling TRIM

        💡 TRIM is a command that helps optimize SSDs by informing them which data blocks are no longer in use and can be erased, improving performance and extending the drive's lifespan.

        ```jsx
        sudo fstrim -v /
        sudo systemctl enable fstrim.timer
        sudo systemctl start fstrim.timer
        systemctl status fstrim.timer
        ```

    - Setting up FreeFileSync Google Drive-External Hard Drive Mirror

        - Saving batch job configuration

            For a batch job—which is usually meant to run automatically in the background without needing your attention—you'll want to configure this so it stays out of your way. When you're leading a session and sharing your screen with your learners, the last thing you want is a giant sync window popping up and interrupting your flow.

            Here is the ideal configuration for an unobtrusive, automated sync:

            ### 1. Progress dialog

            - **Check "Run minimized":** This forces FreeFileSync to start quietly in your system tray or taskbar rather than throwing a large progress window in the middle of your screen.

            - **Check "Auto-close":** This ensures that once the sync finishes successfully, the program shuts itself down completely, keeping your desktop clean.

            ### 2. Error handling

            - **Keep "Show error message" selected:** This is the safest bet. If the sync goes perfectly, it will auto-close silently. However, if your external hard drive gets disconnected or your Google Drive connection drops, it will prompt you with an error.

            - *Alternative:* If you want absolute silence no matter what (e.g., you don't care if a scheduled sync misses a beat because it will just catch up next time), you can select **Ignore errors**.

            ### 3. When finished

            - **Leave this blank:** Unless you want your entire computer to shut down, sleep, or run a custom script after the sync finishes, you don't need to select anything from this dropdown.

            Once you set these preferences, click **Save as...** and save the `.ffs_batch` file somewhere safe on your Zorin OS drive (like your Documents folder). You can then use this file to trigger the sync manually with a double-click, or tie it to a task scheduler for true automation.

        - Setting up FreeFileSync Mirror Schedule

            For continuous, automated syncing on Linux, you have two great options depending on how you want the system to behave.

            The standard recommendation is to use the native background monitor that comes bundled with FreeFileSync, but you can also use Zorin's built-in system scheduler if you strictly want a 15-minute timer.

            ## 1. RealTimeSync (The Recommended, Native Method)

            When you installed FreeFileSync, a companion application called **RealTimeSync** was installed alongside it. Instead of running on a rigid timer, it monitors your folders for changes and syncs automatically. This is generally preferred for Two-Way syncs because it is highly efficient and reacts to your workflow.

            - **Open RealTimeSync:** Search for it in your Zorin OS application menu.

            - **Import Your Batch File:** Click **File > Open** and select the `.ffs_batch` file you saved earlier. RealTimeSync will automatically populate the "Folders to Watch" section.

            - **Set the Idle Time:** This is the delay between when a file change is detected and when the sync runs. Setting this to `10` or `20` seconds ensures it doesn't try to sync a file while you are still actively saving it.

            - **Start Monitoring:** Click **Start**. The app will minimize to your system tray.

            To ensure this runs automatically every time you reboot your laptop:

            1. Open Zorin's **Startup Applications** tool.

            2. Click **Add**.

            3. Name it "Drive Sync" and in the Command field, type `RealTimeSync` followed by a space, and then the exact path to your batch file (e.g., `RealTimeSync /home/username/.scripts/sync.ffs_batch`).

            ## 2. Cron (The Strict 15-Minute Timer Method)

            If you do not want an app constantly monitoring your folders and prefer a strict schedule that executes exactly every 15 minutes, you can use `cron`, the built-in Linux task scheduler.

            1. Open your Terminal.

            2. Type `crontab -e` and press Enter. (If it asks you to choose an editor, press `1` to use Nano).

            3. Use your arrow keys to scroll to the very bottom of the text file and add this exact line:

                - `/15 * * * * env DISPLAY=:0 FreeFileSync /path/to/your/batch_file.ffs_batch`

            4. Save and exit (if using Nano, press **Ctrl+O**, then **Enter**, then **Ctrl+X**).

            *Important technical note:* Because FreeFileSync is technically a graphical application (even when running your silent, minimized batch job), the `env DISPLAY=:0` parameter is required. It tells the invisible background task which desktop session to attach to so it doesn't fail.

        Here is the step-by-step guide to setting up a true mirror from your Google Drive to your external hard drive using the FreeFileSync interface shown in your screenshot.

        Setting up a "Mirror" means FreeFileSync will make the right side (your external drive) an exact copy of the left side (Google Drive). If you delete a file on Google Drive, it will be deleted on your external drive, but adding a file to the external drive will *not* push it back up to Google Drive.

        ### Phase 1: Setting Your Source and Target

        Looking at the FreeFileSync window you have open, we need to define the Left pane as the cloud source and the Right pane as the local destination.

        1. **Connect Google Drive (Left Pane):**

            - Look at the left side, right next to the "Browse" button. Click the small **Cloud icon** (☁️).

            - A "Cloud Connection" window will pop up. Click **Add Connection** and select **Google Drive**.

            - This will open your default web browser. Log into your Google account and grant FreeFileSync permission to access your files.

            - Once authenticated, return to FreeFileSync. Your Google Drive root directory will now be selected as the left folder.

        2. **Select External Drive (Right Pane):**

            - On the right side, click the standard **Browse** button.

            - Navigate to your external hard drive. On Zorin OS, external drives are usually found under **Other Locations** or mounted directly in `/media/[your_username]/[Drive_Name]`.

            - Select the specific folder on the external drive where you want the Google Drive files to live, and click **Open**.

        ### Phase 2: Changing the Sync Settings to "Mirror"

        By default, FreeFileSync is set to "Two way" synchronization (you can see this under the large "Synchronize" button in the top right of your screenshot). We need to change this.

        1. **Open Sync Settings:** Click the **Green Gear icon** located immediately to the left of the large "Synchronize" button at the top right.

        2. **Select Mirror:** In the settings window that appears, you will see a few large variants. Click **Mirror**.

            - *Note: Ensure the arrow points from Left to Right (Google Drive → External Drive).*

        3. **Click OK** at the bottom right to close the settings window. The main interface should now show a green arrow pointing to the right under the Synchronize button.

        ### Phase 3: Compare and Run

        Before any files are moved, FreeFileSync requires you to "Compare" the folders so you can see exactly what will happen.

        1. **Run the Comparison:** Click the large **Compare** button (with the magnifying glass) at the top left.

        2. **Review the Plan:** FreeFileSync will scan your Google Drive and your external drive. It will populate the middle columns with icons indicating what actions it will take (e.g., a green plus sign means a file will be copied, a red trash can means a file will be deleted to maintain the mirror).

        3. **Execute the Sync:** Once you are satisfied with the proposed changes, click the large **Synchronize** button at the top right.

        4. **Confirm:** A final summary prompt will appear. Click **Start** to begin the transfer.

        ### Phase 4: Save the Configuration (Optional but Recommended)

        To save yourself from having to authenticate and set up the paths every time:

        1. Go to the **Configuration** panel on the far left (where it currently says `[Last session]`).

        2. Click the **Save as...** floppy disk icon in that left-hand panel.

        3. Name it something recognizable (e.g., "GDrive to External Backup").

        4. Next time you open FreeFileSync, just double-click that configuration name, click Compare, and click Synchronize.

- Convert Word documents to PDFs (w/LibreOffice)

    Since Zorin OS is based on Ubuntu, you already have the absolute best tool for this pre-installed on your system: **LibreOffice**.

    While you can open LibreOffice and click through menus, doing this for a large batch of documents is incredibly tedious. Instead, you can use the Linux Terminal to run LibreOffice in **headless mode** (meaning it runs in the background without opening the visual software) to instantly convert dozens or hundreds of files at once.

    Here are the best ways to get this done, ranging from a quick single line of code to a neat desktop shortcut.

    ## Method 1: The One-Line Terminal Command (Fastest)

    If all your Word files (`.docx` or `.doc`) are sitting in a single folder, this is the most direct approach.

    1. Open your **Files** app and navigate to the folder where your Word documents are saved.

    2. Right-click anywhere in the empty space of that folder and select **Open in Terminal**.

    3. Paste the following command and hit **Enter**:

    ```bash
    libreoffice --headless --convert-to pdf *.docx
    ```

    ### How it works:

    - `-headless`: Tells Zorin to process the files without launching the full LibreOffice user interface.

    - `-convert-to pdf`: Sets the target format.

    - `.docx`: The asterisk acts as a wildcard, instructing the system to capture *every single* file ending in `.docx` in that directory. If you have older `.doc` files, simply run it a second time changing the extension to `.doc`.

    ## Method 2: The "Advanced" Terminal Script (For Subfolders)

    If your documents are organized across multiple nested folders and you want to convert them all without moving them around, you can use a simple `find` loop.

    Open a terminal in your main directory and run:

    ```bash
    find . -name "*.docx" -exec libreoffice --headless --convert-to pdf {} \;
    ```

    > **Note:** This will find every `.docx` file in the current folder and any subfolder beneath it, generating a matching PDF right alongside the original Word file.

    ## Method 3: Create a Drag-and-Drop Desktop Shortcut (No Code Needed Later)

    If you plan on doing this frequently and prefer a purely visual approach, you can create a dedicated script on your desktop. Once set up, you just drop files onto it.

    Now, whenever you have a batch of Word documents, you can simply select them all in your file manager and drag-and-drop them right on top of that desktop file. Zorin will process them seamlessly in the background.

    > **💡 A Quick Reality Check on Layouts**

    Because LibreOffice is doing the rendering engine work under the hood, 95% of standard text documents, lesson plans, and assignments will convert perfectly. However, if any of your Word documents contain complex Microsoft-specific layouts (like intricate multi-column tables or dense overlapping text boxes), the formatting might shift slightly in the final PDF.

    If you notice a specific document layout breaking, do you have Microsoft fonts installed on your Zorin system, or are you currently relying on Linux defaults like LibreOffice's built-in alternatives?

    **1.Create the script file:**

    Step 1.

    Right-click on your Desktop, choose **Create New Document** -> **Empty Document**, and name it `WordToPDF.sh`.

    **2.Add the script logic:**

    Step 2.

    Open the file with your text editor and paste the following text inside:

    ```bash
    #!/bin/bash
    libreoffice --headless --convert-to pdf "$@"
    ```

    Save and close the file.

    Right-click your new `WordToPDF.sh` file, go to **Properties**, switch to the **Permissions** tab, and check the box that says **Allow executing file as program**.

    ```bash
    
    ```

- Setting up appimage installation

    ### How to Run AppImages in Zorin OS 18.1

    To get AppImages working in Zorin OS 18.1, you need the FUSE 2 library, which allows the operating system to read and mount these compressed files. Because Zorin 18.1 is based on modern Ubuntu architecture, the specific package you need is `libfuse2t64`.

    It's worth noting a quick technical detail: AppImages aren't actually "installed" in the traditional sense. Instead, they are entirely self-contained, portable applications that run directly from wherever you save them (like your Downloads or a dedicated Applications folder).

    Here is how to set up your system and run them:

    **1. Install the Required Package**
    Open your terminal and run the following commands to install the FUSE compatibility library:

    ```bash
    sudo apt update
    sudo apt install libfuse2t64
    ```

    **2. Make the AppImage Executable**
    By default, Linux will not let you run a downloaded file for security reasons. You have to explicitly grant it permission to execute.

    - **Via GUI:** Right-click the downloaded `.AppImage` file > **Properties** > **Permissions** > check the box that says **Allow executing file as program**.

    - **Via Terminal:** Alternatively, you can run `chmod +x /path/to/your-app.AppImage`

    **3. Run the App**
    Simply double-click the `.AppImage` file to launch the program.

    Since AppImages are portable, they won't automatically show up in your main Zorin OS application menu. If you want to seamlessly integrate them into your app launcher, you can download an optional management tool like **Gear Lever** from the Zorin Software store.

    ---

    [Manage and Install AppImages Easily - Tutorial](https://www.youtube.com/watch?v=1AU2Jxn68jo)[[Manage and Install AppImages Easily - Tutorial|Manage and Install AppImages Easily - Tutorial - Notes]]

    
    This video provides a great visual walkthrough on how to handle AppImages on modern Linux distributions, including setting up the required libraries and using management tools.

- Installing QualCoder

    QualCoder is an open-source qualitative data analysis tool. On Zorin 18.1 (Ubuntu-based), the simplest install is via the project’s **.deb** package.

    ## Install using the .deb package (recommended)

    1. Download the latest `.deb` from:

        - [https://github.com/ccbogel/QualCoder/releases](https://github.com/ccbogel/QualCoder/releases)

    2. Install it (from your Downloads folder):

    ```bash
    cd ~/Downloads
    sudo apt install ./qualcoder*.deb
    ```

    ## Launch

    Open **QualCoder** from the Applications menu (or search in the Zorin menu).

    ## Updating / uninstalling

    - Update: install a newer `.deb` the same way (it will upgrade).

    - Uninstall:

    ```bash
    sudo apt remove qualcoder
    ```

- Installing fonts

    When installing Microsoft fonts on Ubuntu, the fonts are generally split into three distinct collections based on how they are legally distributed and packaged.

    ---

    ## 1. TrueType Core Fonts (Classic Windows Fonts)

    These are the most common web-safe fonts. Ubuntu includes an automated installer in its official multi-verse repositories to fetch and unpack them legally.

    - **Andale Mono**

    - **Arial** (Regular, Bold, Italic, Bold Italic)

    - **Arial Black**

    - **Comic Sans MS** (Regular, Bold)

    - **Courier New** (Regular, Bold, Italic, Bold Italic)

    - **Georgia** (Regular, Bold, Italic, Bold Italic)

    - **Impact**

    - **Times New Roman** (Regular, Bold, Italic, Bold Italic)

    - **Trebuchet MS** (Regular, Bold, Italic, Bold Italic)

    - **Verdana** (Regular, Bold, Italic, Bold Italic)

    - **Webdings**

    ### How to Install:

    Run the following commands in your terminal:

    Bash

    `sudo apt update
    sudo apt install ttf-mscorefonts-installer`

    > **Important:** During the terminal installation, a Microsoft EULA agreement screen will appear. Press the **Tab** key to highlight **OK**, hit **Enter**, and then select **Yes** to accept the license.

    ---

    ## 2. ClearType Fonts (MS Office Era)

    These are the standard document fonts introduced with Windows Vista and Microsoft Office 2007. They are not in the standard Ubuntu repositories but can be cleanly extracted from official Microsoft viewer packages using `cabextract`.

    - **Calibri** (Regular, Bold, Italic, Bold Italic)

    - **Cambria** / **Cambria Math**

    - **Candara**

    - **Consolas**

    - **Constantia**

    - **Corbel**

    ### How to Install:

    You can use a widely trusted community installation script to automate the layout conversion and extraction:

    Bash

    `sudo apt install fontforge cabextract
    wget https://gist.github.com/maxwelleite/10774746/raw/ttf-vista-fonts-installer.sh -q -O - | sudo bash`

    ---

    ## 3. UI and Modern Office Fonts (Tahoma, Segoe UI, Aptos)

    Fonts like **Tahoma**, **Segoe UI** (the Windows desktop environment font), and **Aptos** (the default default font for Microsoft 365) must be added manually since there is no native automated linux package for them.

    ### How to Install:

    If you have a dual-boot setup or access to a Windows machine, copy the font files from `C:\Windows\Fonts` to a flash drive or external storage.

    Then, move those `.ttf` or `.otf` files into your Ubuntu system:

    1. **Create a local font folder:**Bash

        `mkdir -p ~/.local/share/fonts/microsoft/`

    2. **Move or copy the font files** into that directory.

    3. **Rebuild the font cache** so Ubuntu recognizes them globally:Bash

        `fc-cache -f -v`

    ---

    ## Verifying the Installation

    To ensure the fonts are correctly registered by your system, check the system font registry using the terminal:

    Bash

    `fc-list : family | grep -iE 'arial|times|calibri|segoe' | sort -u`

    The new font options will immediately become available in LibreOffice, OnlyOffice, Kdenlive, GIMP, and your desktop configuration tools.

- Installing and Configuring Dolphin

    - Setting up icons in Dolphin

        That is expected. **GNOME Tweaks changes GTK/GNOME icon settings, while Dolphin is a KDE/Qt application and uses KDE/Qt icon-theme configuration.** On Zorin OS 18.1, the repository version of Dolphin is KDE Frameworks 5 / Qt 5, so `qt5ct` is the appropriate configuration tool. (Zorin)

        The cleanest fix is:

        ```bash
        sudo apt install qt5ct
        ```

        Then set Qt applications to use it:

        ```bash
        echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.profile
        ```

        Log out of Zorin and log back in. Then launch:

        ```bash
        qt5ct
        ```

        In **qt5ct → Icon Theme**, select the same icon theme you are using in GNOME Tweaks, assuming that theme includes suitable KDE/Qt icons. Click **Apply**.

        This approach is commonly used specifically for running Dolphin outside KDE/Plasma; Dolphin otherwise may not inherit the GNOME icon-theme choice. (Arch Wiki)

        ### Check whether your GNOME icon theme is available

        You can see installed icon themes with:

        ```bash
        ls ~/.icons
        ls ~/.local/share/icons
        ls /usr/share/icons
        ```

        For example, if GNOME Tweaks is using **Papirus**, you should see directories such as:

        ```text
        Papirus
        Papirus-Dark
        Papirus-Light
        ```

        Then select the corresponding one in `qt5ct`.

        ### If you want GNOME and Dolphin to match especially well

        I recommend **Papirus** because it has very good coverage for both GTK/GNOME and KDE applications:

        ```bash
        sudo apt install papirus-icon-theme
        ```

        Then:

        **GNOME Tweaks**
        → Appearance
        → Icons
        → **Papirus** or **Papirus-Dark**

        and:

        **qt5ct**
        → Icon Theme
        → **Papirus** or **Papirus-Dark**

        You would then have something much closer to:

        ```text
        Zorin / GNOME
        ├── GNOME apps ─────────── Papirus
        ├── LibreOffice ────────── Papirus
        └── KDE apps
            └── Dolphin ────────── Papirus
        ```

        ### One thing I would avoid

        Don't install the complete KDE Plasma desktop merely to control Dolphin's appearance. You already have the necessary KDE libraries with Dolphin. Adding Plasma can introduce extra settings daemons, duplicate applications, and competing desktop defaults.

        Your existing Zorin + Dolphin setup can be made visually consistent with just **qt5ct + a shared icon theme**.

        If you tell me **which icon set you are currently selecting in GNOME Tweaks**, I can give you the exact setting needed to make Dolphin use that same set.

        [1]: https://zorin.com/os/details/?utm_source=chatgpt.com "Technical details - Zorin OS"

        [2]: https://wiki.archlinux.org/title/Dolphin_%28Espa%C3%B1ol%29?utm_source=chatgpt.com "Dolphin (Español) - ArchWiki"

    Yes. In Zorin OS 18.1, you can make **Dolphin your default file manager**, but there is a separate issue with the **Open/Save dialogs inside applications** such as LibreOffice.

    An application’s Open/Save window is normally a *file chooser*, not the file manager itself. On Zorin’s GNOME desktop it normally uses a GTK/GNOME chooser. XDG Desktop Portal explicitly allows GNOME, GTK, KDE, etc. to provide different chooser backends. (Flatpak)

    ### 1. First, make Dolphin the default file manager

    Run:

    ```bash
    xdg-mime default org.kde.dolphin.desktop inode/directory
    xdg-mime default org.kde.dolphin.desktop application/x-gnome-saved-search
    ```

    Then verify:

    ```bash
    xdg-mime query default inode/directory
    ```

    You want:

    ```text
    org.kde.dolphin.desktop
    ```

    You can also run:

    ```bash
    gio mime inode/directory org.kde.dolphin.desktop
    ```

    After that, applications that ask the desktop to **open a folder** should launch Dolphin instead of Zorin's Files/Nautilus.

    ### 2. For LibreOffice specifically, use KDE integration

    Zorin OS 18.1 is based on **Ubuntu 24.04 LTS**, so its repositories contain LibreOffice's KDE Frameworks 5 integration package. (Zorin)

    Install it:

    ```bash
    sudo apt update
    sudo apt install libreoffice-kf5 libreoffice-style-breeze
    ```

    Then completely close LibreOffice and test it from Terminal with:

    ```bash
    SAL_USE_VCLPLUGIN=kf5 libreoffice
    ```

    Now open Writer and press:

    **Ctrl+O**

    or

    **File → Open**

    You should get a **KDE-style file chooser**, which is considerably closer to Dolphin: Places sidebar, KDE navigation, better folder handling, etc.

    LibreOffice officially supports switching between its own built-in file picker and the operating system's native picker. (LibreOffice Help)

    Check:

    **Tools → Options → LibreOffice → General**

    Look for the file-dialog setting. If **Use LibreOffice dialogs** is enabled, disable it so LibreOffice uses the system/KDE picker.

    ### 3. If you like the result, make KDE integration permanent

    Instead of typing the environment variable every time, add this to your `~/.profile`:

    ```bash
    echo 'export SAL_USE_VCLPLUGIN=kf5' >> ~/.profile
    ```

    Then **log out and log back in**.

    LibreOffice should subsequently use its KF5 integration automatically.

    This variable is specific to LibreOffice, so it won't turn your entire Zorin desktop into KDE.

    ### 4. Going further: KDE file chooser in other applications

    You can also install KDE's XDG portal:

    ```bash
    sudo apt install xdg-desktop-portal-kde
    ```

    The portal system supports choosing a KDE backend specifically for the `FileChooser` interface while leaving GNOME responsible for things such as screen sharing and desktop integration. (Flatpak)

    This is potentially the **best setup for what you're describing**:

    **Zorin/GNOME desktop**
    → keep Zorin Appearance, GNOME Shell, etc.

    **Dolphin**
    → default file manager

    **KDE File Chooser**
    → Open/Save dialogs in portal-compatible applications

    **LibreOffice KF5**
    → KDE-style Open/Save dialog in LibreOffice

    I would **not** replace all of Zorin's portals with KDE, because that can interfere with GNOME-specific features such as screen sharing. Instead, we can configure *only the FileChooser* to use KDE.

    If you'd like, I can give you the **exact Zorin 18.1 configuration to make KDE/Dolphin-style file dialogs the system-wide default while leaving the rest of Zorin/GNOME untouched**.

    [1]: https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html?utm_source=chatgpt.com "portals.conf - XDG Desktop Portal"

    [2]: https://zorin.com/os/details/?utm_source=chatgpt.com "Technical details - Zorin OS"

    [3]: https://help.libreoffice.org/latest/en-US/text/shared/01/01020000.html?utm_source=chatgpt.com "Open, Insert text"

    [4]: https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.impl.portal.FileChooser.html?utm_source=chatgpt.com "File Chooser - XDG Desktop Portal"

- Installing Winboat dependencies

    WinBoat runs its Windows environment via **Docker**, so the main requirement on **Zorin OS 18.1 (Ubuntu-based)** is a working Docker Engine + Compose v2 install.


    ⚠️

    If you previously installed Docker from Ubuntu’s default repos, it can work, but WinBoat tends to be more reliable with Docker’s official packages below.

    ## 0. Confirm your Zorin base (optional but useful)

    ```bash
    cat /etc/os-release
    lsb_release -a
    ```

    You’ll likely see `UBUNTU_CODENAME` (e.g., `noble`) — the commands below automatically use that value.

    ## 1. Install Docker Engine + Docker Compose v2 (Docker’s official repo)

    ```bash
    # Update your package index
    sudo apt update
    # Install prerequisites
    sudo apt install -y ca-certificates curl gnupg
    # Add Docker’s official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add the repository to Apt sources (auto-detects UBUNTU_CODENAME)
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Install Docker + Compose v2
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

    ## 2. Add your user to the docker group (so you don’t need sudo)

    ```bash
    sudo usermod -aG docker $USER
    ```

    **Important:** log out and log back in (or reboot) for this to apply.

    ## 3. Enable + start Docker

    ```bash
    sudo systemctl enable docker
    sudo systemctl start docker
    ```

    ## 4. Verify Docker is working (without sudo)

    ```bash
    docker --version
    docker compose version
    docker run --rm hello-world
    ```

    If the `hello-world` test fails, run this and re-test:

    ```bash
    sudo systemctl restart docker
    ```

    ## 5. Install WinBoat

    Follow the installer steps on the WinBoat site, then:

    - Launch WinBoat

    - Let it download/build the required container image(s)

    - If it prompts for permissions, accept so it can manage its Docker containers

    - If WinBoat can’t “see” Docker: confirm you logged out/in after adding the docker group.

    - If Docker won’t start: run `systemctl status docker` to see the error and fix dependencies.

    - If you use a VPN/proxy: Docker image downloads may fail — try temporarily disabling it.


    💡

    Troubleshooting (Zorin 18.1):

