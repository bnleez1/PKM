---
type: 'Page'
title: Installing Nobara KDE
aliases: null
description: null
icon: 🖥️
createdAt: '2026-07-09T14:39:58.489Z'
lastUpdated: '2026-08-30T16:48:21.345Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(255).md)'
---

# Installing Nobara KDE

- Installing imageview

    Depending on the Nobara edition/install image, you may not have a dedicated image viewer preinstalled, even though file thumbnails may still work in the file manager.

    Nobara’s current “Official” edition is KDE-based, according to the Nobara site, so the most natural image viewer is **Gwenview**. (nobaraproject.org)

    Install it with:

    ```bash
    sudo dnf install gwenview
    ```

    Then open an image from the file manager. If it still does not open by default, right-click an image → **Open With** → **Gwenview** → choose the option to remember/set it as default.

    Good alternatives:

    ```bash
    sudo dnf install gthumb
    ```

    or, for the GNOME-style image viewer:

    ```bash
    sudo dnf install loupe
    ```

    Loupe is GNOME’s current “Image Viewer” app and can view/edit images with basic actions like crop, rotate, and flip. (apps.gnome.org)

    For Nobara KDE, I’d install **Gwenview** first.

    [1]: https://nobaraproject.org/?utm_source=chatgpt.com "Nobara Linux | The Nobara Project"

    [2]: https://apps.gnome.org/Loupe/?utm_source=chatgpt.com "Image Viewer"

- Installing Fedora Wallpapers

    - Finding wallpapers

        The wallpapers shown in your screenshot are mostly the standard KDE collection. The Fedora packs you installed should be stored under:

        ```text
        /usr/share/wallpapers/
        ```

        For example, Fedora 40 installs its Plasma wallpaper package under:

        ```text
        /usr/share/wallpapers/F40/contents/images/
        /usr/share/wallpapers/F40/contents/images_dark/
        ```

        with multiple resolutions up to 3840×2160. (Fedora Packages)

        ## 1. Close and reopen this window

        Because the **Desktop Folder Settings** window may have been open during installation:

        1. Click **Cancel**.

        2. Right-click the desktop.

        3. Select **Configure Desktop and Wallpaper** again.

        4. Look for entries named **Fedora**, **F21**, **F22**, **F40**, and similar.

        Fedora’s KDE-specific wallpaper packages are intended to register their artwork with Plasma’s wallpaper chooser. (Fedora Project)

        ## 2. Open the installed wallpaper directory

        Run:

        ```bash
        dolphin /usr/share/wallpapers
        ```

        You should see directories such as:

        ```text
        F21
        F22
        F23
        ...
        F40
        F41
        F42
        F43
        F44
        ```

        To list them in the terminal:

        ```bash
        find /usr/share/wallpapers \
            -mindepth 1 -maxdepth 1 \
            -type d \
            -printf '%f\n' |
        sort
        ```

        ## 3. Locate all installed Fedora image files

        Run:

        ```bash
        find /usr/share/wallpapers /usr/share/backgrounds \
            -type f \
            \( -iname '*.png' -o \
               -iname '*.jpg' -o \
               -iname '*.jpeg' -o \
               -iname '*.webp' -o \
               -iname '*.jxl' \) \
            2>/dev/null |
        sort |
        less
        ```

        Press **Q** to leave the list.

        To show only large-resolution filenames:

        ```bash
        find /usr/share/wallpapers \
            -type f \
            \( -name '3840x2160.*' -o \
               -name '3440x1440.*' -o \
               -name '3200x1800.*' -o \
               -name '2560x1440.*' \) \
            2>/dev/null |
        sort
        ```

        ## 4. Add one manually in the window shown

        In your screenshot:

        1. Click **Add…**

        2. Press **Ctrl+L** in the file chooser.

        3. Enter:

        ```text
        /usr/share/wallpapers
        ```

        1. Open a Fedora folder, such as:

        ```text
        F40 → contents → images
        ```

        1. Select the image matching your screen resolution, commonly:

        ```text
        3840x2160.png
        ```

        Plasma normally handles the entire packaged wallpaper automatically, including light and dark versions, so manual addition is only needed when the chooser has not refreshed.

        ## 5. Verify which packs actually installed

        ```bash
        rpm -qa --qf '%{NAME}\n' |
        grep -E 'backgrounds-(kde|extras-kde)$' |
        sort
        ```

        That should produce a substantial list of Fedora wallpaper packages. If the directories exist but still do not appear after reopening the settings window, log out of Plasma and sign back in once.

        [1]: https://packages.fedoraproject.org/pkgs/f40-backgrounds/f40-backgrounds-kde/fedora-42.html?utm_source=chatgpt.com "f40-backgrounds-kde-40.2.0-3.fc42 in Fedora 42"

        [2]: https://fedoraproject.org/wiki/Wallpapers "Wallpapers - Fedora Project Wiki"

- Installing Winboat Dependencies

    For **Nobara 44**, use **KVM + Docker Engine + the Docker Compose plugin + FreeRDP 3**. Docker Desktop is unsupported. Podman is another supported option, but the instructions below use Docker throughout. [WinBoat requirements](https://winboat.app/)

    These steps are adapted from current upstream documentation; I haven’t tested them on your computer. Run commands from your normal desktop account, using `sudo` only where shown.

    1. **Update Nobara first.**

        Open **Update System / DNF App Center** and update everything, or run:

        ```bash
        nobara-sync cli
        ```

        Do **not** prefix this command with `sudo`. Nobara recommends its updater because it applies repository fixes and package synchronization beyond a normal `dnf update`. Reboot after the update finishes successfully. [Nobara update instructions](https://wiki.nobaraproject.org/en/general-usage/troubleshooting/update-system)

    2. **Check hardware virtualization and available resources.**

        WinBoat lists minimums of 4 GB RAM, two CPU threads, and 32 GB free space in the selected installation location. For practical Windows use, I recommend 16 GB host RAM and at least 64–100 GB available storage. [WinBoat prerequisites](https://github.com/winboat-org/winboat/blob/main/README.md)

        Run:

        ```bash
        lscpu
        free -h
        df -h "$HOME" /var
        ls -l /dev/kvm
        ```

        In `lscpu`, look for **VT-x** on Intel or **AMD-V** on AMD. `/dev/kvm` should exist.

        If virtualization is disabled, restart into your BIOS/UEFI and enable:

        - **Intel:** Intel Virtualization Technology / VT-x.

        - **AMD:** SVM Mode / AMD-V.

        If virtualization is enabled but `/dev/kvm` is missing, load the module for **your CPU only**:

        Intel:

        ```bash
        sudo modprobe kvm_intel
        ```

        AMD:

        ```bash
        sudo modprobe kvm_amd
        ```

        Then check again:

        ```bash
        ls -l /dev/kvm
        ```

        If Nobara itself runs inside another VM, the outer hypervisor must expose nested virtualization. [Dockur KVM guidance](https://github.com/dockur/windows#how-do-i-verify-that-kvm-is-available)

        You do not need a separate host installation of VirtualBox, virt-manager, or libvirt for this Docker-based setup.

    3. **Install FreeRDP and the DNF repository-management plugin.**

        ```bash
        sudo dnf install freerdp dnf5-plugins
        ```

        The package is called `freerdp`, not Ubuntu’s `freerdp3-x11`. Fedora 44’s package supplies FreeRDP 3 and the `xfreerdp` executable. `dnf5-plugins` supplies `config-manager`. [FreeRDP package](https://packages.fedoraproject.org/pkgs/freerdp/freerdp/fedora-44-updates.html), [DNF5 plugins](https://packages.fedoraproject.org/pkgs/dnf5/dnf5-plugins/index.html)

        Verify from a terminal inside your graphical desktop:

        ```bash
        xfreerdp /version
        xfreerdp /buildconfig
        ```

        The version should be **3.x**. The build configuration should include an audio backend such as `WITH_PULSE=ON` or `WITH_ALSA=ON`.

        WinBoat recognizes the executable name `xfreerdp`; you do not need to create an `xfreerdp3` symlink. [WinBoat FreeRDP detection](https://github.com/winboat-org/winboat/blob/main/src/renderer/utils/getFreeRDP.ts)

    4. **Install Docker Engine and Compose.**

        First check for an existing Docker installation or Podman’s Docker compatibility wrapper:

        ```bash
        rpm -q docker-ce docker-ce-cli moby-engine docker-cli podman-docker
        ```

        “Package … is not installed” is normal on a fresh system.

        If `podman-docker` is installed, remove that compatibility wrapper before installing the real Docker CLI:

        ```bash
        sudo dnf remove podman-docker
        ```

        Review the proposed removal list before accepting. You generally do not need to remove Podman itself. If you already use `moby-engine` or another Docker installation for existing containers, do not blindly replace it.

        Add Docker’s Fedora repository using DNF5 syntax:

        ```bash
        sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
        ```

        Install:

        ```bash
        sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```

        Docker currently publishes Fedora 44 packages. If prompted to trust its signing key, the documented fingerprint is:

        ```text
        060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
        ```

        These are Docker’s official repository and package commands. If DNF reports conflicts, do not add `--allowerasing` without reviewing what would be removed. [Docker installation documentation](https://docs.docker.com/engine/install/fedora/)

    5. **Start Docker and grant your account access.**

        ```bash
        sudo systemctl enable --now docker
        sudo groupadd -f docker
        sudo usermod -aG docker "$USER"
        ```

        **Security note:** membership in the `docker` group grants effectively root-level control over the computer. Only add trusted users. [Docker post-installation guidance](https://docs.docker.com/engine/install/linux-postinstall/)

        Save your work and reboot:

        ```bash
        systemctl reboot
        ```

        A full logout/login also refreshes group membership, but rebooting ensures WinBoat and your desktop launchers inherit it. Opening another terminal alone is insufficient.

    6. **Verify everything as your normal user.**

        After rebooting, run these **without** `sudo`:

        ```bash
        id -nG
        systemctl is-active docker
        systemctl is-enabled docker
        docker version
        docker compose version
        docker run --rm hello-world
        xfreerdp /version
        ls -l /dev/kvm
        ```

        Expected results:

        | Check                    | Expected result                    |
        | :----------------------- | :--------------------------------- |
        | `id -nG`                 | Includes `docker`                  |
        | Docker service           | `active` and `enabled`             |
        | `docker version`         | Shows both Client and Server       |
        | `docker compose version` | Prints a Compose version           |
        | `hello-world`            | Prints a successful Docker message |
        | FreeRDP                  | Version `3.x`                      |
        | KVM                      | `/dev/kvm` exists                  |

        Use `docker compose` **with a space**. The separately named `docker-compose` command is not necessary for this installation. [Compose plugin documentation](https://docs.docker.com/compose/install/linux/)

    7. **Install or reopen WinBoat.**

        Download the latest **RPM** from the [official WinBoat releases](https://github.com/winboat-org/winboat/releases/latest). The latest release I found was **0.9.2**, which includes security fixes.

        Install the downloaded RPM using DNF, replacing the quoted example with its actual path:

        ```bash
        sudo dnf install "/full/path/to/downloaded-winboat.rpm"
        ```

        Launch WinBoat from your application menu **without** `sudo`, select **Docker**, and check its prerequisites.

        Choose an installation folder with sufficient space. Docker also needs some space under `/var` for its images and runtime data.

    There are a few specific problems to watch for:

    - **WinBoat rejects Docker Compose even though it is installed.**

        Docker’s Fedora 44 repository now supplies **Compose 5.x**. Some WinBoat releases incorrectly reject that major version; this is a documented prerequisite-check bug. Try the current WinBoat release first. [Docker packages](https://download.docker.com/linux/fedora/44/x86_64/stable/Packages/), [WinBoat issue #573](https://github.com/winboat-org/winboat/issues/573)

        **Only if that check still fails**, a compatibility workaround is to install official Compose **2.40.3** for your user. The following commands assume an `x86_64` computer. Check whether `~/.docker/cli-plugins/docker-compose` already exists and back it up before replacing it.

        ```bash
        sudo dnf install curl
        mkdir -p "$HOME/.docker/cli-plugins"
        curl -fL \
          https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-x86_64 \
          -o "$HOME/.docker/cli-plugins/docker-compose"
        chmod +x "$HOME/.docker/cli-plugins/docker-compose"
        docker compose version
        ```

        It should now report `v2.40.3`. Close and reopen WinBoat.

        This overrides Compose for **all Docker commands run by your user**, and it does **not** update automatically. Treat it as a temporary workaround. Once your WinBoat version accepts the repository version, move this manually installed override aside:

        ```bash
        mv "$HOME/.docker/cli-plugins/docker-compose" \
           "$HOME/.docker/cli-plugins/docker-compose.winboat-v2-disabled"
        docker compose version
        ```

        [Official Compose 2.40.3 release](https://github.com/docker/compose/releases/tag/v2.40.3), [manual plugin installation guidance](https://docs.docker.com/compose/install/linux/)

    - **Docker reports “permission denied” for its socket.**

        Check that `id -nG` includes `docker`, then fully log out or reboot. Do not fix this with `chmod 666` on the Docker socket or by running WinBoat as root.

    - **Docker fails to start.**

        Inspect the actual error:

        ```bash
        sudo journalctl -u docker -b -n 100 --no-pager
        ```

        If it specifically says `failed to find iptables`, Docker documents this Fedora fix:

        ```bash
        sudo alternatives --set iptables /usr/bin/iptables-nft
        sudo systemctl restart docker
        ```

        [Docker’s Fedora troubleshooting note](https://docs.docker.com/engine/install/fedora/)

    - **FreeRDP reports that it cannot open the display.**

        Run it from your Nobara desktop terminal. On a Wayland session, ensure XWayland is installed:

        ```bash
        sudo dnf install xorg-x11-server-Xwayland
        ```

        Then log out and back in.

    - **An older guide tells you to force-load networking modules.**

        Current WinBoat does not require manually loading `ip_tables` and `iptable_nat` as installation prerequisites. Skip those instructions unless you are diagnosing a specific networking problem. Do not disable your firewall or SELinux as a routine installation step. [WinBoat prerequisite changes](https://github.com/TibixDev/winboat/releases/tag/v0.8.6)

- Setting up HP LaserJet P1102w Printer

    Use **HPLIP with HP’s proprietary plug-in**. The P1102w requires that plug-in when using the HPLIP driver; installing HPLIP alone may leave it detected but unable to print. [Red Hat documentation](https://access.redhat.com/solutions/1250653)

    These instructions cover USB and Wi-Fi on Nobara 44. They follow the documented HP/Fedora workflow, but I haven’t tested them on your hardware.

    1. **Update Nobara.**

        Open **DNF App Center / Nobara System Updater**, install updates, and restart if requested. Nobara recommends its updater for system updates. [Nobara guidance](https://wiki.nobaraproject.org/new-user-guide-general-guidelines)

    2. **Install the printing software.**

        Open Konsole or Terminal and run:

        ```bash
        sudo dnf install cups cups-client hplip hplip-gui
        sudo systemctl enable --now cups.service
        ```

        Use the repository packages rather than downloading the full HPLIP `.run` installer, which can conflict with packaged dependencies. [Fedora printing guidance](https://www.fedoraproject.org/wiki/How_to_debug_printing_problems)

    3. **Install the required HP plug-in.**

        With your computer connected to the internet, run:

        ```bash
        sudo hp-plugin -i
        ```

        Select the option to **download and install the plug-in**, review and accept HP’s license if you agree, and wait for installation to finish. The `-i` option runs the installer in the terminal.

        If installation reports a download, checksum, or signature error, stop and resolve it before continuing; don’t bypass verification.

    4. **For USB printing, connect and add the printer.**

        Turn the printer on, load paper, and connect it directly to your computer with a USB printer cable. Then run:

        ```bash
        sudo hp-setup -i -b usb
        ```

        Follow the prompts:

        - Select the **HP LaserJet Professional P1102w**.

        - Accept the matching recommended driver; choose the **P1102w / hpcups** entry if asked.

        - Accept or enter a printer queue name.

        - Print the test page when offered.

        HP documents this terminal setup method, including USB selection and test-page printing. [HP setup reference](https://developers.hp.com/hp-linux-imaging-and-printing/tech_docs/man_pages/setup)

        **If you only want USB printing, setup is complete once the test page prints.**

    5. **For Wi-Fi printing, connect the printer to your router first.**

        Skip pairing if the printer is already connected to your current network. The printer uses **2.4 GHz Wi-Fi**; your computer can use Ethernet or another Wi-Fi band on the same local network. [HP specifications](https://support.hp.com/us-en/product/product-specs/hp-laserjet-pro-p1102-printer-series/model/5149432)

        If your router supports WPS:

        - Hold the printer’s **Wireless** button for approximately three seconds, releasing when the wireless light starts blinking.

        - Immediately activate **WPS** on your router, following the router’s instructions.

        - Wait for the printer’s wireless light to become steady.

        This pairing procedure is described by [HP support](https://h30434.www3.hp.com/t5/Printer-Wireless-Networking-Internet/LASERJET-P1102W-STOPPED-WORKING-WIRELESSLY/td-p/7712055).

        Without WPS, temporarily connect the printer by USB and try:

        ```bash
        hp-wificonfig
        ```

        Follow the wireless configuration wizard to select your network and enter its password. HPLIP provides this utility for supported printers using a temporary USB connection. If it reports that your device is unsupported, use HP’s model-specific wireless setup software on a supported Windows/Mac computer, or retain USB printing. [HPLIP utility implementation](https://sources.debian.org/src/hplip/3.26.4%2Bdfsg0-3/ui4/devmgr5.py)

    6. **Add the Wi-Fi printer in Nobara.**

        Print the printer’s configuration page: while it is idle, hold **Cancel** until the Ready light blinks, then release. Find its IPv4 address on that page. [HP user guide](https://h10032.www1.hp.com/ctg/Manual/c04697535.pdf)

        Disconnect the USB cable. Run the following, **replacing the example address with your printer’s address**:

        ```bash
        sudo hp-setup -i 192.168.1.50
        ```

        Select the matching P1102w driver and print a test page. HP supports adding a network printer directly by IP address. [HP setup reference](https://developers.hp.com/hp-linux-imaging-and-printing/tech_docs/man_pages/setup)

        In Nobara’s **Printers** settings, set the working queue as default and choose the correct paper size. Reserving the printer’s IP address in your router’s DHCP settings will help keep this configuration working.

    If something fails:

    - **“Plug-in required” or printing stops after an HPLIP update:** rerun `sudo hp-plugin -i` to install the matching plug-in.

    - **USB appears as an HP installation disk:** install the USB mode-switching packages below, then turn the printer off and on and reconnect it:

        ```bash
        sudo dnf install usb_modeswitch usb_modeswitch-data
        ```

        This addresses the older HP Smart Install virtual-CD mode. [OpenPrinting instructions](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/INSTALL.in)

    - **Wi-Fi printer is missing:** check that its wireless light is steady and use its current IP address directly. Avoid guest networks that prevent devices from communicating.

    - **Jobs remain stuck:** check the queue status with `lpstat -t` and confirm you selected the working USB or Wi-Fi queue.

- Installing fonts

    Nobara 44 can use standard **TrueType (**`.ttf`**), OpenType (**`.otf`**), and font collections (**`.ttc`**)**. You don’t need Wine.

    The instructions below install downloaded fonts **for your account only**. Fonts installed through `dnf` are available to all users. Microsoft and Apple fonts have different licenses, so use the appropriate source for each family.

    1. **Prepare Nobara and the font folders.**

        If updates are pending, apply them through **Nobara System Updater / DNF App Center** first.

        Open Konsole or Terminal:

        ```bash
        sudo dnf install fontconfig curl cabextract unzip 7zip bsdtar
        mkdir -p "$HOME/.local/share/fonts"
        mkdir -p "$HOME/Downloads/font-setup"
        ```

        `cabextract` extracts Microsoft’s older font packages. `7zip` and `bsdtar` handle Apple’s download archives. Fedora 44 provides the `7z` command through the **7zip** package. [Fedora package details](https://packages.fedoraproject.org/pkgs/7zip/7zip/fedora-44.html)

    2. **Install Microsoft’s classic Core Fonts.**

        This collection includes **Arial, Arial Black, Times New Roman, Courier New, Verdana, Georgia, Trebuchet MS, Comic Sans MS, Impact, Andale Mono, and Webdings**.

        These are older releases distributed under the original Core Fonts license. Review the [license](https://corefonts.sourceforge.net/eula.htm) before proceeding. The original installers are preserved by the [Core Fonts project](https://sourceforge.net/projects/corefonts/files/the%20fonts/final/).

        Paste this entire block into your terminal:

        ```bash
        (
          set -e
          font_work="$(mktemp -d "$HOME/Downloads/font-setup/ms-core.XXXXXX")"
          font_dest="$HOME/.local/share/fonts/microsoft-core"
          mkdir -p "$font_dest"
          for package in \
            andale32 arial32 arialb32 comic32 courie32 georgi32 \
            impact32 times32 trebuc32 verdan32 webdin32
          do
            curl --fail --location --retry 3 \
              "https://downloads.sourceforge.net/project/corefonts/the%20fonts/final/${package}.exe" \
              --output "$font_work/${package}.exe"
            mkdir -p "$font_work/$package"
            cabextract -q \
              -d "$font_work/$package" \
              "$font_work/${package}.exe"
          done
          find "$font_work" -type f -iname '*.ttf' \
            -exec install -m 644 -t "$font_dest" {} +
          fc-cache -f
          printf 'Installers and license files retained in: %s\n' "$font_work"
        )
        ```

        This **extracts** the Windows executables; it does not run them. The block stops if a download or extraction fails.

        It does **not** install Calibri, Cambria, Consolas, Segoe UI, Aptos, or Tahoma. Don’t use Ubuntu’s `ttf-mscorefonts-installer` package name with Nobara’s `dnf`.

    3. **Add newer Microsoft fonts where available.**

        **Aptos:** Microsoft provides an official standalone ZIP download and lists compatibility with operating systems supporting TrueType or OpenType. Download **Microsoft Aptos Fonts.zip** from the [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=106087).

        Assuming it is in your Downloads folder, extract it:

        ```bash
        mkdir -p "$HOME/Downloads/font-setup/aptos"
        unzip "$HOME/Downloads/Microsoft Aptos Fonts.zip" \
          -d "$HOME/Downloads/font-setup/aptos"
        ```

        Review the included license, then install:

        ```bash
        mkdir -p "$HOME/.local/share/fonts/microsoft-aptos"
        find "$HOME/Downloads/font-setup/aptos" -type f \
          \( -iname '*.ttf' -o -iname '*.otf' \) \
          -exec install -m 644 \
            -t "$HOME/.local/share/fonts/microsoft-aptos" {} +
        fc-cache -f
        ```

        **Cascadia Code and Cascadia Mono:** these are Microsoft’s open-source programming fonts. Install the packaged versions:

        ```bash
        sudo dnf install cascadia-code-fonts cascadia-mono-fonts
        ```

        These package names are available in Fedora 44. [Fedora Cascadia packages](https://packages.fedoraproject.org/pkgs/cascadia-code-fonts/cascadia-fonts-all/fedora-44.html)

        **Calibri, Cambria, Consolas, and other Windows/Office fonts:** obtain a license that permits your intended installation. A Windows or Office license should not be assumed to authorize copying its entire font collection to Linux. [Microsoft’s licensing FAQ](https://learn.microsoft.com/en-us/typography/fonts/font-faq)

        Microsoft also offers [Fluent Calibri and Sitka for Linux](https://www.microsoft.com/en-ca/download/details.aspx?id=50721), but these have intentionally increased spacing. **Fluent Calibri is not a layout-equivalent replacement for ordinary Calibri.**

    4. **Install Apple fonts only for uses their licenses permit.**

        Apple provides **SF Pro, SF Compact, SF Mono, and New York** through its [official font downloads page](https://developer.apple.com/fonts/).

        **Apple’s downloadable fonts are not generally licensed as everyday Linux desktop or document fonts.** For example, the published San Francisco license restricts use to specified Apple-platform interface mockups and includes developer eligibility requirements. Review the license accompanying the particular download. For ordinary Nobara desktop use, consider **Inter** instead.

        If your use is permitted, download **SF-Pro.dmg** to Downloads. Then run:

        ```bash
        (
          set -e
          apple_archive="$HOME/Downloads/SF-Pro.dmg"
          apple_name="$(basename "$apple_archive" .dmg)"
          apple_work="$(mktemp -d "$HOME/Downloads/font-setup/apple.XXXXXX")"
          apple_dest="$HOME/.local/share/fonts/apple/$apple_name"
          7z x "$apple_archive" "-o$apple_work/dmg"
          apple_pkg="$(find "$apple_work/dmg" -type f \
            -name '*.pkg' -print -quit)"
          test -n "$apple_pkg"
          7z x "$apple_pkg" "-o$apple_work/pkg"
          apple_payload="$(find "$apple_work/pkg" -type f \
            -name Payload -print -quit)"
          test -n "$apple_payload"
          mkdir -p "$apple_work/fonts"
          bsdtar -xf "$apple_payload" -C "$apple_work/fonts"
          mkdir -p "$apple_dest"
          find "$apple_work/fonts" -type f \
            \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \) \
            -exec install -m 644 -t "$apple_dest" {} +
          fc-cache -f
          printf 'Extracted package retained in: %s\n' "$apple_work"
        )
        ```

        The process extracts the DMG, its installer package, and its font payload without running the installer. `bsdtar` supports compressed CPIO payloads. [Libarchive documentation](https://www.libarchive.org/)

        To install another permitted Apple download, repeat the block after changing `apple_archive` to its actual filename, such as `SF-Mono.dmg`.

        **If extraction fails, stop:** Apple may have changed the archive structure. Don’t treat an incomplete extraction as a successful installation. I could verify the documented archive layout, but could not test the downloads from this workspace.

    5. **Install Google Fonts.**

        For commonly used families, repository packages are the easiest option:

        ```bash
        sudo dnf install \
          google-roboto-fonts \
          google-noto-sans-fonts \
          google-noto-serif-fonts \
          google-noto-sans-mono-fonts
        ```

        These packages provide Roboto, Noto Sans, Noto Serif, and Noto Sans Mono. Some may already be installed. [Roboto package](https://packages.fedoraproject.org/pkgs/google-roboto-fonts/google-roboto-fonts/index.html), [Noto packages](https://packages.fedoraproject.org/pkgs/google-noto-fonts/google-noto-sans-fonts/)

        For **Inter, Montserrat, Lato, Poppins, Open Sans**, or other families:

        - Visit [Google Fonts](https://fonts.google.com/).

        - Open the family you want and use its download option, typically **Get font → Download all**.

        - Extract the ZIP.

        - Keep its license file with your downloaded files.

        - Install the `.ttf` or `.otf` files into a family-specific folder under `~/.local/share/fonts/google/`.

        For example, after downloading `Inter.zip`:

        ```bash
        unzip "$HOME/Downloads/Inter.zip" \
          -d "$HOME/Downloads/font-setup/Inter"
        ```

        Then run:

        ```bash
        (
          set -e
          google_source="$HOME/Downloads/font-setup/Inter"
          google_dest="$HOME/.local/share/fonts/google/Inter"
          # Prefer static fonts when the download includes them.
          if [ -d "$google_source/static" ]; then
            google_source="$google_source/static"
          fi
          mkdir -p "$google_dest"
          find "$google_source" -type f \
            \( -iname '*.ttf' -o -iname '*.otf' \) \
            -exec install -m 644 -t "$google_dest" {} +
          fc-cache -f
        )
        ```

        Adjust the ZIP and folder names for other families. Avoid installing both static and variable versions of the same family unless you need both.

        Google’s repository includes font files and their individual licenses. You can download the entire collection, but installing selected families keeps application font menus manageable. [Google Fonts repository](https://github.com/google/fonts)

    6. **Optionally install free Microsoft-font substitutes.**

        These are useful for opening Office documents when the original fonts aren’t available:

        | Original font   | Substitute       |
        | :-------------- | :--------------- |
        | Arial           | Liberation Sans  |
        | Times New Roman | Liberation Serif |
        | Courier New     | Liberation Mono  |
        | Calibri         | Carlito          |
        | Cambria         | Caladea          |

        Install them with:

        ```bash
        sudo dnf install \
          liberation-sans-fonts \
          liberation-serif-fonts \
          liberation-mono-fonts \
          google-carlito-fonts \
          google-crosextra-caladea-fonts
        ```

        They aim to preserve compatible text measurements, but appearance and document layout can still differ. [Liberation](https://packages.fedoraproject.org/pkgs/liberation-fonts/liberation-sans-fonts/), [Carlito](https://packages.fedoraproject.org/pkgs/texlive-collection-fontsextra/texlive-carlito/fedora-44-updates-testing.html), [Caladea](https://packages.fedoraproject.org/pkgs/google-crosextra-caladea-fonts/google-crosextra-caladea-fonts/)

    7. **Refresh, verify, and select your fonts.**

        Refresh the cache after manual installation:

        ```bash
        fc-cache -f -v
        ```

        List the installed family names:

        ```bash
        fc-list : family | sort -u
        ```

        Check which file would actually be used for a requested font:

        ```bash
        fc-match -f '%{family}\n%{file}\n' "Arial"
        fc-match -f '%{family}\n%{file}\n' "Aptos"
        fc-match -f '%{family}\n%{file}\n' "Inter"
        ```

        **Inspect the returned family and path.** `fc-match` can return a substitute when the requested font is missing.

        Completely close and reopen LibreOffice, your browser, and other applications. A reboot is usually unnecessary.

        To change desktop fonts:

        - **Nobara Official/KDE:** open System Settings, search for **Fonts**, choose your fonts, and apply. Terminal fonts may need changing separately in the terminal’s profile.

        - **Nobara GNOME:** install `gnome-tweaks`, open **Tweaks**, and use its font settings.

        Installing a font makes it available; it does not automatically make it the default. [KDE font settings](https://docs.kde.org/stable_kf6/en/plasma-workspace/kcontrol/fonts/index.html)

    8. **Handle Flatpak apps, installation scope, and removal.**

        **Flatpak:** fonts in `~/.local/share/fonts` should normally be available after restarting the app. Flatpak exposes this directory automatically; broad filesystem permissions through Flatseal should not be necessary. Prefer actual font files there over symlinks pointing into Downloads. [Flatpak documentation](https://docs.flatpak.org/en/latest/desktop-integration.html#fonts)

        **All users:** for manually installed fonts whose licenses permit it, use a dedicated directory under `/usr/local/share/fonts`. For example, to make your manually installed Inter family available system-wide:

        ```bash
        sudo install -d -m 755 /usr/local/share/fonts/inter
        find "$HOME/.local/share/fonts/google/Inter" -type f \
          \( -iname '*.ttf' -o -iname '*.otf' \) \
          -exec sudo install -m 644 \
            -t /usr/local/share/fonts/inter {} +
        sudo fc-cache -f
        ```

        Once verified, remove the redundant per-user copy to avoid duplicate installations. Leave package-managed files under `/usr/share/fonts` alone.

        **Removal:** delete only the dedicated family folder you created, then run `fc-cache -f`. For packaged fonts, remove the specific package with `sudo dnf remove PACKAGE_NAME`, reviewing the proposed transaction first.

        **Maintenance:** repository fonts update through Nobara’s updater. Manually downloaded fonts need manual updates; replace the old files rather than accumulating multiple versions.

