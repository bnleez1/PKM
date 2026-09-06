---
type: Page
collections: Public Pages
title: Installing Ubuntu 26.04 LTS
aliases:
description:
icon:
createdAt: 2026-06-04T22:53:23.936Z
lastUpdated: 2026-08-20T12:21:17.048Z
tags:
  - Linux
coverImage:
---

# Installing Ubuntu 26.04 LTS

- Fixing hibernation wakup fail

    # Ubuntu 26.04 Hibernation Setup — Home PC

    This procedure reproduces the working configuration on the identical office PC:

    - Ubuntu 26.04

    - approximately **30 GiB RAM**

    - NVMe storage

    - ext4 root filesystem

    - Intel Iris Xe graphics using `i915`

    - dracut initramfs

    - **36 GiB** `/swap.img`

    - systemd hibernation/resume

    The goal is reliable hibernation while avoiding unnecessary GRUB or graphics-driver modifications.

    ---

    ## 1. Verify the Home PC configuration

    Open Terminal and run:

    ```bash
    uname -r
    free -h
    swapon --show
    df -h /
    cat /sys/power/state
    cat /sys/power/disk
    dpkg -l | grep -E 'dracut|initramfs-tools'
    lspci -k | grep -EA3 'VGA|3D|Display'
    ```

    For a machine matching the office PC, expect approximately:

    ```text
    RAM:       30 GiB
    Swap:      probably 8 GiB initially
    Filesystem: ext4
    Graphics:  Intel Iris Xe
    Driver:    i915
    ```

    This command:

    ```bash
    cat /sys/power/state
    ```

    should include:

    ```text
    freeze mem disk
    ```

    The presence of `disk` confirms that the kernel supports hibernation.

    ---

    # Part I — Create a 36 GiB Swap File

    ## 2. Check the existing swap

    Run:

    ```bash
    swapon --show
    ```

    If the Home PC has the same original Ubuntu configuration, you may see:

    ```text
    NAME      TYPE SIZE USED PRIO
    /swap.img file   8G   0B   -1
    ```

    Also verify that you have sufficient disk space:

    ```bash
    df -h /
    ```

    A 36 GiB swapfile requires at least 36 GiB of disk space; having substantially more free space is preferable.

    ---

    ## 3. Confirm `/etc/fstab`

    Run:

    ```bash
    grep swap /etc/fstab
    ```

    For the same Ubuntu configuration, expect:

    ```text
    /swap.img none swap sw 0 0
    ```

    If that entry already exists, **do not add another one**.

    ---

    ## 4. Replace the existing swapfile

    Close memory-intensive applications first.

    Disable the current swap:

    ```bash
    sudo swapoff /swap.img
    ```

    Delete the old swapfile:

    ```bash
    sudo rm /swap.img
    ```

    Create the new 36 GiB file:

    ```bash
    sudo fallocate -l 36G /swap.img
    ```

    Restrict its permissions:

    ```bash
    sudo chmod 600 /swap.img
    ```

    Format it as swap:

    ```bash
    sudo mkswap /swap.img
    ```

    Activate it:

    ```bash
    sudo swapon /swap.img
    ```

    ---

    ## 5. Verify the new swap

    Run:

    ```bash
    swapon --show
    ```

    You should now see approximately:

    ```text
    NAME      TYPE SIZE USED PRIO
    /swap.img file  36G   0B   -1
    ```

    Also run:

    ```bash
    free -h
    ```

    Swap should now report approximately **35–36 GiB**.

    The larger swap provides considerably more capacity for the hibernation image than the original 8 GiB swap on a machine with approximately 30 GiB RAM.

    ---

    # Part II — Configure Ubuntu 26.04 dracut Resume

    Ubuntu 26.04 uses dracut for initramfs generation. A reported Ubuntu 26.04 hibernation-resume problem is fixed by explicitly including dracut's `resume` module and `systemd-hibernate-resume.service` in the initramfs.

    ## 6. Create the dracut resume configuration

    Run:

    ```bash
    sudo nano /etc/dracut.conf.d/resume.conf
    ```

    Enter exactly:

    ```text
    add_dracutmodules+=" resume "
    install_items+=" /usr/lib/systemd/system/systemd-hibernate-resume.service "
    ```

    Save:

    **Ctrl+O**

    Press:

    **Enter**

    Exit:

    **Ctrl+X**

    ---

    ## 7. Verify the configuration file

    Run:

    ```bash
    cat /etc/dracut.conf.d/resume.conf
    ```

    It should display:

    ```text
    add_dracutmodules+=" resume "
    install_items+=" /usr/lib/systemd/system/systemd-hibernate-resume.service "
    ```

    ---

    # Part III — Rebuild the Initramfs

    ## 8. Rebuild all installed initramfs images

    Run:

    ```bash
    sudo update-initramfs -u -k all
    ```

    Allow the command to finish completely.

    ---

    ## 9. Verify that resume support was included

    Run:

    ```bash
    sudo lsinitrd /boot/initrd.img-$(uname -r) | grep -Ei 'resume|hibernate'
    ```

    The important entries should include something similar to:

    ```text
    resume
    usr/lib/systemd/systemd-hibernate-resume
    usr/lib/systemd/system-generators/systemd-hibernate-resume-generator
    usr/lib/systemd/system/systemd-hibernate-resume.service
    ```

    `systemd-hibernate-resume` is the component that tells the kernel where the hibernation image is located and initiates restoration. Current systemd can obtain that information from the kernel command line or its `HibernateLocation` EFI mechanism.

    ---

    # Part IV — Reboot and Verify

    ## 10. Reboot

    Run:

    ```bash
    sudo reboot
    ```

    After Ubuntu starts again, open Terminal.

    ---

    ## 11. Confirm the swap survived the reboot

    Run:

    ```bash
    swapon --show
    ```

    You should still see:

    ```text
    /swap.img file 36G
    ```

    Then:

    ```bash
    free -h
    ```

    You should have approximately:

    ```text
    Swap: 35–36 GiB
    ```

    ---

    ## 12. Confirm hibernation support

    Run:

    ```bash
    cat /sys/power/state
    ```

    You should still see:

    ```text
    freeze mem disk
    ```

    The `disk` state is the kernel hibernation mode. systemd advertises hibernation when the kernel supports it and the necessary resources are available.

    ---

    # Part V — Test Hibernation

    ## 13. Prepare a recognizable desktop session

    For the first test, open several applications, for example:

    - Firefox

    - Files

    - Terminal

    - a document or text editor

    This makes it obvious whether Ubuntu restores the existing session rather than performing an ordinary boot.

    ---

    ## 14. Hibernate as root for the first test

    Use:

    ```bash
    sudo systemctl hibernate
    ```

    Using `sudo` deliberately avoids confusing a **polkit user-permission issue** with an actual hibernation/resume failure.

    The computer should:

    1. prepare the hibernation image;

    2. write the necessary memory state to swap;

    3. shut completely down.

    The Linux kernel supports swapfiles as hibernation storage, provided the system knows the underlying storage location and offset when restoring the image.

    ---

    ## 15. Power the PC back on

    Turn the PC on normally.

    **Do not immediately assume it has failed if the screen remains blank for a while.**

    Hibernation resume is not the same as waking from suspend. Ubuntu must:

    1. start the firmware;

    2. start the kernel/initramfs;

    3. initialize the NVMe drive;

    4. locate the hibernation image;

    5. restore saved memory;

    6. restore hardware;

    7. restore Intel graphics;

    8. return to the GNOME session.

    On the office PC, the logged kernel portion of the tested hibernation/resume transition took approximately **20 seconds**, and the total perceived power-button-to-desktop period was longer.

    For the first few tests, give the machine roughly **60–90 seconds** before deciding that resume has failed.

    ---

    # Part VI — Confirm a Successful Resume

    ## 16. Verify your session

    After resume, your previously opened applications should still be present.

    That is the decisive test that Ubuntu restored the hibernation image rather than simply booting normally.

    ---

    ## 17. Examine the resume log

    After a successful resume, run:

    ```bash
    sudo journalctl -b -o short-monotonic -k | \
    grep -Ei 'hibernate|resume|PM:|i915|drm|nvme'
    ```

    Look for lines similar to:

    ```text
    PM: hibernation: hibernation entry
    ...
    PM: hibernation: hibernation exit
    ```

    A successful `hibernation exit` following `hibernation entry` is evidence that the kernel completed the hibernation cycle.

    ---

    # Part VII — What NOT to Change

    With this configuration working, **do not add these GRUB parameters just because older tutorials recommend them**:

    ```text
    resume=
    resume_offset=
    ```

    Current systemd supports automatic acquisition of the resume location through the `HibernateLocation` EFI variable in addition to traditional kernel parameters.

    Since the identical office PC successfully restored its swapfile hibernation image without manually adding these parameters, there is no reason to introduce them on the Home PC unless resume actually fails.

    Also do **not** add experimental Intel `i915` kernel parameters merely because you see a DMC warning.

    The office PC produced an `i915` DMC warning during startup but subsequently reported successful DMC, GuC and HuC initialization and successfully resumed from hibernation. Therefore that warning is not currently sufficient evidence of a graphics-related resume failure.

    ---

    # Part VIII — About `systemctl hibernate` Saying “Access denied”

    You may find that:

    ```bash
    systemctl hibernate
    ```

    returns:

    ```text
    Call to Hibernate failed: Access denied
    ```

    while:

    ```bash
    sudo systemctl hibernate
    ```

    works.

    That is a **polkit/logind authorization issue**, not evidence that hibernation itself is broken.

    systemd's logind API uses polkit to determine whether an ordinary user is authorized to perform operations such as hibernation.

    You can check with:

    ```bash
    busctl call org.freedesktop.login1 \
      /org/freedesktop/login1 \
      org.freedesktop.login1.Manager \
      CanHibernate
    ```

    Possible results include:

    ```text
    yes        supported and authorized
    no         supported but user is not authorized
    challenge  supported but authentication is required
    na         hibernation is unavailable
    ```

    Therefore, if you receive:

    ```text
    s "no"
    ```

    but:

    ```bash
    sudo systemctl hibernate
    ```

    successfully hibernates and restores the computer, the core hibernation configuration is working.

    **Do not add a polkit rule simply to fix resume reliability.** It is a separate convenience/authorization issue and can be addressed later if you specifically want ordinary users or GNOME to initiate hibernation without `sudo`.

    ---

    # Part IX — If Resume Really Fails

    If the PC genuinely fails to restore and you eventually have to force it off and boot normally, run this after the reboot:

    ```bash
    sudo journalctl -b -1 -k | \
    grep -Ei 'hibernate|hibern|resume|PM:|ACPI|i915|drm|swap|nvme'
    ```

    Also run:

    ```bash
    sudo journalctl -b -1 | \
    grep -Ei 'hibernate|resume|sleep'
    ```

    These examine the **previous boot**, which contains the failed hibernation/resume attempt.

    Do not immediately change GRUB, the graphics driver, or the swapfile. Diagnose the failed attempt first.

    ---

    # Final Working Configuration

    The Home PC should ultimately match the office PC:

    ```text
    Ubuntu:           26.04
    RAM:              ~30 GiB
    Swap:             /swap.img
    Swap size:        36 GiB
    Swap filesystem:  ext4-hosted swapfile
    Swap at boot:     /etc/fstab
    Initramfs:        dracut
    Dracut module:    resume
    Resume service:   systemd-hibernate-resume.service
    Graphics:         Intel Iris Xe / i915
    Manual GRUB
    resume parameters: NONE
    ```

    The essential commands are therefore:

    ```bash
    sudo swapoff /swap.img
    sudo rm /swap.img
    sudo fallocate -l 36G /swap.img
    sudo chmod 600 /swap.img
    sudo mkswap /swap.img
    sudo swapon /swap.img
    ```

    Verify:

    ```bash
    swapon --show
    grep swap /etc/fstab
    ```

    Configure dracut:

    ```bash
    sudo nano /etc/dracut.conf.d/resume.conf
    ```

    with:

    ```text
    add_dracutmodules+=" resume "
    install_items+=" /usr/lib/systemd/system/systemd-hibernate-resume.service "
    ```

    Rebuild:

    ```bash
    sudo update-initramfs -u -k all
    ```

    Verify:

    ```bash
    sudo lsinitrd /boot/initrd.img-$(uname -r) | grep -Ei 'resume|hibernate'
    ```

    Reboot:

    ```bash
    sudo reboot
    ```

    Verify swap again:

    ```bash
    swapon --show
    ```

    Finally test:

    ```bash
    sudo systemctl hibernate
    ```

    This is the configuration I would reproduce on the identical Home PC before making **any additional hibernation, GRUB, ACPI, or Intel graphics changes**.

- Setting up Nautilus File Manager

    [13 Quick Tips to Make Linux File Manager Nautilus Even Better](https://www.youtube.com/watch?v=Ia2CaItxTEk)[13 Quick Tips to Make Linux File Manager Nautilus Even Better - Notes](../Weblinks/13%20Quick%20Tips%20to%20Make%20Linux%20File%20Manager%20Nautilus%20Even%20Better%20(2).md)


- Installing themes

    Ubuntu 26.04 LTS uses **GNOME 50**, so theme compatibility matters more than it did on older Ubuntu releases. (Ubuntu Documentation) Based on current GNOME 50 support and maintenance, I would rank these as follows:

    1. **Orchis — my #1 recommendation**

        - Modern Material/Windows-11-like appearance

        - Excellent rounded corners and dark mode

        - Includes a matching **GNOME Shell theme**

        - Supports libadwaita theming

        - Most importantly, its **July 7, 2026 release specifically fixed GNOME 50 issues**. (GitHub)

        - Best choice if you want Ubuntu to look modern without making it look completely unlike GNOME.

    2. **Colloid — best for a Windows 11-inspired desktop**

        - Very clean, contemporary design

        - Excellent with Dash to Panel or Dash to Dock

        - GNOME Shell supports a **floating-panel style**

        - Includes a libadwaita installation option

        - The project is still actively maintained, with a release as recently as August 2026. (GitHub)

        - **This is probably the one I'd recommend most specifically for your setup** if you're still aiming for the polished Windows 11-style Ubuntu desktop you were working on.

    3. **WhiteSur — best macOS-style theme**

        - Probably the most complete macOS transformation available

        - GTK + GNOME Shell + icons + Firefox + GDM options

        - Includes explicit libadwaita support

        - Extremely configurable: panel transparency, sizing, colors, Nautilus styling, window buttons, etc. (GitHub)

        - It remains actively maintained, with a July 2026 GTK release and August 2026 icon-theme release. (GitHub)

        - One caveat: there has been a reported GNOME 50 issue involving a thin white line on the top panel, so I would currently put Orchis and Colloid ahead of it. (GitHub)

    4. **Graphite — best understated/professional theme**

        - Clean and minimal

        - Especially attractive in dark mode

        - GNOME Shell variants include floating and colorful-panel options

        - Supports libadwaita installation/uninstallation. (GitHub)

        - Excellent if you want your computer to look customized without looking heavily themed.

    5. **Qogir — best traditional flat desktop**

        - More conventional desktop appearance

        - Includes GTK and GNOME Shell themes

        - Particularly nice if you want something somewhere between classic GNOME, Windows, and Arc. (GitHub)

        - I rank it fifth because its published GNOME Shell release history explicitly documents compatibility only through GNOME 46, whereas Orchis has an explicit GNOME 50 fix. (GitHub)

    ### First install the Ubuntu 26.04 theming tools

    Ubuntu 26.04 provides GNOME Tweaks, Extension Manager, and the GNOME 50-compatible User Themes extension in its repositories. (Ubuntu Packages)

    ```bash
    sudo apt update
    sudo apt install -y \
      gnome-tweaks \
      gnome-shell-extension-manager \
      gnome-shell-extension-user-theme \
      gnome-themes-extra \
      gtk2-engines-murrine \
      gtk2-engines-pixbuf \
      sassc \
      git
    ```

    Then open **Extension Manager → Installed** and make sure **User Themes** is enabled. That extension is what allows GNOME Shell itself—the top bar, menus, overview, notifications, etc.—to use a custom theme rather than just changing application windows. (Ubuntu Packages)

    ### My suggested setup for your Ubuntu PC

    I'd use:

    **GTK/Application theme:** `Orchis-Dark`
    **GNOME Shell:** `Orchis-Dark`
    **Icons:** Tela Circle
    **Cursor:** Bibata Modern Classic
    **Extensions:** Dash to Panel + ArcMenu + Blur My Shell + User Themes

    That combination gives you a **very polished Windows 11-style Ubuntu desktop while retaining GNOME 50's strengths**.

    If you want the strongest Windows 11 resemblance instead, I'd switch the GTK/Shell combination to **Colloid**, particularly one of its floating-shell configurations. Colloid's installer explicitly supports a floating GNOME Shell panel. (GitHub)

    If you'd like, I can give you **one copy-and-paste terminal installation sequence that installs Orchis + Tela icons + Bibata cursor + the recommended GNOME extensions on Ubuntu 26.04**.

    [1]: https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/?utm_source=chatgpt.com "Ubuntu 26.04 LTS summary - Ubuntu release notes"

    [2]: https://github.com/vinceliuice/Orchis-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/Orchis-theme"

    [3]: https://github.com/vinceliuice/Colloid-gtk-theme?utm_source=chatgpt.com "Colloid gtk theme for linux"

    [4]: https://github.com/vinceliuice/whitesur-gtk-theme "GitHub - vinceliuice/WhiteSur-gtk-theme: MacOS like theme for all gtk based desktops · GitHub"

    [5]: https://github.com/vinceliuice/WhiteSur-gtk-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/WhiteSur-gtk-theme"

    [6]: https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1399?utm_source=chatgpt.com "There is a white line on the top panel of the desktop #1399"

    [7]: https://github.com/vinceliuice/Graphite-gtk-theme "GitHub - vinceliuice/Graphite-gtk-theme: Graphite gtk theme · GitHub"

    [8]: https://github.com/vinceliuice/qogir-theme "GitHub - vinceliuice/Qogir-theme: Qogir is a flat Design theme for GTK · GitHub"

    [9]: https://github.com/vinceliuice/qogir-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/Qogir-theme"

    [10]: https://packages.ubuntu.com/resolute/s390x/gnome-tweaks?utm_source=chatgpt.com "Details of package gnome-tweaks in resolute"

    [11]: https://packages.ubuntu.com/resolute/armhf/gnome/gnome-shell-extension-user-theme?utm_source=chatgpt.com "gnome-shell-extension-user-theme (50.0-1) [universe]"

    [12]: https://github.com/vinceliuice/Colloid-gtk-theme "GitHub - vinceliuice/Colloid-gtk-theme: Colloid gtk theme for linux · GitHub"

- Installing themes 2

    Yes. I would install these **from their developers' GitHub repositories rather than downloading theme archives from GNOME-Look**, because you get the current installer and can update them later with `git pull`.

    Ubuntu 26.04 provides GNOME Shell 50's User Themes extension, and the extension exists specifically to load alternative GNOME Shell themes. (Ubuntu Packages)

    ## 1. Prepare Ubuntu 26.04 first

    You only need to do this once.

    ```bash
    sudo apt update
    sudo apt install -y \
      git \
      gnome-tweaks \
      gnome-shell-extension-user-theme \
      gnome-themes-extra \
      gtk2-engines-murrine \
      gtk2-engines-pixbuf \
      sassc
    ```

    These dependencies correspond to the requirements specified by the theme developers; Ubuntu 26.04 provides the Murrine engine and GNOME 50-compatible User Themes extension. (Ubuntu Packages)

    Create a convenient directory for the source repositories:

    ```bash
    mkdir -p ~/Themes
    cd ~/Themes
    ```

    After installing `gnome-shell-extension-user-theme`, **log out and back in**.

    Then open **Extensions** and enable:

    > **User Themes**

    This is essential for changing the **GNOME Shell** theme rather than just application windows. WhiteSur's developer explicitly recommends User Themes for this purpose. (GitHub)

    ---

    # 2. Orchis

    This is the one I would try first on Ubuntu 26.04.

    ### Download it

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git
    cd Orchis-theme
    ```

    ### Standard installation

    ```bash
    ./install.sh
    ```

    This installs the available Orchis GTK and Shell variants into your user theme directory. The installer supports light/dark variants, different accent colors, compact sizing, Shell tweaks and libadwaita integration. (GitHub)

    ### Recommended Ubuntu installation

    Because Ubuntu uses Ubuntu Dock, I'd use:

    ```bash
    ./install.sh -c dark --tweaks dock
    ```

    The Orchis installer specifically includes a `dock` tweak intended to improve compatibility with Dash-to-Dock/Ubuntu Dock. (GitHub)

    If you want GTK4/libadwaita applications themed too:

    ```bash
    ./install.sh -c dark -l --tweaks dock
    ```

    The `-l` option links the Orchis GTK4 theme into your GTK4 configuration. (GitHub)

    ### Apply Orchis

    Open:

    **GNOME Tweaks → Appearance**

    Choose something similar to:

    - Legacy Applications: **Orchis-Dark**

    - Shell: **Orchis-Dark**

    The exact installed name can vary slightly depending on the options you selected.

    ### Optional: Ubuntu logo in the Shell

    Orchis supports an Ubuntu Activities icon:

    ```bash
    ./install.sh -c dark -i ubuntu --tweaks dock
    ```

    ### Uninstall Orchis

    From `~/Themes/Orchis-theme`:

    ```bash
    ./install.sh -u
    ```

    ---

    # 3. Colloid

    Colloid would be my next choice, especially if you're trying to create a **Windows 11-like GNOME desktop**.

    ### Download

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/Colloid-gtk-theme.git
    cd Colloid-gtk-theme
    ```

    ### Standard installation

    ```bash
    ./install.sh
    ```

    The installer provides standard/light/dark themes, numerous accent colors and standard or compact sizing. (GitHub)

    ### Recommended dark installation

    ```bash
    ./install.sh -c dark
    ```

    ### Add GTK4/libadwaita support

    For a more consistent appearance across Files, Settings and modern GTK applications:

    ```bash
    ./install.sh -c dark -l
    ```

    The current Colloid installer says its default GTK4/libadwaita color scheme follows the system light/dark setting. (GitHub)

    ### Windows 11-like floating panel

    This is one reason I particularly recommend Colloid:

    ```bash
    ./install.sh -c dark -l --tweaks float
    ```

    The developer provides `float` specifically as a floating GNOME Shell panel variant. (GitHub)

    ### Apply it

    In **GNOME Tweaks → Appearance**, select:

    - Legacy Applications: **Colloid-Dark**

    - Shell: **Colloid-Dark**

    If you used the floating variant, select the corresponding Colloid Shell theme if multiple entries appear.

    ### Uninstall

    ```bash
    ./install.sh -u
    ```

    ---

    # 4. WhiteSur

    Use WhiteSur if you want Ubuntu to resemble **macOS**.

    ### Download

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
    cd WhiteSur-gtk-theme
    ```

    ### Standard installation

    ```bash
    ./install.sh
    ```

    That is the developer's standard installation procedure. (GitHub)

    ### Dark version

    ```bash
    ./install.sh -c dark
    ```

    ### Dark + libadwaita

    ```bash
    ./install.sh -c dark -l
    ```

    WhiteSur's installer supports installing the theme directly into the user's GTK4 configuration for libadwaita applications. (GitHub)

    ### Light version

    ```bash
    ./install.sh -c light -l
    ```

    ### macOS Monterey appearance

    ```bash
    ./install.sh -c dark -m
    ```

    The installer includes a dedicated Monterey style option. (GitHub)

    ### Ubuntu logo instead of Apple-style branding

    If you'd rather keep some Ubuntu identity:

    ```bash
    ./install.sh -c dark --shell -i ubuntu
    ```

    WhiteSur supports multiple GNOME Shell Activities-button icons, including Ubuntu. (GitHub)

    ### More macOS-like Nautilus

    Try:

    ```bash
    ./install.sh -c dark -l -N glassy
    ```

    Or:

    ```bash
    ./install.sh -c dark -l -N mojave
    ```

    WhiteSur currently provides multiple Nautilus layouts including `stable`, `normal`, `mojave`, `glassy`, and `right`. (GitHub)

    ### Apply WhiteSur

    GNOME Tweaks:

    - Legacy Applications: **WhiteSur-Dark**

    - Shell: **WhiteSur-Dark**

    ### Uninstall

    ```bash
    ./install.sh -r
    ```

    WhiteSur uses `-r` for removal. (GitHub)

    ---

    # 5. Graphite

    Graphite is my recommendation for a more restrained, professional desktop.

    ### Download

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/Graphite-gtk-theme.git
    cd Graphite-gtk-theme
    ```

    ### Standard install

    ```bash
    ./install.sh
    ```

    ### Recommended dark version

    ```bash
    ./install.sh -c dark
    ```

    ### Dark + libadwaita

    ```bash
    ./install.sh -c dark -l
    ```

    Graphite officially supports installing a GTK4/libadwaita link through its `-l` option. (GitHub)

    ### Floating panel version

    This is particularly attractive:

    ```bash
    ./install.sh -c dark -l --tweaks float
    ```

    The Graphite installer explicitly provides a floating GNOME Shell panel variant. (GitHub)

    You can also use a colorful panel:

    ```bash
    ./install.sh -c dark -l --tweaks colorful
    ```

    ### Change roundness

    Graphite lets you specify the window corner radius:

    ```bash
    ./install.sh -c dark -l --round 10px
    ```

    The installer supports configurable corner radii between roughly 3 and 15 pixels. (GitHub)

    ### Apply

    GNOME Tweaks:

    - Legacy Applications: **Graphite-Dark**

    - Shell: **Graphite-Dark**

    ### Uninstall

    ```bash
    ./install.sh -u
    ```

    Remove its libadwaita configuration with:

    ```bash
    ./install.sh -u -l
    ```

    Those are the developer's documented removal options. (GitHub)

    ---

    # 6. Qogir

    Qogir has a somewhat more traditional desktop appearance.

    ### Download

    ```bash
    cd ~/Themes
    git clone --depth=1 https://github.com/vinceliuice/Qogir-theme.git
    cd Qogir-theme
    ```

    ### Install default themes

    ```bash
    ./install.sh
    ```

    ### Ubuntu-specific variant

    This makes particular sense on Ubuntu:

    ```bash
    ./install.sh -t ubuntu
    ```

    Qogir specifically provides `default`, `manjaro`, and `ubuntu` primary variants. (GitHub)

    ### Recommended dark Ubuntu version

    ```bash
    ./install.sh -t ubuntu -c dark
    ```

    ### Add libadwaita

    ```bash
    ./install.sh -t ubuntu -c dark -l
    ```

    ### Rounded version

    I would probably use:

    ```bash
    ./install.sh -t ubuntu -c dark -l --tweaks round
    ```

    The Qogir installer provides `image`, `square`, and `round` tweaks. (GitHub)

    ### Windows-like square controls

    Interesting if you're building a Windows-oriented setup:

    ```bash
    ./install.sh -t ubuntu -c dark --tweaks square
    ```

    Qogir describes this option as giving the theme Windows 10-style square window controls. (GitHub)

    ### Apply

    GNOME Tweaks:

    - Legacy Applications: **Qogir-dark** or corresponding installed name

    - Shell: matching **Qogir** Shell theme

    ### Uninstall

    ```bash
    ./install.sh -u
    ```

    One caution with Qogir: its most recent published release notes document GNOME Shell fixes through **GNOME 46**, rather than explicitly documenting GNOME 50 fixes. Therefore, on Ubuntu 26.04 I would use it experimentally; if its Shell elements look wrong, use Qogir for GTK applications while leaving the GNOME Shell on Yaru or another theme. (GitHub)

    ---

    # 7. How to switch between the five

    Once they're installed, you **do not need to reinstall them every time**.

    Open:

    **Tweaks → Appearance**

    Then change both:

    **Legacy Applications**
    → Orchis / Colloid / WhiteSur / Graphite / Qogir

    and:

    **Shell**
    → corresponding Shell theme

    For example:

    | Desktop  | Applications  | GNOME Shell   |
    | :------- | :------------ | :------------ |
    | Orchis   | Orchis-Dark   | Orchis-Dark   |
    | Colloid  | Colloid-Dark  | Colloid-Dark  |
    | WhiteSur | WhiteSur-Dark | WhiteSur-Dark |
    | Graphite | Graphite-Dark | Graphite-Dark |
    | Qogir    | Qogir-dark    | Qogir-dark    |

    If **Shell** is disabled or cannot be selected, the **User Themes** extension is almost certainly not enabled.

    ## 8. Important: don't install `-l` for all five

    This is the one part I'd do differently from the basic installation instructions.

    You can safely install **all five normal GTK/Shell themes**, but don't run:

    ```bash
    ./install.sh -l
    ```

    for every theme one after another and expect GNOME to switch GTK4 styling when you select a theme in Tweaks.

    `-l` modifies or links files under:

    ```text
    ~/.config/gtk-4.0/
    ```

    so the last libadwaita configuration installed effectively becomes the one modern GTK4 applications encounter. The installers document this behavior explicitly. (GitHub)

    ### Therefore I recommend initially installing them like this

    ```bash
    # Orchis
    cd ~/Themes/Orchis-theme
    ./install.sh -c dark --tweaks dock
    # Colloid
    cd ~/Themes/Colloid-gtk-theme
    ./install.sh -c dark --tweaks float
    # WhiteSur
    cd ~/Themes/WhiteSur-gtk-theme
    ./install.sh -c dark
    # Graphite
    cd ~/Themes/Graphite-gtk-theme
    ./install.sh -c dark --tweaks float
    # Qogir
    cd ~/Themes/Qogir-theme
    ./install.sh -t ubuntu -c dark --tweaks round
    ```

    Then test them in **GNOME Tweaks**.

    Once you've decided which one you actually want as your primary desktop theme, run **that theme's** installer again with `-l`.

    ### My order for your Ubuntu 26.04 machine

    I would personally test them in this order:

    **1. Orchis → 2. Colloid → 3. Graphite → 4. WhiteSur → 5. Qogir**

    And given the Windows-like GNOME setup you've been building, I'd pay particular attention to **Colloid Dark + floating Shell**, versus **Orchis Dark + Ubuntu Dock tweak**. Those are the two I think are most likely to give you the polished result you're after.

    [1]: https://packages.ubuntu.com/source/resolute/gnome-shell-extensions?utm_source=chatgpt.com "Ubuntu – Details of source package gnome-shell-extensions in resolute"

    [2]: https://packages.ubuntu.com/en/resolute/x11/gtk2-engines-murrine?utm_source=chatgpt.com "Ubuntu – Details of package gtk2-engines-murrine in resolute"

    [3]: https://github.com/vinceliuice/WhiteSur-gtk-theme/blob/master/README.md "WhiteSur-gtk-theme/README.md at master · vinceliuice/WhiteSur-gtk-theme · GitHub"

    [4]: https://github.com/vinceliuice/Orchis-theme/blob/master/README.md "Orchis-theme/README.md at master · vinceliuice/Orchis-theme · GitHub"

    [5]: https://github.com/vinceliuice/Colloid-gtk-theme/blob/main/README.md "Colloid-gtk-theme/README.md at main · vinceliuice/Colloid-gtk-theme · GitHub"

    [6]: https://github.com/vinceliuice/Graphite-gtk-theme "GitHub - vinceliuice/Graphite-gtk-theme: Graphite gtk theme · GitHub"

    [7]: https://github.com/vinceliuice/qogir-theme "GitHub - vinceliuice/Qogir-theme: Qogir is a flat Design theme for GTK · GitHub"

    [8]: https://github.com/vinceliuice/qogir-theme/releases?utm_source=chatgpt.com "Releases · vinceliuice/Qogir-theme"

- pCloud icon does not appear in panel (fix)

    GNOME does not display traditional tray icons by default. To show the pCloud status icon in the top panel, install Ubuntu's AppIndicator extension support.

    ### 1. Install AppIndicator support

    Open Terminal and run:

    ```bash
    sudo apt update
    sudo apt install gnome-shell-extension-appindicator
    ```

    Ubuntu 26.04 provides the gnome-shell-extension-appindicator package, which adds AppIndicator and KStatusNotifierItem support to GNOME Shell, allowing applications like pCloud to display their status icons in the top panel.

    ### 2. Log out and back in

    Because Ubuntu 26.04 defaults to Wayland, a full session logout/login is required for newly installed GNOME Shell extensions to load properly.

    1. Save your work.

    2. Log out of your current session (click the power icon, then select "Log Out").

    3. Log back in to your account.

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

    Alternatively, you can enable it via the GUI:

    1. Open Extensions from your applications menu (or search for "Extensions").

    2. Find AppIndicator and KStatusNotifierItem Support.

    3. Toggle it ON.

    The extension supports both modern AppIndicators and legacy tray icons, which should cover pCloud's Linux client.

    ### 4. Restart pCloud

    Close pCloud completely:

    ```bash
    pkill -f pcloud
    ```

    Then reopen pCloud Drive from the application menu. Its icon should appear in the upper-right section of the GNOME top panel.

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

    If by "panel" you mean the bottom application dock (Dash) rather than the top status area, open pCloud, right-click its dock icon, and select Pin to Dash.

    ### Troubleshooting on Ubuntu 26.04

    If the extension appears greyed out or disabled after enabling it, you may need to disable GNOME's extension version validation:

    ```bash
    gsettings set org.gnome.shell disable-extension-version-validation true
    ```

    Then log out and back in again.

    ---

    **Key changes made:**

    - Replaced Fedora `dnf` commands with Ubuntu `apt` commands

    - Removed Fedora-specific package references

    - Emphasized Ubuntu 26.04's Wayland default (same as the original Fedora version)

    - Added Ubuntu-specific troubleshooting step about extension version validation

    - Kept the same logical flow and clear step structure

    Would you like me to apply this updated version to your note in Capacities?

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

- Installing fonts

    On **Ubuntu 26.04 LTS**, I recommend a combination of Ubuntu packages plus a single user-level fonts directory. This gives you excellent Microsoft document compatibility, common Google fonts, and a clean place for any legitimately licensed Microsoft/Apple fonts you add manually.

    ### 1. Install the Ubuntu-packaged fonts first

    Run:

    ```bash
    sudo apt update
    sudo apt install \
      ttf-mscorefonts-installer \
      fonts-liberation \
      fonts-liberation-sans-narrow \
      fonts-crosextra-carlito \
      fonts-crosextra-caladea \
      fonts-noto \
      fonts-roboto-unhinted \
      fonts-open-sans \
      font-manager
    ```

    Ubuntu 26.04 includes `ttf-mscorefonts-installer` in **Multiverse**, providing Microsoft's classic TrueType core-font collection. Ubuntu also provides Liberation fonts, while **Carlito** is metrically compatible with Calibri and **Caladea** with Cambria—particularly useful when opening Microsoft Office documents in LibreOffice. (Ubuntu Packages)

    If Ubuntu says it cannot find `ttf-mscorefonts-installer`, enable Multiverse first:

    ```bash
    sudo add-apt-repository multiverse
    sudo apt update
    sudo apt install ttf-mscorefonts-installer
    ```

    During installation, you'll need to accept Microsoft's font license.

    ### 2. Create one location for manually installed fonts

    I suggest:

    ```bash
    mkdir -p ~/.local/share/fonts/{Microsoft,Google,Apple}
    ```

    Then whenever you obtain a `.ttf`, `.otf`, or compatible font collection legitimately, copy it into the appropriate folder and rebuild the font cache:

    ```bash
    fc-cache -f -v
    ```

    This is preferable to putting manually downloaded fonts into `/usr/share/fonts`, because your personal fonts remain separate from Ubuntu-managed packages.

    ### 3. Google Fonts: download only the families you actually use

    For Google Fonts, I would **not install the entire Google Fonts repository** unless you really need thousands of fonts. Google's complete repository exceeds 1 GB, whereas Ubuntu already packages useful families such as Noto, Roboto and Open Sans. (GitHub)

    For additional fonts such as:

    ```text
    Inter
    Montserrat
    Lato
    Merriweather
    Source Sans
    Source Serif
    Poppins
    Nunito
    Oswald
    Playfair Display
    ```

    download the families you want from Google Fonts, extract them, and copy the `.ttf`/`.otf` files into:

    ```text
    ~/.local/share/fonts/Google/
    ```

    Then:

    ```bash
    fc-cache -f
    ```

    This approach also makes it much easier to remove or update an individual family later.

    ### 4. Microsoft fonts: understand the two categories

    `ttf-mscorefonts-installer` gives you the **older/classic Microsoft fonts**, but it does **not represent the complete modern Microsoft Office collection**. Modern Office documents commonly use fonts such as **Calibri, Cambria, Candara, Consolas, Corbel, Segoe UI and Aptos**; Microsoft identifies Aptos as its newer Office typeface replacing Calibri. (Microsoft Learn)

    If you legitimately have the font files from a licensed Windows/Microsoft Office installation, you can place permitted copies in:

    ```text
    ~/.local/share/fonts/Microsoft/
    ```

    and run:

    ```bash
    fc-cache -f
    ```

    For example, with legitimate `.ttf` files:

    ```bash
    cp ~/Downloads/*.ttf ~/.local/share/fonts/Microsoft/
    fc-cache -f
    ```

    Microsoft's font licensing varies by font, so I would avoid the many GitHub scripts that simply download proprietary Microsoft fonts from unofficial locations. Microsoft itself notes that redistribution rights vary among its fonts. (Microsoft Learn)

    For your **UAA Word/PowerPoint document compatibility**, the particularly valuable ones are:

    - Aptos

    - Calibri

    - Cambria

    - Candara

    - Consolas

    - Constantia

    - Corbel

    - Segoe UI

    - Arial

    - Times New Roman

    ### 5. Apple fonts require more caution

    Apple officially provides fonts such as **SF Pro, SF Compact, SF Mono and New York**, but their licenses are considerably more restrictive than Google Fonts. Apple's own SF license, for example, limits use of San Francisco to designing interfaces for Apple-platform software rather than treating it as a general-purpose freely redistributable desktop font. (Apple Developer)

    Therefore, I would **not use one of the Ubuntu/Linux scripts that downloads Apple fonts from an unofficial repository**.

    If you already possess Apple font files and their license allows your intended use, place them under:

    ```text
    ~/.local/share/fonts/Apple/
    ```

    and rebuild:

    ```bash
    fc-cache -f
    ```

    For general Linux typography, **Inter** is an excellent freely licensed alternative when you want something visually similar to Apple's San Francisco style.

    ### 6. Verify everything

    You can check individual families with:

    ```bash
    fc-match Arial
    fc-match "Times New Roman"
    fc-match Calibri
    fc-match Cambria
    fc-match Roboto
    fc-match "Open Sans"
    fc-match "Noto Sans"
    ```

    For example:

    ```bash
    fc-match Calibri
    ```

    If Calibri itself isn't installed, Ubuntu may return Carlito instead—which is desirable for layout compatibility because Carlito is specifically metrically compatible with Calibri. (Ubuntu Packages)

    You can see all installed families with:

    ```bash
    fc-list : family | sort -u | less
    ```

    ### What I would install on your Ubuntu machine

    For the kind of **LibreOffice, Microsoft Office document, Moodle, teaching-material and web-design work** you do, I'd aim for this set:

    ```text
    MICROSOFT
    Arial
    Times New Roman
    Verdana
    Georgia
    Trebuchet MS
    Calibri
    Cambria
    Aptos
    Segoe UI
    Consolas
    COMPATIBILITY
    Carlito
    Caladea
    Liberation Sans
    Liberation Serif
    Liberation Mono
    GOOGLE
    Noto Sans
    Noto Serif
    Roboto
    Open Sans
    Inter
    Lato
    Montserrat
    Merriweather
    Source Sans
    Source Serif
    APPLE
    Only legitimately licensed Apple fonts you specifically need
    ```

    **The key is not to install hundreds or thousands unnecessarily.** Around 25–40 well-chosen families gives you very good compatibility without turning the font menus in LibreOffice, OnlyOffice, GIMP, Kdenlive, browsers, etc. into a mess.

    [1]: https://packages.ubuntu.com/resolute/ttf-mscorefonts-installer "Ubuntu – Details of package ttf-mscorefonts-installer in resolute"

    [2]: https://github.com/google/fonts?utm_source=chatgpt.com "Google Fonts Files"

    [3]: https://learn.microsoft.com/en-us/typography/font-list/aptos?utm_source=chatgpt.com "Aptos - Typography"

    [4]: https://learn.microsoft.com/en-us/typography/fonts/font-faq?utm_source=chatgpt.com "Font redistribution FAQ - Typography"

    [5]: https://developer.apple.com/fonts/?utm_source=chatgpt.com "Fonts - Apple Developer"

    [6]: https://packages.ubuntu.com/resolute/s390x/fonts-crosextra-carlito?utm_source=chatgpt.com "Details of package fonts-crosextra-carlito in resolute - Ubuntu"

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

- Click to minimize

    ```text
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    ```
