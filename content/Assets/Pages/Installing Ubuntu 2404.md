---
type: Page
collections: Public Pages
title: Installing Ubuntu 24.04
aliases:
description:
icon:
createdAt: 2025-01-09T12:18:23.905Z
lastUpdated: 2026-06-28T12:56:40.977Z
tags:
  - Linux
  - Ubuntu
coverImage:
---

# Installing Ubuntu 24.04

# If Snap store updates don't update

💡 Close App store, run the command below, and close the App store a second time.

```text
snap-store --quit && sudo snap refresh snap-store
```

[Refreshing snap-store](https://askubuntu.com/questions/1411104/unable-to-update-snap-store-cannot-refresh-snap-store-snap-snap-store-ha)



# Click to minimize

```text
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
```

# Installing software

### Remove and reinstall Firefox (snap)

### Uninstall Firefox

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

### Reinstall Firefox as a Snap Package

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

### Install pCloud (AppImage)

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

These steps should help you get pCloud up and running on your Ubuntu 24.10 system[[1]](https://www.hackingthehike.com/ubuntu-24-10-after-install-guide/)[[2]](https://gpdstore.net/kb/faq/kb-article/how-to-install-ubuntu-linux-24-10-on-the-gpd-pocket-3/).

If you encounter any issues or need further assistance, feel free to ask!

References

[1] [Ubuntu 24.10 After Install Guide – Hacking The Hike](https://www.hackingthehike.com/ubuntu-24-10-after-install-guide/)

[2] [How to install Ubuntu Linux 24.10 on the GPD Pocket 3](https://gpdstore.net/kb/faq/kb-article/how-to-install-ubuntu-linux-24-10-on-the-gpd-pocket-3/)

```text
sudo apt install variety gdebi ubuntu-restricted-extras gnome-shell-extensions gnome-shell-extension-manager timeshift pspp bleachbit okular blueman tweaks
```

```text
sudo snap install teams-for-linux outlook-for-linux --edge kdenlive whatsapp-for-linux okular zotero-snap bluetooth-autostart
```

```text
flatpak install flathub com.github.alainm23.planner com.google.Chrome com.github.tchx84.Flatseal com.calibre_ebook.calibre com.linuxmint.webapp-manager
```

### Install flatpak

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



## Install Microsoft Fonts

[How to install Microsoft fonts in Linux office suites](https://www.pcworld.com/article/431001/how-to-install-microsoft-fonts-in-linux-office-suites.html)[[How to install Microsoft fonts in Linux office suites|How to install Microsoft fonts in Linux office suites - Notes]]

```text
sudo apt-get install ttf-mscorefonts-installer
sudo apt-get install cabextract
mkdir .fonts
wget -qO- http://plasmasturm.org/code/vistafonts-installer/vistafonts-installer | bash
```



## Installing AppImages

```text
sudo add-apt-repository universe && sudo apt install libfuse2 
```

## Gnome extensions

[Gnome extensions](../Images/Media/Gnome%20extensions.jpg)
[[Gnome extensions|Gnome extensions - Notes]]


## LibreOffice setup

- Install [WPS Office](https://www.wps.com/).

- Install [Microsoft fonts](https://itsfoss.com/install-microsoft-fonts-ubuntu/).

```text
sudo add-apt-repository multiverse && sudo apt update && sudo apt install ttf-mscorefonts-installer && sudo fc-cache -f -v
```

- If using LibreOffice, install [LibreOffice extensions](https://extensions.libreoffice.org/) - recommended per [The Linux Experiment: Make LIBREOFFICE more compatible](https://youtu.be/G0che2Az9hw?si=hbxuY4R3-x7kuFO0)...

    - AltSearch

    - LibreWeb

    - PepitoCleaner

    - Pycalender

    - Starxpert-multisave

    - Transciber



# Uninstall & install (Snap) Firefox

[How to install, uninstall and update Firefox on Ubuntu](https://linuxconfig.org/how-to-install-uninstall-and-update-firefox-on-ubuntu-20-04-focal-fossa-linux)

`sudo apt remove firefox`

`sudo snap remove firefox`

```text
$ sudo rm -fr /opt/firefox
$ sudo mv /usr/lib/firefox/firefox_backup /usr/lib/firefox/firefox
```

## Install (Debian) Firefox

[Introducing Mozilla’s Firefox Nightly .deb Package for Debian-based Linux Distributions – Firefox Nightly News](https://blog.nightly.mozilla.org/2023/10/30/introducing-mozillas-firefox-nightly-deb-packages-for-debian-based-linux-distributions/)

Create a directory…

> sudo install -d -m 0755 /etc/apt/keyrings

Import repository…

> wget -q [https://packages.mozilla.org/apt/repo-signing-key.gpg](https://packages.mozilla.org/apt/repo-signing-key.gpg) -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3

> gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\\n"$0"\n"}’

Add repository…

> echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] [https://packages.mozilla.org/apt](https://packages.mozilla.org/apt) mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

Update…

> sudo apt-get update && sudo apt-get install firefox-nightly



# AMD installs

### [Install drivers for Radeon™ Software for Linux® version 23.40.2 for Ubuntu 22.04.3 HWE with ROCm 6.0.2](https://www.amd.com/en/support/linux-drivers)

```text
sudo apt update
wget <https://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb>
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb
sudo amdgpu-install -y --usecase=graphics,rocm
sudo usermod -a -G render,video $LOGNAME
```

### [Install Vulcan Pro](https://amdgpu-install.readthedocs.io/en/latest/install-script.html#using-the-amdgpu-install-script)

```text
amdgpu-install --vulkan=amdvlk,pro
```



### Install AMDGPU stack

```text
amdgpu-install
```

### Install Vulkan (AMD)

```text
amdgpu-install -y --accept-eula
```

# Nvidia drivers

[Install Nvidia Driver on Linux Ubuntu 24.04 | Compatible (Debian/Arch/Mint/Fedora/ETC...) 2024!!!](https://youtu.be/w30UjIX8XhU?si=w0TI6VMKJ9eFBOkC)

[NVIDIA drivers installation | Ubuntu](https://ubuntu.com/server/docs/nvidia-drivers-installation)

```jsx
sudo dpkg --add-architecture i386
sudo apt install build-essential
sudo apt install pkg-config libglvnd-dev
restart
```



## File Manager

[13 Quick Tips to Make Linux File Manager Nautilus Even Better](https://www.youtube.com/watch?v=Ia2CaItxTEk)[[13 Quick Tips to Make Linux File Manager Nautilus Even Better|13 Quick Tips to Make Linux File Manager Nautilus Even Better - Notes]]


# How to reset user folders in Ubuntu 22.04

[How to Reset User Folders (Documents, Downloads, etc) in Ubuntu 22.04 - FOSTips](https://fostips.com/reset-user-folders-ubuntu-linux/)

Run…

> xdg-user-dirs-update —force



## Bluetooth settings to automatically detect external Bluetooth speaker

Bose speaker ID: AC:BF:71:AD:C5:92

To ensure your **Bose Flex SE SoundLink** stays **automatically connected** to your **Ubuntu 24.10** system via **Bluetooth**, follow these steps:

---

### **1. Enable Automatic Bluetooth Connection at Startup**

Ubuntu may sometimes disconnect Bluetooth devices upon reboot or sleep. To maintain a persistent connection, try these methods.

#### **Method 1: Using** `bluetoothctl` **for Auto-Connect**

1. **Open a terminal** (`Ctrl + Alt + T`) and enter:

    ```bash
    bluetoothctl
    ```

2. **Ensure Bluetooth is on**:

    ```bash
    power on
    ```

3. **Find your speaker's MAC address**:

    ```bash
    devices
    ```

    Look for an entry similar to:

    ```text
    Device AC:BF:71:AD:C5:92 Bose Flex SE SoundLink
    ```

    Take note of the MAC address (`XX:XX:XX:XX:XX:XX`).

4. **Trust the device** (so Ubuntu will automatically connect to it):

    ```bash
    trust XX:XX:XX:XX:XX:XX
    ```

5. **Enable auto-connect**:

    ```bash
    pair XX:XX:XX:XX:XX:XX
    connect XX:XX:XX:XX:XX:XX
    ```

6. **Exit** `bluetoothctl` by typing:

    ```bash
    exit
    ```

---

#### **Method 2: Add a Startup Script for Auto-Reconnection**

Ubuntu might not reconnect after reboot or suspend. To fix this, add a script that runs at startup.

1. **Create a script**:

    ```bash
    nano ~/auto-connect-bluetooth.sh
    ```

2. **Paste the following script** (replace `XX:XX:XX:XX:XX:XX` with your speaker's MAC address):

    ```bash
    #!/bin/bash
    sleep 10 # Wait for system to fully boot
    bluetoothctl connect XX:XX:XX:XX:XX:XX
    ```

3. **Save the file** (`Ctrl + X`, then `Y`, then `Enter`).

4. **Make the script executable**:

    ```bash
    chmod +x ~/auto-connect-bluetooth.sh
    ```

5. **Add it to Startup Applications**:

    - Open **"Startup Applications"** (`gnome-session-properties`).

    - Click **Add**.

    - Name: **Auto-Connect Bose Speaker**.

    - Command: `/home/your-username/auto-connect-bluetooth.sh`

    - Click **Save**.

---

#### **Method 3: Fix Ubuntu Bluetooth Power Management**

If your speaker disconnects frequently, it may be due to power-saving features.

1. **Disable Bluetooth power management**:

    ```bash
    sudo nano /etc/bluetooth/main.conf
    ```

2. **Find the line**:

    ```text
    AutoEnable=false
    ```

    **Change it to**:

    ```text
    AutoEnable=true
    ```

3. **Save and exit** (`Ctrl + X`, then `Y`, then `Enter`).

4. **Restart Bluetooth service**:

    ```bash
    sudo systemctl restart bluetooth
    ```

---

### **Final Steps: Test the Auto-Connect**

- **Restart Ubuntu** and check if the Bose speaker **automatically connects**.

- If not, open the terminal and manually run:

    ```bash
    ~/auto-connect-bluetooth.sh
    ```

Let me know if you need further troubleshooting! 🚀

## Completing removing LibreOffice from terminal

To completely remove LibreOffice from Ubuntu 24.04 using the terminal, follow these steps:

1. **Open Terminal**: Press `Ctrl + Alt + T` to open the terminal.

2. **Remove LibreOffice**: Run the following command to remove all LibreOffice packages:

```bash
sudo apt remove --purge libreoffice*
```

1. **Remove Residual Configuration Files**: Clean up any residual configuration files:

```bash
sudo apt autoremove
   sudo apt clean
```

1. **Verify Removal**: Optionally, you can check if any LibreOffice packages are still installed:

```bash
dpkg -l | grep libreoffice
```



# Kubuntu

- Removing boot options

    To remove the old boot options from previous Linux installations and ensure your PC boots directly into Kubuntu, you can follow these steps:

    1. **Update GRUB Configuration**:

        - Open a terminal and run the following command to update the GRUB configuration:

        ```bash
        sudo update-grub
        ```

        This command will regenerate the GRUB configuration file and should remove entries for any non-existent operating systems.

    2. **Remove Old Kernel Versions**:

        - You can use the `apt` package manager to remove old kernel versions. Run the following command:

        ```bash
        sudo apt --purge autoremove
        ```

        This will remove old kernel versions and their associated files, which can help clean up the boot menu[[1]](https://www.linux.org/threads/solved-how-to-remove-old-kernels-in-kubuntu-20-04-kde.36151/).

    3. **Edit GRUB Configuration Manually**:

        - If the above steps don't fully resolve the issue, you can manually edit the GRUB configuration file. Open the GRUB configuration file in a text editor:

        ```bash
        sudo nano /etc/default/grub
        ```

        - Look for the line that starts with `GRUB_DEFAULT` and set it to `0` to make the first entry the default boot option:

        ```bash
        GRUB_DEFAULT=0
        ```

        - Save the file and exit the text editor. Then, update GRUB again:

        ```bash
        sudo update-grub
        ```

    4. **Remove Unwanted Boot Entries**:

        - If there are still unwanted boot entries, you can remove them by editing the GRUB configuration files in `/etc/grub.d/`. For example, you can disable the `os-prober` script that detects other operating systems: `bash sudo chmod -x /etc/grub.d/30_os-prober`

        - Update GRUB once more: `bash sudo update-grub`

    These steps should help you clean up your boot menu and ensure your PC boots directly into Kubuntu. 

    [[1]](https://www.linux.org/threads/solved-how-to-remove-old-kernels-in-kubuntu-20-04-kde.36151/): [Linux.org](https://www.linux.org/threads/solved-how-to-remove-old-kernels-in-kubuntu-20-04-kde.36151/)

    References

    [1] [SOLVED>How To Remove Old Kernels in Kubuntu 20.04 KDE - Linux.org](https://www.linux.org/threads/solved-how-to-remove-old-kernels-in-kubuntu-20-04-kde.36151/)

- Removing necessary prompt messages when copying-and-pasting files in file manager

    To remove the prompting for copying and pasting files in KDE's file manager, you can adjust the settings in the clipboard manager, Klipper. Here are the steps:

    1. **Open Klipper Settings**:

        - Click on the clipboard icon in the system tray.

        - Right-click and select "Configure Clipboard."

    2. **Adjust Settings**:

        - Uncheck the option "Prevent empty clipboard."

        - You might also want to uncheck "Enable mime-based actions" if you see it.

    3. **Reboot**:

        - Restart your system to apply the changes.

    These steps should help you disable the prompts and streamline your copy-paste actions[[1]](https://www.reddit.com/r/kde/comments/s4lvuc/disable_paste_on_middle_click/)[[2]](https://www.reddit.com/r/kde/comments/qa58oa/how_do_i_disable_this_selection_popup_for_copy/).

    If you have any other questions or need further assistance, feel free to ask!

    References

    [1] [Disable paste on middle click : r/kde - Reddit](https://www.reddit.com/r/kde/comments/s4lvuc/disable_paste_on_middle_click/)

    [2] [How do I disable this selection popup for Copy? : r/kde - Reddit](https://www.reddit.com/r/kde/comments/qa58oa/how_do_i_disable_this_selection_popup_for_copy/)
