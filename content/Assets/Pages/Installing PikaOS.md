---
type: Page
collections: Public Pages
title: Installing PikaOS
aliases:
description:
icon:
createdAt: 2026-06-25T14:34:37.351Z
lastUpdated: 2026-06-28T12:56:02.626Z
tags:
  - Linux
coverImage:
---

# Installing PikaOS

- Installing Snapper

    To install and configure Snapper on PikaOS, follow these steps as outlined in the official PikaOS documentation:

    ### 1. Installation

    Open your terminal and run the following commands to install the necessary packages:

    ```bash
    pikman update
    pikman install snapper snapper-gui
    ```

    ### 2. Initial Configuration

    Set up the Snapper configuration for your root partition:

    ```bash
    sudo snapper create-config /
    ```

    ### 3. Setup Refind Integration (for bootable snapshots)

    To make your snapshots bootable via rEFInd, prepare the directory and install the specific PikaOS hooks:

    1. **Prepare the directory**:

        ```bash
        sudo mkdir -p /var/lib/refind-btrfs
        sudo chmod 755 /var/lib/refind-btrfs
        ```

    2. **Install integration packages**:

        ```bash
        pikman install pika-refind-btrfs-hooks refind-btrfs
        ```

    3. **Enable the service**:

        ```bash
        sudo systemctl enable refind-btrfs --now
        ```

    ### Important Prerequisites

    - **Partition Label**: Your boot partition **must** be labeled as `PikaOS`. You can verify or rename this label using a disk management tool like GParted.

    - **Rebooting**: After completing these steps, reboot your system. You should see two sets of entries for each installed kernel—one for the base kernel and one for your snapshots. You can press `Tab` on the snapshots to switch between them.

    - **Maintenance**: To avoid a cluttered boot menu, consider managing (reducing) the number of old kernels installed on your system.

    For further details and troubleshooting, you can refer to the official [PikaOS Snapper setup guide](https://wiki.pika-os.com/en/guides-wiki/snapper-btrfs).

- Installing HP LaserJet P1102w Printer

    To install the HP LaserJet P1102w printer on PikaOS, you should use the **HPLIP (HP Linux Imaging and Printing)** software suite, which is the standard, official solution for using HP printers on Linux.

    ### Recommended Steps

    1. **Install HPLIP**Open your terminal and install the HPLIP package using `pikman` (the package manager used in PikaOS):

        ```bash
        pikman install hplip
        ```

        Ensure that the **CUPS** (Common UNIX Printing System) service is active and running:

        ```bash
        sudo systemctl enable --now cups
        ```

    2. **Configure the Printer**Once the package is installed, run the HPLIP setup tool to detect your printer and configure it:

        ```bash
        hp-setup
        ```

        Follow the graphical prompts. This tool will:

        - Detect if your printer is connected via USB or Wi-Fi.

        - Set up the device properly.

        - Automatically download any necessary proprietary plugins required by specific HP models.

    ### Important Considerations

    - **Ignore Windows Drivers:** Do **not** attempt to use any `.exe` files you find online. Those are for Windows and will not function on Linux.

    - **Wireless Setup:** If you intend to use the "w" (wireless) feature of your P1102w, `hp-setup` can help configure the connection if the printer is already on your local network. You may need to temporarily connect it via USB for the initial setup to pass the network credentials to the printer.

    - **Alternative Driver:** If HPLIP encounters issues with this specific older model, you can check your system's printer settings (accessible via the GNOME/KDE printer control panel) to see if the `foo2zjs` driver is available as an alternative, as it is a common open-source driver for many LaserJet models.

    By using `hplip` and `hp-setup`, your printer should be fully operational within the PikaOS printing system.

- Installing Dock like [https://youtu.be/LkXXzptHhp0?si=gHNN0nGBgxQSxC5u](https://youtu.be/LkXXzptHhp0?si=gHNN0nGBgxQSxC5u) 

    The dock you're seeing in the screenshot is a custom status bar called **Pikabar**.

    Pikabar is built using a UI framework called Quickshell and comes pre-configured as the default bottom panel out-of-the-box for the **Niri** and **Hyprland** editions of PikaOS.

    If you installed the standard GNOME or KDE editions of PikaOS, you won't have Pikabar. Here is how you can get it running on your system:

    ### 1. Install the Niri Window Manager

    To get Pikabar perfectly integrated, you'll need to install one of the window managers that natively utilizes it. PikaOS officially recommends Niri as their primary tiling option. Open your terminal and use the Pikman package manager to install it:

    **For standard (AMD/Intel) setups:**

    ```bash
    pikman update && pikman install pika-niri-desktop-minimal pika-niri-settings
    ```

    **For NVIDIA setups:**

    ```bash
    pikman update && pikman install pika-niri-desktop-minimal pika-niri-settings-nvidia
    ```

    Once the installation completes, log out of your current session. On the login screen, click the small gear icon in the bottom right corner and select **Niri** before logging back in.

    ### 2. Basic Customizations

    If you just want to make minor tweaks to Pikabar (such as changing the weather widget from Celsius to Fahrenheit or adjusting specific modules), you can quickly edit its main configuration file:

    - Open and modify `~/.config/pikabar/config.json`.

    ### 3. Advanced Theming (Preventing Update Overwrites)

    Pikabar is maintained by the PikaOS team and is designed to receive automatic layout updates. If you want to heavily customize the styling, colors, or modules without your changes getting wiped out during your next system update, you need to detach it from the system defaults:

    - **Copy the default files locally:** Copy everything from `/usr/share/pikabar` into `~/.config/quickshell`.

    - **Redirect your startup config:**

    - **If using Niri:** Open `~/.config/niri/config.kdl` and change the startup command from `pikabar` to `quickshell`.

    - **If using Hyprland:** Open `~/.config/hypr/exec.conf` and do the exact same replacement.

    *(Bonus tip: The application open in the background of your screenshot is the native* ***Pikman Update Manager****, which handles both APT packages and Flatpaks for PikaOS!)*
