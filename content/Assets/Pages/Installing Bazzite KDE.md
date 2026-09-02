---
type: 'Page'
title: Installing Bazzite KDE
aliases: null
description: null
icon: 🏛️
createdAt: '2026-08-29T23:56:31.098Z'
lastUpdated: '2026-08-30T00:21:16.471Z'
tags: []
coverImage: '[Untitled](../Images/Untitled%20(6).md)'
---

# Installing Bazzite KDE

- Installing Box Bluetooth speaker

    If a Bose Bluetooth speaker connects to Bazzite but **doesn't appear as an audio-output device**, check its Bluetooth audio profiles:

    ```bash
    pactl list cards | grep -A 40 -i bose
    ```

    If you see only:

    ```text
    audio-gateway
    ```

    and **no** `a2dp-sink`, WirePlumber is negotiating the wrong Bluetooth role.

    ### Fix

    Create a WirePlumber configuration:

    ```bash
    sudo mkdir -p /etc/wireplumber/wireplumber.conf.d
    sudo nano /etc/wireplumber/wireplumber.conf.d/50-bt-classic-codecs.conf
    ```

    Add:

    ```text
    monitor.bluez.properties = {
        bluez5.codecs = [ sbc sbc_xq aac aptx aptx_hd ]
        bluez5.roles = [ a2dp_source hsp_hs hfp_hf ]
    }
    ```

    Save, then restart WirePlumber:

    ```bash
    systemctl --user restart wireplumber
    ```

    Disconnect and reconnect the Bose speaker.

    Verify:

    ```bash
    pactl list cards | grep -A 50 -i bose
    ```

    A successful configuration should now show:

    ```text
    a2dp-sink: High Fidelity Playback (A2DP Sink, codec SBC)
    a2dp-sink-sbc_xq: High Fidelity Playback (A2DP Sink, codec SBC-XQ)
    Active Profile: a2dp-sink
    ```

    ### Recommended audio profile

    In **System Settings → Sound → Bose Flex SE SoundLink**, choose:

    **High Fidelity Playback (A2DP Sink, codec SBC-XQ)**

    for higher-quality audio. If you experience Bluetooth dropouts, use regular **SBC** instead.

    This workaround **does not use** `rpm-ostree` **or modify Bazzite's immutable** `/usr` **image**, and the configuration should persist across reboots and normal Bazzite updates.

- Adding icon to web app

    If a web app works but shows a **generic icon in the KDE taskbar**, try this first:

    1. Open the **Application Launcher**.

    2. Search for the web app you created.

    3. **Right-click → Edit Application**.

    4. Click the application's current **icon**.

    5. Select the correct icon or browse to a downloaded `.png`/`.svg` icon.

    6. Click **Save**.

    7. **Unpin the old icon** from the taskbar.

    8. Launch the web app again from the Application Launcher.

    9. Right-click the running application's icon → **Pin to Task Manager**.

    ### If the correct icon disappears when the app launches

    KDE may not be matching the launcher to the running web-app window correctly. The launcher file is usually under:

    ```bash
    ~/.local/share/applications/
    ```

    The relevant setting inside its `.desktop` file is:

    ```text
    StartupWMClass=
    ```

    If necessary, this can be corrected to match the web app's actual window class.

    **Recommendation:** Try the graphical **Edit Application → change icon → unpin → relaunch → repin** procedure first. Only modify `StartupWMClass` if the icon is correct in the Application Launcher but wrong once the web app is running.

- Installing pCloud

    Yes. For **pCloud on Bazzite**, the best way to keep the OS as immutable as possible is to use **pCloud’s official AppImage**, preferably managed through **Gear Lever**.

    That avoids `rpm-ostree`, avoids layering anything into the Bazzite image, and still gives you normal desktop integration. Bazzite explicitly recommends AppImages for GUI applications that are not available through Bazaar, and specifically recommends Gear Lever for managing them. (Bazzite Docs)

    ## Recommended setup

    Your installation will look roughly like this:

    ```text
    Bazzite immutable system
            │
            └── Your home folder
                  │
                  ├── pCloud AppImage
                  ├── pCloud configuration
                  └── pCloud virtual drive
    ```

    No `rpm-ostree` package is added to the operating-system deployment.

    ---

    # 1. Install Gear Lever from Bazaar

    Open **Bazaar** and search for:

    **Gear Lever**

    Install it normally.

    Bazzite recommends Gear Lever because it integrates AppImages with the desktop, creates launcher entries, manages icons, and can detect available AppImage updates. Updates themselves may still need to be applied manually. (Bazzite Docs)

    So:

    **Bazaar → Gear Lever → Get**

    This is a Flatpak, so installing Gear Lever itself also leaves Bazzite's base image untouched.

    ---

    # 2. Download pCloud from the official website

    Download pCloud Drive for Linux directly from pCloud:

    [Download pCloud Drive for Linux](https://www.pcloud.com/download-free-online-cloud-file-storage.html?utm_source=chatgpt.com)

    pCloud officially distributes its Linux desktop application as an **AppImage**. Their installation instructions specifically tell Linux users to download the AppImage, make it executable, and run it. (pCloud)

    The file will probably look similar to:

    ```text
    pcloud.AppImage
    ```

    or include a version number.

    As of July 23, 2026, pCloud's current Linux release is **2.2.1**. (pCloud)

    ---

    # 3. Open the AppImage with Gear Lever

    Instead of simply double-clicking the downloaded file, I recommend importing it into Gear Lever.

    Open your **Downloads** folder in Dolphin.

    Right-click:

    ```text
    pcloud.AppImage
    ```

    Choose:

    **Open With → Gear Lever**

    If that option doesn't appear, open Gear Lever first and import the AppImage from there.

    Gear Lever should offer something similar to:

    **Move to the app menu / Integrate**

    Choose the integration option.

    Gear Lever will move/manage the AppImage in an appropriate location under your user account and create a proper KDE application launcher.

    You should then be able to find:

    **pCloud**

    from the KDE Application Launcher just like LibreOffice, Firefox, etc.

    ---

    # 4. Start pCloud

    Launch:

    **Application Launcher → pCloud**

    Then sign into your pCloud account.

    pCloud will create its virtual drive.

    Its purpose is to let you access cloud files as though they are local files without having to download your entire pCloud storage onto your SSD. (pCloud)

    You'll normally see pCloud appear in your file system and a pCloud icon in the KDE system tray.

    ---

    # 5. Enable pCloud at login

    Inside pCloud, open:

    **Settings**

    Look for the option similar to:

    **Start pCloud on system startup**

    and enable it.

    pCloud has supported automatic startup on Linux for years, and it is intended to run automatically after login so the virtual drive is mounted without you manually starting it each time. (pCloud)

    This is preferable to creating your own systemd service unless pCloud's own startup mechanism doesn't work.

    ---

    # 6. Enable Dolphin integration

    This is particularly useful on your Bazzite KDE setup.

    Recent pCloud versions support context-menu integration with:

    - Dolphin

    - Nautilus

    - Nemo

    - Caja

    - Thunar

    pCloud added this functionality to its current Linux release. (pCloud)

    In pCloud go to:

    **Settings → General**

    Enable:

    **Show context menu**

    pCloud's official documentation confirms that this enables actions such as uploading files directly to pCloud and generating share links from the file manager. (pCloud Help Center)

    After enabling it, you may need to restart Dolphin:

    ```bash
    kquitapp6 dolphin
    ```

    Then reopen Dolphin.

    You may then see pCloud options when right-clicking files.

    ---

    # 7. Check that the pCloud drive is mounted

    After logging into pCloud, open Dolphin.

    You should be able to access the pCloud virtual drive.

    You can also check from the terminal:

    ```bash
    mount | grep -i pcloud
    ```

    or:

    ```bash
    findmnt | grep -i pcloud
    ```

    Don't worry if the exact mount location differs from another Linux distribution. pCloud manages the mount itself.

    ---

    # 8. What about FUSE?

    pCloud Drive uses filesystem mounting technology to provide its virtual drive, and AppImages can also rely on FUSE.

    Normally **you should not install anything first**.

    Bazzite already supports AppImages as an officially recommended software format, so try pCloud before adding any system packages. (Bazzite Docs)

    If pCloud launches and the virtual drive appears:

    **do nothing else.**

    If you receive an actual FUSE error such as:

    ```text
    AppImages require FUSE to run
    ```

    then troubleshoot that specific error. AppImage documentation notes that newer AppImages increasingly include FUSE 3 support and many distributions provide what is required out of the box. (GitHub)

    I would **not preemptively layer** `fuse` **packages with** `rpm-ostree`.

    ---

    # 9. Updating pCloud

    There are two possible mechanisms.

    pCloud itself has historically included an internal updater, while Gear Lever can also check whether newer AppImage versions are available. (pCloud)

    Because pCloud has recently changed its AppImage handling, I would periodically check:

    **Gear Lever → pCloud**

    and compare with pCloud's current Linux release.

    You can also check:

    [pCloud Linux release notes](https://www.pcloud.com/release-notes/linux?utm_source=chatgpt.com)

    The current 2.2.1 release specifically includes improvements related to the AppImage launcher and Linux file-manager integration. (pCloud)

    ---

    # 10. What I would avoid

    For pCloud, I would **not** recommend:

    ```bash
    rpm-ostree install pcloud.rpm
    ```

    even if you find an RPM somewhere.

    Bazzite warns that package layering can introduce dependency conflicts, block upgrades, prevent rebasing, and make image updates slower. It recommends Flatpak, Homebrew, containers, or AppImage before layering packages. (Bazzite Docs)

    I also wouldn't put pCloud inside Distrobox unless the AppImage fails.

    pCloud needs fairly close integration with:

    - your home directories

    - the file manager

    - FUSE/filesystem mounting

    - the KDE system tray

    - automatic startup

    Running it inside a container introduces unnecessary complexity.

    ---

    ## The setup I recommend for your machine

    ```text
    BAZZITE
    │
    ├── Bazaar
    │     └── Gear Lever
    │
    └── Gear Lever
           └── Official pCloud.AppImage
                  │
                  ├── pCloud virtual drive
                  ├── KDE launcher
                  ├── system-tray icon
                  ├── start at login
                  └── Dolphin integration
    ```

    This gives you nearly the same experience as installing pCloud traditionally on Fedora **without adding pCloud to Bazzite's immutable system image**.

    ### Bottom line

    For pCloud on Bazzite:

    **Official pCloud AppImage + Gear Lever = recommended approach.**

    I'd choose that over an RPM, Distrobox, or `rpm-ostree` installation. It fits Bazzite's software-management philosophy particularly well because pCloud already officially distributes its Linux client as an AppImage. (pCloud)

    [1]: https://docs.bazzite.gg/Installing_and_Managing_Software/software-intro/?utm_source=chatgpt.com "Introduction to Installing Software on Bazzite - Bazzite Documentation"

    [2]: https://docs.bazzite.gg/Installing_and_Managing_Software/AppImage/?utm_source=chatgpt.com "AppImage - Bazzite Documentation"

    [3]: https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64&utm_source=chatgpt.com "Install pCloud Drive on Linux | Step-by-Step Guide"

    [4]: https://www.pcloud.com/release-notes/linux?utm_source=chatgpt.com "pCloud Linux Release Notes | App Updates"

    [5]: https://pcdn-www.pcloud.com/download-free-online-cloud-file-storage.html?utm_source=chatgpt.com "Download pCloud Apps | Windows, Mac, Linux, iOS & Android"

    [6]: https://help.pcloud.com/article/use-pcloud-from-your-linux-file-manager?utm_source=chatgpt.com "pCloud Help center - Use pCloud from your Linux file manager"

    [7]: https://github.com/AppImage/AppImageKit/wiki/FUSE?utm_source=chatgpt.com "FUSE · AppImage/AppImageKit Wiki · GitHub"

    [8]: https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/?utm_source=chatgpt.com "Package Layering - Bazzite Documentation"

- Installing Gear level (to install app images)

    To install **Gear Lever** from the terminal in Bazzite, use Flatpak:

    ```bash
    flatpak install flathub it.mijorus.gearlever
    ```

    When prompted, confirm the installation.

    Then launch it with:

    ```bash
    flatpak run it.mijorus.gearlever
    ```

    After installation, **Gear Lever should also appear in the KDE Application Launcher**, so you normally won't need to start it from the terminal again.

    This is a good Bazzite-friendly method because Gear Lever is installed as a **Flatpak**, so it does not modify or layer packages into Bazzite's immutable base system.

