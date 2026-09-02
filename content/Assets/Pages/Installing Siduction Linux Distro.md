---
type: 'Page'
title: Installing Siduction Linux Distro
aliases: null
description: null
icon: ✴️
createdAt: '2026-07-18T02:39:23.949Z'
lastUpdated: '2026-08-03T15:50:45.294Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(424).md)'
---

# Installing Siduction Linux Distro

[Making sure you’re not a bot!](https://siduction.org/)[[Making sure you’re not a bot!|Making sure you’re not a bot! - Notes]]

- Apps to remove on fresh install

    - Remove Flameshot package

        Add **Flameshot** to the software-removal instructions as follows:

        ```bash
        sudo apt purge flameshot
        sudo apt autoremove --purge
        sudo apt clean
        ```

        To remove any remaining user configuration files:

        ```bash
        rm -rf ~/.config/flameshot
        ```

        If Flameshot was installed through Flatpak instead of APT, check with:

        ```bash
        flatpak list | grep -i flameshot
        ```

        Then remove it with:

        ```bash
        flatpak uninstall org.flameshot.Flameshot
        flatpak uninstall --unused
        ```

        To verify that it has been removed:

        ```bash
        command -v flameshot
        dpkg -l | grep -i flameshot
        flatpak list | grep -i flameshot
        ```

        No output from those commands indicates that Flameshot is no longer installed.

    Below is a safe, thorough procedure for removing the applications, their Debian packages, unused dependencies, and—optionally—their personal settings and data.

    The relevant Debian Sid package names are `alligator`, `elisa`, `gimp`, `kaddressbook`, `kcalc`, `kmail`, `konqueror`, `libreoffice`, `okular`, and `tokodon`. (Debian Packages)

    ## 1. Close the applications

    Close all the listed applications.

    Because KMail and KAddressBook use the shared Akonadi personal-information database, stop it before backing up or deleting related files:

    ```bash
    akonadictl stop 2>/dev/null || true
    ```

    If the command is not found, continue normally.

    ## 2. Back up KMail and KAddressBook data

    Skip this only when you are certain that you do not need any locally stored mail, contacts, account settings, or address books.

    ```bash
    mkdir -p "$HOME/App-removal-backup"
    (
      cd "$HOME" || exit
      tar --ignore-failed-read -czf \
        "$HOME/App-removal-backup/kde-pim-backup-$(date +%F).tar.gz" \
        .config/akonadi \
        .config/kmail2rc \
        .config/kaddressbookrc \
        .local/share/akonadi \
        .local/share/local-mail \
        .local/share/kmail2 \
        2>/dev/null
    )
    ```

    Confirm that the backup exists:

    ```bash
    ls -lh "$HOME/App-removal-backup/"
    ```

    ## 3. Update the package information

    ```bash
    sudo apt update
    ```

    Do not run a full upgrade just to remove these applications.

    ## 4. Simulate the removal first

    APT supports exact package names and quoted glob patterns. Purging removes systemwide package configuration, but it does not remove personal data stored in your home directory. (Debian Manpages)

    Run this simulation:

    ```bash
    sudo apt -s purge \
      'alligator*' \
      'elisa*' \
      'gimp*' \
      'kaddressbook*' \
      'kcalc*' \
      'kmail*' \
      accountwizard \
      'kdepim-themeeditors*' \
      'konqueror*' \
      'konq-plugins*' \
      'libreoffice*' \
      'okular*' \
      'tokodon*'
    ```

    The `-s` option means **simulate**; nothing is removed. (Debian Manpages)

    Review the packages listed under **The following packages will be REMOVED**.

    It is generally acceptable if APT also removes application metapackages such as:

    ```text
    kde-standard
    kdeutils
    kdemultimedia
    kdepim
    ```

    Metapackages mostly exist to install collections of other packages. For example, Debian’s `kdemultimedia` metapackage includes Elisa, while `kdeutils` includes KCalc. (Debian Packages)

    **Do not proceed** if the simulation proposes removing essential desktop components such as:

    ```text
    plasma-desktop
    plasma-workspace
    sddm
    dolphin
    konsole
    network-manager
    systemd
    linux-image-amd64
    ```

    ## 5. Perform the actual purge

    When the simulation looks safe, run the same command without `-s`:

    ```bash
    sudo apt purge \
      'alligator*' \
      'elisa*' \
      'gimp*' \
      'kaddressbook*' \
      'kcalc*' \
      'kmail*' \
      accountwizard \
      'kdepim-themeeditors*' \
      'konqueror*' \
      'konq-plugins*' \
      'libreoffice*' \
      'okular*' \
      'tokodon*'
    ```

    APT will show the package list again. Read it before entering `Y`.

    ### Why these additional package names are included

    - `accountwizard` is the KDE PIM email-account setup tool associated with KMail. (Debian Packages)

    - **KMail Header Theme Editor** is supplied by `kdepim-themeeditors`. Removing that package may also remove other KDE PIM theme editors, such as the contact theme editors. (docs.kde.org)

    - The quoted `libreoffice*` pattern removes Writer, Calc, Impress, Draw, Base, Math, language packages, help packages, and LibreOffice integration components. LibreOffice itself is a metapackage that installs its individual components. (Debian Packages)

    - `okular*` also catches packages such as `okular-data`, documentation, and extra backends. (Debian Packages)

    ## 6. Remove unused dependencies

    First simulate the cleanup:

    ```bash
    sudo apt -s autoremove --purge
    ```

    Review the list carefully. In particular, make sure it is not proposing to remove Plasma, Dolphin, networking, printing, Bluetooth, or another application you use.

    If the list looks safe:

    ```bash
    sudo apt autoremove --purge
    ```

    Siduction’s own package-management instructions recommend `apt autoremove` for dependencies that are no longer required after removing applications. (Siduction Manual)

    Clear downloaded package files:

    ```bash
    sudo apt clean
    ```

    ## 7. Remove personal settings and application data

    This step is what makes the removal more complete. It permanently deletes settings, caches, histories, feeds, accounts, local mail, application databases, and customizations.

    ### Important data warning

    The following deletion includes:

    - Alligator feed subscriptions and history

    - Elisa’s music database

    - GIMP brushes, plug-ins, presets, and preferences stored in your home folder

    - KMail settings and locally stored mail

    - KAddressBook settings

    - LibreOffice user profile, templates, macros, and extensions

    - Okular document history and locally stored document metadata

    - Tokodon accounts and local state

    Run:

    ```bash
    rm -rf \
      "$HOME/.config/alligatorrc" \
      "$HOME/.local/share/alligator" \
      "$HOME/.cache/alligator" \
      "$HOME/.config/elisarc" \
      "$HOME/.local/share/elisa" \
      "$HOME/.cache/elisa" \
      "$HOME/.config/GIMP" \
      "$HOME/.local/share/GIMP" \
      "$HOME/.cache/gimp" \
      "$HOME/.config/kaddressbookrc" \
      "$HOME/.local/share/kaddressbook" \
      "$HOME/.cache/kaddressbook" \
      "$HOME/.config/kcalcrc" \
      "$HOME/.config/kmail2rc" \
      "$HOME/.config/kmailsearchindexingrc" \
      "$HOME/.local/share/kmail2" \
      "$HOME/.local/share/local-mail" \
      "$HOME/.cache/kmail" \
      "$HOME/.config/headerthemeeditorrc" \
      "$HOME/.config/contactthemeeditorrc" \
      "$HOME/.config/contactprintthemeeditorrc" \
      "$HOME/.config/konquerorrc" \
      "$HOME/.local/share/konqueror" \
      "$HOME/.cache/konqueror" \
      "$HOME/.config/libreoffice" \
      "$HOME/.local/share/libreoffice" \
      "$HOME/.cache/libreoffice" \
      "$HOME/.config/okularrc" \
      "$HOME/.local/share/okular" \
      "$HOME/.cache/okular" \
      "$HOME/.config/tokodonrc" \
      "$HOME/.local/share/tokodon" \
      "$HOME/.cache/tokodon"
    ```

    Do **not** put `sudo` before this command. These are files in your own home directory.

    ## 8. Optional: remove the shared Akonadi database

    KMail and KAddressBook store much of their data through Akonadi.

    Do this only when you do not use any other Akonadi-based applications, such as:

    - KOrganizer

    - Kontact

    - Merkuro or Kalendar

    - KNotes

    - Akregator integrated with Kontact

    Removing Akonadi’s personal database can erase calendars, tasks, notes, contacts, and other KDE PIM information.

    After confirming that your backup exists:

    ```bash
    akonadictl stop 2>/dev/null || true
    rm -rf \
      "$HOME/.config/akonadi" \
      "$HOME/.local/share/akonadi" \
      "$HOME/.cache/akonadi"
    ```

    Remove remaining Akonadi resource configuration files:

    ```bash
    find "$HOME/.config" -maxdepth 1 \
      \( -iname 'akonadi*' -o -iname '*maildir*resource*' \) \
      -print
    ```

    Review the output. To delete those files:

    ```bash
    find "$HOME/.config" -maxdepth 1 \
      \( -iname 'akonadi*' -o -iname '*maildir*resource*' \) \
      -delete
    ```

    Do not manually purge `akonadi-server` or KDE PIM libraries unless `apt autoremove --purge` identifies them as unused.

    ## 9. Check for Flatpak installations

    APT removal does not affect Flatpak versions.

    Check:

    ```bash
    flatpak list --app --columns=application,name 2>/dev/null |
    grep -Ei 'alligator|elisa|gimp|kaddressbook|kcalc|kmail|konqueror|libreoffice|okular|tokodon'
    ```

    For every application ID shown, remove it with:

    ```bash
    flatpak uninstall --delete-data APPLICATION_ID
    ```

    For example, use the exact ID displayed by `flatpak list`; do not type `APPLICATION_ID` literally.

    Then remove unused Flatpak runtimes:

    ```bash
    flatpak uninstall --unused
    ```

    ## 10. Check for leftover menu shortcuts

    Search for user-created desktop shortcuts:

    ```bash
    grep -RIlE \
      'Alligator|Elisa|GIMP|KAddressBook|KCalc|KMail|Konqueror|LibreOffice|Okular|Tokodon' \
      "$HOME/.local/share/applications" \
      2>/dev/null
    ```

    Review any files found. Remove only shortcuts belonging to the deleted applications:

    ```bash
    rm "$HOME/.local/share/applications/name-of-shortcut.desktop"
    ```

    Refresh the Plasma application database:

    ```bash
    kbuildsycoca6 --noincremental
    ```

    Then log out of Plasma and log back in.

    ## 11. Verify removal

    Check for remaining installed or residual packages:

    ```bash
    dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' 2>/dev/null |
    grep -Ei '^(ii|rc).*(alligator|elisa|gimp|kaddressbook|kcalc|kmail|kdepim-themeeditors|konqueror|libreoffice|okular|tokodon)'
    ```

    No output means no matching installed packages or residual system configuration remains.

    Check whether executable commands still exist:

    ```bash
    for app in alligator elisa gimp kaddressbook kcalc kmail konqueror libreoffice okular tokodon; do
      if command -v "$app" >/dev/null 2>&1; then
        echo "Still present: $app -> $(command -v "$app")"
      else
        echo "Removed: $app"
      fi
    done
    ```

    Finally, reboot:

    ```bash
    systemctl reboot
    ```

    After reboot, the applications should be absent from the application menu, their Debian packages should be purged, and—provided you completed the optional data-removal steps—their personal settings and application data should also be gone.

    [1]: https://packages.debian.org/sid/alligator?utm_source=chatgpt.com "Debian -- Details of package alligator in sid"

    [2]: https://manpages.debian.org/unstable/apt/apt.8.en.html?utm_source=chatgpt.com "apt(8) — apt — Debian unstable — Debian Manpages"

    [3]: https://manpages.debian.org/unstable/apt/apt-get.8.en.html?utm_source=chatgpt.com "apt-get(8) — apt — Debian unstable — Debian Manpages"

    [4]: https://packages.debian.org/sid/metapackages/kdemultimedia?utm_source=chatgpt.com "Package: kdemultimedia (4:26.04.0+5.170 and others)"

    [5]: https://packages.debian.org/sid/utils/accountwizard?utm_source=chatgpt.com "Debian -- Details of package accountwizard in sid"

    [6]: https://docs.kde.org/trunk_kf6/en/grantlee-editor/headerthemeeditor/index.html?utm_source=chatgpt.com "The Header Theme Editor Handbook"

    [7]: https://packages.debian.org/sid/libreoffice?utm_source=chatgpt.com "Debian -- Details of package libreoffice in sid"

    [8]: https://packages.debian.org/source/sid/okular?utm_source=chatgpt.com "Debian -- Details of source package okular in sid"

    [9]: https://manual.siduction.org/sys-admin-apt_en.html?utm_source=chatgpt.com "A small APT cookbook"

- Getting sudo access

    apt update
    apt install sudo
    adduser ben sudo

- Installing QualCoder

    ## Recommended: use the official Linux executable

    QualCoder 3.8.2 provides a standalone Linux executable intended to work on recent Debian-based distributions. It is not a `.deb` package, so it should be installed in your home directory rather than through `apt`. (GitHub)

    ### 1. Confirm your processor architecture

    ```bash
    uname -m
    ```

    Continue with the binary method when the result is:

    ```text
    x86_64
    ```

    ### 2. Download the Linux executable

    Either expand **Assets** on the release page and download:

    ```text
    QualCoder_3_8_2_ubuntu
    ```

    Or download it directly:

    ```bash
    wget -O ~/Downloads/QualCoder_3_8_2_ubuntu \
    https://github.com/ccbogel/QualCoder/releases/download/3.8.2/QualCoder_3_8_2_ubuntu
    ```

    ### 3. Install it under your account

    ```bash
    mkdir -p ~/.local/opt/qualcoder-3.8.2
    mkdir -p ~/.local/bin
    install -m 755 \
      ~/Downloads/QualCoder_3_8_2_ubuntu \
      ~/.local/opt/qualcoder-3.8.2/qualcoder
    ln -sfn \
      ~/.local/opt/qualcoder-3.8.2/qualcoder \
      ~/.local/bin/qualcoder
    ```

    Start it with:

    ```bash
    ~/.local/bin/qualcoder
    ```

    The release instructions specifically require making the Linux file executable before running it. (GitHub)

    ## Add QualCoder to the KDE application menu

    Run:

    ```bash
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/qualcoder.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=QualCoder
    Comment=Qualitative data analysis software
    Exec=$HOME/.local/bin/qualcoder
    Icon=applications-science
    Terminal=false
    Categories=Education;Science;Office;
    StartupNotify=true
    EOF
    chmod +x ~/.local/share/applications/qualcoder.desktop
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
    ```

    QualCoder should then appear in KDE’s application launcher. Logging out should not be necessary, although the launcher may need to be reopened.

    ## Audio and video support

    VLC is optional but needed for QualCoder’s audio/video coding features; `ffmpeg` supports waveform and related media processing. (GitHub)

    ```bash
    sudo apt update
    sudo apt install vlc ffmpeg libxcb-cursor0
    ```

    Then restart QualCoder.

    ## Source installation fallback

    Use this when the standalone executable fails, audio/video support is not detected, or you prefer a Python virtual environment. The project recommends source installations inside a virtual environment, and QualCoder currently requires Python 3.12 or newer with PyQt6. (GitHub)

    ```bash
    sudo apt update
    sudo apt install \
      python3 \
      python3-venv \
      python3-pip \
      wget \
      vlc \
      ffmpeg \
      libxcb-cursor0
    ```

    Check Python:

    ```bash
    python3 --version
    ```

    Then install QualCoder:

    ```bash
    mkdir -p ~/.local/share
    cd ~/.local/share
    wget -O QualCoder-3.8.2.tar.gz \
    https://github.com/ccbogel/QualCoder/archive/refs/tags/3.8.2.tar.gz
    tar -xzf QualCoder-3.8.2.tar.gz
    cd QualCoder-3.8.2
    python3 -m venv env
    source env/bin/activate
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
    cd src
    python -m qualcoder
    ```

    The official Linux instructions use this same `venv` → `pip install -r requirements.txt` → `python -m qualcoder` procedure. (GitHub)

    ### Important for your pCloud setup

    Keep the **active QualCoder project folder on your local internal drive**, such as:

    ```text
    /home/ben/Documents/QualCoder Projects
    ```

    Do not actively edit a project located inside pCloud or another cloud-synchronized folder. A QualCoder maintainer warns that running the project from cloud storage risks database corruption. Close QualCoder before copying a backup into pCloud. (GitHub)

    [1]: https://github.com/ccbogel/QualCoder/releases/tag/3.8.2 "Release QualCoder 3.8.2 · ccbogel/QualCoder · GitHub"

    [2]: https://github.com/ccbogel/QualCoder "GitHub - ccbogel/QualCoder: Qualitative data analysis for text, images, audio, video. Cross platform. Python 3.12 or newer and PyQt6. · GitHub"

    [3]: https://github.com/ccbogel/QualCoder/discussions/1214?utm_source=chatgpt.com "QualCoder 3.8.2 #1214"

- Reestablishing F12 keyboard shortcut to access Yakuake dropdown terminal and removes Inspector code in Firefox

    The screenshot confirms that **F12 is reaching Firefox**, which opens Developer Tools. KDE is therefore not currently capturing F12 as Yakuake’s global shortcut.

    ## Re-register F12 for Yakuake

    1. Close Firefox Developer Tools by clicking the **×** at the upper-right of the developer panel.

    2. Open **Yakuake manually** from the application menu.

    3. In Yakuake, open the **☰ menu**.

    4. Select **Configure Keyboard Shortcuts…**

    5. Locate **Open/Retract Yakuake**.

    6. Select **Custom**, click the shortcut box, and press **F12**.

    7. Click **Apply**, then **OK**.

    8. Leave Yakuake running and test F12 while Firefox is focused.

    Yakuake normally uses F12 to open and retract the terminal. (KDE UserBase)

    ## If F12 is already shown but does not work

    The shortcut registration may be stale. This has occurred with Yakuake under Plasma 6, and removing and recreating its shortcut entry has restored it for other users. (Reddit)

    1. Open **System Settings**.

    2. Go to **Keyboard → Shortcuts**.

    3. Search for:

    ```text
    Yakuake
    ```

    1. Select the Yakuake entry.

    2. Remove the current F12 assignment from **Open/Retract Yakuake**.

    3. Hover over the Yakuake application entry and click the **trash-can icon**.

    4. Click **Apply**.

    5. Close and reopen System Settings.

    6. Return to **Keyboard → Shortcuts**.

    7. Choose **Add New → Application…**

    8. Select **Yakuake**.

    9. Assign **F12** to **Open/Retract Yakuake**.

    10. Click **Apply**.

    11. Log out of Siduction and log back in.

    ## Make Yakuake start automatically

    Open:

    **System Settings → Autostart**

    If Yakuake is not listed:

    1. Click **Add…**

    2. Select **Add Application…**

    3. Choose **Yakuake**

    4. Log out and back in.

    Once KDE successfully registers F12 globally, Firefox should no longer receive that keystroke, so Developer Tools should not open.

    ## Verify the saved shortcut

    Run this in a terminal:

    ```bash
    grep -A6 '^\[yakuake\]' ~/.config/kglobalshortcutsrc
    ```

    You should see a line similar to:

    ```text
    toggle-window-state=F12,F12,Open/Retract Yakuake
    ```

    If the Yakuake section is missing even after applying the GUI changes, the **remove Yakuake → Apply → add Yakuake again** procedure above is the most appropriate repair.

    [1]: https://userbase.kde.org/Yakuake?utm_source=chatgpt.com "Yakuake - KDE UserBase Wiki"

    [2]: https://www.reddit.com/r/kde/comments/1duzxgx/f12_key_isnt_opening_yakuake_terminal_in_kde/?utm_source=chatgpt.com "F12 key isn't opening Yakuake terminal in KDE plasma 6.1"

- Gaining permission to backup PC to pCloud

- Missing main folders in Dolphin (fix) 

    Dolphin’s **Videos** shortcut points to `/home/ben/Videos`, but that folder is currently missing. Dolphin’s Places panel contains shortcuts to locations such as the standard XDG folders. (KDE Documentation)

    ## Easiest correction

    Click **Create missing folder** in the red notification bar.

    That should recreate:

    ```text
    /home/ben/Videos
    ```

    The new folder will be empty; this does not restore any videos that may previously have been stored there.

    ## Recommended terminal correction

    Open **Konsole** and run these commands as your normal user, without `sudo`:

    ```bash
    mkdir -p "$HOME/Videos"
    xdg-user-dirs-update --set VIDEOS "$HOME/Videos"
    xdg-user-dir VIDEOS
    ```

    The final command should return:

    ```text
    /home/ben/Videos
    ```

    The `xdg-user-dirs-update --set` command officially sets the location of an individual standard folder such as `VIDEOS`. (Debian Manpages)

    Verify the folder and ownership:

    ```bash
    ls -ld "$HOME/Videos"
    ```

    You should see `ben ben` as the owner and group.

    ## Restart Dolphin

    Close all Dolphin windows and reopen it. Alternatively, run:

    ```bash
    kquitapp6 dolphin 2>/dev/null
    dolphin "$HOME/Videos" &
    ```

    ## If the folder has the wrong ownership

    Only when `ls -ld` shows that `root` owns it, run:

    ```bash
    sudo chown "$USER":"$(id -gn)" "$HOME/Videos"
    chmod u+rwx "$HOME/Videos"
    ```

    Then reopen Dolphin. The **Videos** entry should work normally again.

    [1]: https://docs.kde.org/stable/es/applications/dolphin/panels.html?utm_source=chatgpt.com "Panels"

    [2]: https://manpages.debian.org/trixie/xdg-user-dirs/xdg-user-dirs-update.1.en.html?utm_source=chatgpt.com "xdg-user-dirs-update [OPTION...] [--set NAME PATH...]"

- Installing fonts: Microsoft, Google, and Apple

    The safest approach is to install Microsoft’s redistributable core fonts and Google fonts from Debian packages, then install Apple fonts manually from Apple’s official downloads. Run the commands as your normal user `ben`; use `sudo` only where shown.

    ## 1. Make sure Debian `contrib` is enabled

    Microsoft’s core-font installer is in Debian’s `contrib` repository. (Debian Packages)

    Check your Debian repository configuration:

    ```bash
    grep -RsnE '^(deb |Components:)' \
      /etc/apt/sources.list \
      /etc/apt/sources.list.d 2>/dev/null
    ```

    Look for a Debian Sid entry containing:

    ```text
    main contrib non-free non-free-firmware
    ```

    ### For a `.sources` file

    Edit the existing Debian source file shown by the previous command, commonly:

    ```bash
    sudo nano /etc/apt/sources.list.d/debian.sources
    ```

    Make sure its components line resembles:

    ```text
    Components: main contrib non-free non-free-firmware
    ```

    ### For an older `.list` file

    Edit the appropriate file:

    ```bash
    sudo nano /etc/apt/sources.list
    ```

    The Debian Sid line should end with:

    ```text
    sid main contrib non-free non-free-firmware
    ```

    Do not create a duplicate Debian repository entry. Debian supports both traditional `.list` files and newer deb822 `.sources` files. (Debian Manpages)

    Update APT:

    ```bash
    sudo apt update
    ```

    ## 2. Install Microsoft fonts

    Run:

    ```bash
    sudo apt install \
      ttf-mscorefonts-installer \
      fonts-liberation \
      fonts-crosextra-carlito \
      fonts-crosextra-caladea
    ```

    During installation, a license screen may appear:

    1. Press **Tab** until `<OK>` is selected.

    2. Press **Enter**.

    3. Select **Yes** to accept the license.

    4. Press **Enter**.

    The `ttf-mscorefonts-installer` package installs Microsoft’s older web-font collection, including Arial, Times New Roman, Courier New, Georgia, Verdana, Trebuchet MS, Comic Sans MS, Impact and Webdings. It does **not** install newer Microsoft fonts such as Calibri, Cambria, Aptos or Segoe UI. (Debian Packages)

    The additional free fonts provide document-compatible alternatives:

    - **Carlito** is metrically compatible with Calibri.

    - **Caladea** is metrically compatible with Cambria.

    - **Liberation Sans, Serif and Mono** are compatible with Arial, Times New Roman and Courier New document layouts. (Debian Packages)

    If the Microsoft installer did not finish correctly, run:

    ```bash
    sudo dpkg-reconfigure ttf-mscorefonts-installer
    ```

    Then check its status:

    ```bash
    dpkg -l ttf-mscorefonts-installer
    ```

    The line should begin with:

    ```text
    ii
    ```

    ## 3. Install Google fonts

    This recommended collection provides Roboto, Noto, emoji support and several widely used Google Fonts families:

    ```bash
    sudo apt install \
      fonts-noto-core \
      fonts-noto-ui-core \
      fonts-noto-mono \
      fonts-noto-color-emoji \
      fonts-roboto \
      fonts-open-sans \
      fonts-montserrat
    ```

    Debian Sid currently provides the Noto core, UI, monospace and color-emoji packages, as well as Roboto. (Debian Packages)

    For Chinese, Japanese and Korean support, add:

    ```bash
    sudo apt install fonts-noto-cjk
    ```

    That package is relatively large because it includes Noto Sans, Serif and Mono variants for Japanese, Korean, Simplified Chinese and Traditional Chinese. (Debian Packages)

    ### Optional: install the complete Noto collection

    ```bash
    sudo apt install fonts-noto
    ```

    The `fonts-noto` metapackage is intended to install the broad Noto collection, so it will consume considerably more space and add many font families to application menus. (Debian Packages)

    ## 4. Install Apple fonts

    Apple’s proprietary system fonts are generally not supplied as ordinary Debian packages. Apple provides fonts such as **SF Pro**, **SF Compact** and related design resources through its official developer-design resources. Their use remains subject to Apple’s accompanying license terms. (Apple Developer)

    ### Recommended Apple-like open-source alternative

    Install Inter:

    ```bash
    sudo apt install fonts-inter
    ```

    Inter is designed for high legibility in computer interfaces and provides an excellent Linux desktop alternative to Apple’s San Francisco family. (Debian Packages)

    You may also install DejaVu:

    ```bash
    sudo apt install fonts-dejavu
    ```

    ### Installing actual Apple font files

    First download the desired font package from Apple’s official design-resources page using Firefox. It will normally be downloaded as a `.dmg` file.

    Install 7-Zip, which can extract DMG and XAR-based package files:

    ```bash
    sudo apt install 7zip
    ```

    Debian Sid’s `7zip` package supports DMG and XAR extraction. (Debian Packages)

    Create extraction and font directories:

    ```bash
    mkdir -p "$HOME/apple-font-extract"
    mkdir -p "$HOME/.local/share/fonts/Apple"
    ```

    List the downloaded DMG files:

    ```bash
    find "$HOME/Downloads" -maxdepth 1 -type f -iname '*.dmg'
    ```

    Extract the downloaded Apple package, replacing the filename with the actual file shown above:

    ```bash
    cd "$HOME/apple-font-extract"
    7z x "$HOME/Downloads/SF-Pro.dmg" -oSF-Pro
    ```

    Find any package files inside it:

    ```bash
    find "$HOME/apple-font-extract" -type f -iname '*.pkg'
    ```

    Extract the package. Adjust the path to match the result from the previous command:

    ```bash
    mkdir -p "$HOME/apple-font-extract/package"
    7z x \
      "$HOME/apple-font-extract/SF-Pro/SF Pro Fonts.pkg" \
      -o"$HOME/apple-font-extract/package"
    ```

    Look for font files:

    ```bash
    find "$HOME/apple-font-extract" -type f \
      \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \)
    ```

    If font files are found, copy them into your personal Apple-font directory:

    ```bash
    find "$HOME/apple-font-extract" -type f \
      \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \) \
      -exec cp -n '{}' "$HOME/.local/share/fonts/Apple/" \;
    ```

    Apple occasionally changes the internal structure of its downloadable packages. If the first package extraction produces a file named `Payload`, extract it too:

    ```bash
    find "$HOME/apple-font-extract" -type f -name 'Payload'
    ```

    Then, using the actual path shown:

    ```bash
    mkdir -p "$HOME/apple-font-extract/payload"
    7z x \
      "$HOME/apple-font-extract/package/Payload" \
      -o"$HOME/apple-font-extract/payload"
    ```

    Copy the newly extracted fonts:

    ```bash
    find "$HOME/apple-font-extract/payload" -type f \
      \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \) \
      -exec cp -n '{}' "$HOME/.local/share/fonts/Apple/" \;
    ```

    Do not use `sudo` for files installed under:

    ```text
    ~/.local/share/fonts
    ```

    ## 5. Install individual Google Fonts manually

    For a Google Fonts family that is not available through APT:

    1. Download the family as a ZIP from the official Google Fonts site. (Google Fonts)

    2. Create a directory:

    ```bash
    mkdir -p "$HOME/.local/share/fonts/Google"
    mkdir -p "$HOME/google-font-extract"
    ```

    1. Extract the ZIP, replacing the filename:

    ```bash
    unzip "$HOME/Downloads/FontFamily.zip" \
      -d "$HOME/google-font-extract"
    ```

    1. Copy the fonts:

    ```bash
    find "$HOME/google-font-extract" -type f \
      \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \) \
      -exec cp -n '{}' "$HOME/.local/share/fonts/Google/" \;
    ```

    ## 6. Refresh the font cache

    After all installations:

    ```bash
    fc-cache -f -v
    ```

    The `fontconfig` package provides `fc-cache`, `fc-list` and `fc-match`. (Debian Packages)

    Log out of Plasma and log back in so all applications reload their font lists.

    ## 7. Verify the fonts

    Microsoft:

    ```bash
    fc-match Arial
    fc-match "Times New Roman"
    fc-match Carlito
    fc-match Caladea
    ```

    Google:

    ```bash
    fc-match Roboto
    fc-match "Noto Sans"
    fc-match "Noto Sans Mono"
    fc-match "Noto Color Emoji"
    fc-match Montserrat
    ```

    Apple:

    ```bash
    fc-list | grep -iE 'SF Pro|SF Compact|New York|San Francisco'
    ```

    See all installed matching fonts:

    ```bash
    fc-list | grep -iE \
      'Arial|Times New Roman|Calibri|Cambria|Carlito|Caladea|Roboto|Noto|Montserrat|SF Pro'
    ```

    A practical single-command collection for your teaching and document work is:

    ```bash
    sudo apt install \
      ttf-mscorefonts-installer \
      fonts-liberation \
      fonts-crosextra-carlito \
      fonts-crosextra-caladea \
      fonts-noto-core \
      fonts-noto-ui-core \
      fonts-noto-mono \
      fonts-noto-color-emoji \
      fonts-roboto \
      fonts-open-sans \
      fonts-montserrat \
      fonts-inter
    ```

    [1]: https://packages.debian.org/sid/fonts/ttf-mscorefonts-installer?utm_source=chatgpt.com "Details of package ttf-mscorefonts-installer in sid"

    [2]: https://manpages.debian.org/unstable/apt/sources.list.5.en.html?utm_source=chatgpt.com "sources.list(5) — apt — Debian unstable"

    [3]: https://packages.debian.org/sid/fonts/fonts-crosextra-caladea?utm_source=chatgpt.com "Debian -- Details of package fonts-crosextra-caladea in sid"

    [4]: https://packages.debian.org/unstable/fonts/?utm_source=chatgpt.com "Software Packages in "sid", Subsection fonts"

    [5]: https://packages.debian.org/sid/fonts-noto-cjk?utm_source=chatgpt.com "Debian -- Details of package fonts-noto-cjk in sid"

    [6]: https://packages.debian.org/sid/fonts-noto?utm_source=chatgpt.com "Debian -- Details of package fonts-noto in sid"

    [7]: https://developer.apple.com/fonts/system-fonts/?utm_source=chatgpt.com "System Fonts"

    [8]: https://packages.debian.org/sid/fonts-inter?utm_source=chatgpt.com "Debian -- Details of package fonts-inter in sid"

    [9]: https://packages.debian.org/sid/7zip?utm_source=chatgpt.com "Debian -- Details of package 7zip in sid"

    [10]: https://fonts.google.com/?utm_source=chatgpt.com "Google Fonts: Browse Fonts"

    [11]: https://packages.debian.org/sid/fontconfig?utm_source=chatgpt.com "Debian -- Details of package fontconfig in sid"

- Installing [R Project](https://www.r-project.org/)

    # Recommended R setup for Siduction/Debian

    These instructions assume you are installing R on your current **Siduction system**, which follows **Debian sid/unstable**.

    The most practical setup is:

    1. **R** — the statistical programming language and computation engine.

    2. **RStudio Desktop** — the user-friendly graphical interface.

    3. **Quarto** — for producing Word, HTML, PDF, presentation, and book-style reports.

    4. **TinyTeX** — needed only when producing PDF documents.

    5. Selected R packages for data analysis, visualization, teaching, and academic research.

    On Debian sid, the official Debian repositories currently provide **R 4.6.1**, so you should not add a separate CRAN repository. CRAN itself recommends using the official Debian sid packages because sid normally contains the latest stable R release. (CRAN)

    ---

    ## 1. Confirm your system architecture

    Open Konsole and run:

    ```bash
    dpkg --print-architecture
    grep -E '^(ID|VERSION|VERSION_CODENAME)=' /etc/os-release
    ```

    Your architecture will probably be:

    ```text
    amd64
    ```

    The RStudio package below is for `amd64`. R itself is also available for Debian `arm64`, but Posit’s current Linux RStudio download is listed for `amd64`. (Posit Docs)

    ---

    ## 2. Update Siduction

    Before installing R, update your packages:

    ```bash
    sudo apt update
    sudo apt full-upgrade
    ```

    Restart if the update includes a new kernel, systemd, graphics stack, or major KDE components:

    ```bash
    systemctl reboot
    ```

    ---

    ## 3. Install R

    Install the complete base R system and the development files needed to compile additional R packages:

    ```bash
    sudo apt install r-base r-base-dev
    ```

    The `r-base` package includes R and the packages recommended by the R Core Team. The `r-base-dev` package supplies the basic tools needed when an R package must be compiled from source. (CRAN)

    You can also install the local HTML documentation:

    ```bash
    sudo apt install r-base-html r-doc-html
    ```

    ### Verify the installation

    Run:

    ```bash
    R --version
    ```

    You should see output beginning with something similar to:

    ```text
    R version 4.6.1
    ```

    Then test R:

    ```bash
    R
    ```

    At the R prompt, enter:

    ```r
    2 + 2
    sessionInfo()
    ```

    Exit R with:

    ```r
    q()
    ```

    When asked whether to save the workspace, answer:

    ```text
    n
    ```

    ---

    ## 4. Install common system libraries

    On Linux, some R packages need Debian development libraries. Installing the following now prevents many common package-installation errors:

    ```bash
    sudo apt install \
      build-essential \
      gfortran \
      git \
      curl \
      wget \
      ca-certificates \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      libgit2-dev \
      libfontconfig1-dev \
      libharfbuzz-dev \
      libfribidi-dev \
      libfreetype-dev \
      libpng-dev \
      libtiff-dev \
      libjpeg-dev
    ```

    These support packages that process websites, XML, fonts, text rendering, graphics, Git repositories, and encrypted connections.

    ### Optional GIS and mapping support

    Install these only when you expect to use maps, geospatial data, or packages such as `sf`:

    ```bash
    sudo apt install \
      libgdal-dev \
      libgeos-dev \
      libproj-dev \
      libudunits2-dev
    ```

    ---

    # 5. Install RStudio Desktop

    R by itself primarily presents a terminal console. **RStudio Desktop** supplies a graphical editor, data viewer, package manager, plot viewer, help system, debugging tools, project management, and direct support for Quarto and R Markdown. (Posit)

    As of August 3, 2026, the current stable release is **RStudio 2026.07.1-147**. Posit officially lists its `.deb` package for Debian 12 and Debian 13. Siduction is based on Debian sid, so it will usually work, but sid is not one of Posit’s explicitly supported distributions. (Posit Docs)

    Download and install it:

    ```bash
    cd ~/Downloads
    wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2026.07.1-147-amd64.deb
    sudo apt install ./rstudio-2026.07.1-147-amd64.deb
    ```

    Using `apt install ./package.deb`, rather than `dpkg -i`, allows APT to resolve required dependencies automatically.

    Once installed, launch it from:

    ```text
    Application Launcher → Development → RStudio
    ```

    Or run:

    ```bash
    rstudio
    ```

    After confirming that it works, remove the installer:

    ```bash
    rm ~/Downloads/rstudio-2026.07.1-147-amd64.deb
    ```

    ---

    ## 6. Confirm that RStudio sees R

    In the RStudio Console, run:

    ```r
    R.version.string
    R.home()
    .libPaths()
    ```

    You should see an R version and an R installation directory such as:

    ```text
    /usr/lib/R
    ```

    Your user-installed packages will normally be stored somewhere under:

    ```text
    ~/R/
    ```

    Do not start RStudio using `sudo`. Packages intended for your personal account should be installed as your regular user.

    ---

    # 7. Configure RStudio for easier use

    Open:

    ```text
    Tools → Global Options
    ```

    ## General settings

    Under **General → Basic**:

    - Uncheck **Restore .RData into workspace at startup**.

    - Set **Save workspace to .RData on exit** to **Never**.

    - Leave the initial working directory at its default.

    - Use RStudio Projects instead of changing directories manually.

    Posit recommends beginning each session with a blank workspace rather than silently restoring objects from an earlier session. (Posit Docs)

    ## Code settings

    Under **Code → Editing**:

    - Enable syntax highlighting.

    - Enable automatic code completion.

    - Enable matching parentheses and brackets.

    - Enable code diagnostics.

    - Enable soft wrapping for long lines if you prefer it.

    Under **Code → Saving**:

    - Set the default text encoding to **UTF-8**.

    ## Appearance

    Under **Appearance**:

    - Increase the editor font size if needed.

    - Select a light or dark editor theme.

    - Adjust the overall interface zoom through:

    ```text
    View → Zoom In
    View → Zoom Out
    ```

    RStudio supports interface zooming, multiple editor themes, keyboard navigation, and reduced-motion settings. (Posit Docs)

    ## Pane layout

    Under **Pane Layout**, a useful arrangement is:

    - Upper left: Source

    - Lower left: Console

    - Upper right: Environment and History

    - Lower right: Files, Plots, Packages, Help, and Viewer

    RStudio organizes work into four primary panes, although their arrangement can be changed. (Posit Docs)

    ## Accessibility

    Under **Accessibility**:

    - Enable **Reduce User Interface Animations** when desired.

    - Adjust screen-reader or keyboard-navigation settings when applicable.

    ---

    # 8. Use RStudio Projects

    Create a separate project for every substantial analysis, course, study, or manuscript:

    ```text
    File → New Project → New Directory → New Project
    ```

    For example:

    ```text
    ~/Documents/R-Projects/
    ├── Academic-Writing-Research/
    ├── Discourse-Analysis-Study/
    ├── Student-Survey-Analysis/
    └── Newsletter-Analytics/
    ```

    A typical project might contain:

    ```text
    Student-Survey-Analysis/
    ├── data/
    ├── scripts/
    ├── output/
    ├── figures/
    ├── documents/
    └── Student-Survey-Analysis.Rproj
    ```

    Projects make file paths, package environments, scripts, and outputs easier to manage. RStudio’s official workflow uses **File → New Project** to establish a project-specific working environment. (Posit Docs)

    ---

    # 9. Install a friendlier R package manager

    R’s standard package installer is:

    ```r
    install.packages("package-name")
    ```

    I recommend installing `pak`, which gives clearer dependency information and generally provides a more convenient package installation workflow:

    ```r
    install.packages("pak")
    ```

    You can then install packages with:

    ```r
    pak::pkg_install("package-name")
    ```

    The official `pak` documentation also offers self-contained Linux builds and supports installing packages from CRAN, Git repositories, Bioconductor, and other sources. (R-lib)

    ---

    # 10. Install recommended R packages

    Paste the following groups into the **RStudio Console**. You do not have to install every group immediately.

    ## Essential data-analysis packages

    ```r
    pak::pkg_install(c(
      "tidyverse",
      "janitor",
      "skimr",
      "here",
      "rio"
    ))
    ```

    These provide:

    - `tidyverse`: data preparation, transformation, visualization, and importing.

    - `janitor`: cleaning variable names and creating tabulations.

    - `skimr`: readable descriptive summaries.

    - `here`: reliable project-relative file paths.

    - `rio`: straightforward importing and exporting based on file extensions.

    The `tidyverse` installs a coordinated collection that includes packages such as `dplyr`, `ggplot2`, `readr`, `readxl`, `tidyr`, `stringr`, `lubridate`, `haven`, and `reprex`. The `rio` package simplifies importing and exporting formats such as Excel, CSV, SPSS, Stata, and other common data files. (CRAN)

    ## Statistical and educational research packages

    ```r
    pak::pkg_install(c(
      "psych",
      "car",
      "effectsize",
      "performance",
      "parameters",
      "report",
      "gtsummary"
    ))
    ```

    This group is useful for:

    - Descriptive statistics

    - Reliability analysis

    - Factor analysis

    - Regression diagnostics

    - Effect sizes

    - Model summaries

    - Publication-oriented statistical tables

    ## Tables and Office-document output

    ```r
    pak::pkg_install(c(
      "gt",
      "flextable",
      "officer",
      "openxlsx",
      "writexl"
    ))
    ```

    This group is useful for producing:

    - Formatted statistical tables

    - Microsoft Word documents

    - PowerPoint content

    - Excel workbooks

    - Publication-ready output

    ## User-friendly graphical tools

    ```r
    pak::pkg_install(c(
      "esquisse",
      "DataEditR"
    ))
    ```

    `esquisse` provides a drag-and-drop interface for creating `ggplot2` visualizations and gives you the corresponding reproducible R code. `DataEditR` supplies a spreadsheet-like interface for viewing, entering, filtering, and editing data. (CRAN)

    Launch them with:

    ```r
    esquisse::esquisser()
    ```

    and:

    ```r
    DataEditR::data_edit()
    ```

    ## Reproducibility tools

    ```r
    pak::pkg_install(c(
      "renv",
      "quarto"
    ))
    ```

    The `renv` package gives each project its own package library and records exact package versions in an `renv.lock` file. This helps keep long-term studies and collaborative projects reproducible. (rstudio.github.io)

    To enable it in a project:

    ```r
    renv::init()
    ```

    After adding or updating packages:

    ```r
    renv::snapshot()
    ```

    To recreate the same environment on another computer:

    ```r
    renv::restore()
    ```

    ---

    # 11. Install PDF support with TinyTeX

    RStudio already includes a stable version of **Quarto**, so you normally do not need to install Quarto separately at the system level. Quarto can produce HTML and Microsoft Word files immediately. PDF output additionally requires a LaTeX installation. (Posit Docs)

    TinyTeX is a relatively small LaTeX distribution designed to work well with R and Quarto. It installs in your home directory and does not require administrator privileges. (Yihui Xie)

    In the RStudio Console, run:

    ```r
    install.packages("tinytex")
    tinytex::install_tinytex()
    ```

    Do **not** run RStudio as root and do not use `sudo` for this command.

    Verify it:

    ```r
    tinytex::is_tinytex()
    ```

    The result should be:

    ```r
    [1] TRUE
    ```

    Restart RStudio after installation.

    ---

    # 12. Test Quarto

    In RStudio, choose:

    ```text
    File → New File → Quarto Document
    ```

    Enter a title and select **HTML** initially. RStudio will create a `.qmd` file.

    Replace its contents with:

    ```markdown
    ---
    title: "My First R Report"
    format: html
    ---
    ## Sample analysis
    ```{r}
    library(tidyverse)
    scores <- tibble(
      group = c("Group A", "Group B", "Group C"),
      average = c(81, 87, 84)
    )
    ggplot(scores, aes(group, average)) +
      geom_col() +
      labs(
        title = "Average Scores",
        x = "Group",
        y = "Average"
      )
    ```
    ```

    Click **Render**.

    Quarto can render `.qmd` documents as HTML, Word, PDF, presentations, websites, and books. RStudio also supplies a Visual Editor for working with Quarto without manually entering all Markdown formatting. (Quarto)

    To test Word output, change:

    ```yaml
    format: html
    ```

    to:

    ```yaml
    format: docx
    ```

    For PDF:

    ```yaml
    format: pdf
    ```

    PDF output will use TinyTeX.

    ---

    # 13. Optional KDE-native alternative: RKWard

    Because you use KDE Plasma, you may also find **RKWard** useful. It is a KDE-based graphical interface for R with menus, dialogs, a spreadsheet-style data editor, statistical-analysis interfaces, an R console, package management, plots, and script editing.

    Install it with:

    ```bash
    sudo apt install rkward
    ```

    Launch it from the KDE application menu or run:

    ```bash
    rkward
    ```

    Debian sid currently provides RKWard 0.8.3, which includes compatibility updates for R 4.6. (Debian Packages)

    ### Which interface should you use?

    - **RStudio**: best general recommendation for learning R, writing scripts, creating Quarto reports, teaching, research, and reproducible analysis.

    - **RKWard**: useful when you prefer KDE integration and menu-driven statistical procedures.

    - Both can use the same system installation of R.

    You can safely install both.

    ---

    # 14. Basic package-management commands

    ## See installed packages

    ```r
    installed.packages()[, c("Package", "Version")]
    ```

    ## Install a package

    ```r
    pak::pkg_install("psych")
    ```

    ## Install several packages

    ```r
    pak::pkg_install(c("psych", "effectsize", "performance"))
    ```

    ## Remove a package

    ```r
    remove.packages("package-name")
    ```

    ## Update user-installed packages

    ```r
    update.packages(
      ask = FALSE,
      checkBuilt = TRUE
    )
    ```

    CRAN recommends `checkBuilt = TRUE` when packages may need rebuilding after a major R update. (CRAN)

    ## See package-library locations

    ```r
    .libPaths()
    ```

    ## Get package help

    ```r
    help(package = "psych")
    ```

    or:

    ```r
    ?psych::describe
    ```

    ---

    # 15. Updating the installation

    ## Update R

    Because R is installed through Debian:

    ```bash
    sudo apt update
    sudo apt full-upgrade
    ```

    ## Update R packages

    Inside RStudio:

    ```r
    update.packages(
      ask = FALSE,
      checkBuilt = TRUE
    )
    ```

    For an `renv` project, update deliberately and then record the new versions:

    ```r
    renv::update()
    renv::snapshot()
    ```

    ## Update RStudio

    RStudio’s downloaded `.deb` is not managed through a Posit APT repository. To upgrade it, download the newer `.deb` from Posit and install it over the existing version:

    ```bash
    sudo apt install ./new-rstudio-version-amd64.deb
    ```

    Your projects and RStudio preferences will remain in your home directory.

    Avoid RStudio daily builds for routine use; Posit explicitly identifies them as testing builds rather than stable releases. (Posit Docs)

    ---

    # 16. Troubleshooting

    ## An R package reports a missing header or library

    A message such as:

    ```text
    fatal error: curl/curl.h: No such file or directory
    ```

    usually means a Debian development package is missing. For that example:

    ```bash
    sudo apt install libcurl4-openssl-dev
    ```

    Other common relationships are:

    ```text
    openssl/ssl.h       → libssl-dev
    libxml/parser.h     → libxml2-dev
    fontconfig headers  → libfontconfig1-dev
    gdal.h              → libgdal-dev
    proj.h              → libproj-dev
    ```

    Then reinstall the R package.

    ## RStudio does not open

    Test it from Konsole:

    ```bash
    rstudio
    ```

    The terminal may display the actual error.

    Confirm that R exists:

    ```bash
    which R
    R RHOME
    ```

    Expected results are similar to:

    ```text
    /usr/bin/R
    /usr/lib/R
    ```

    Because RStudio’s official package targets Debian 12 and 13 rather than sid, a temporary sid library transition can occasionally make the `.deb` incompatible. Do not force removal or downgrading of core Siduction libraries. Use RKWard or the R terminal until a compatible RStudio build is available.

    ## RStudio opens with a blank or damaged interface

    Reset its local state by closing RStudio and renaming its configuration directories:

    ```bash
    mv ~/.config/rstudio ~/.config/rstudio.backup
    mv ~/.local/share/rstudio ~/.local/share/rstudio.backup
    ```

    Then reopen RStudio. Your actual R projects are unaffected.

    ## Packages are being installed into a system directory

    Check:

    ```r
    .libPaths()
    ```

    Do not install packages by running:

    ```bash
    sudo R
    ```

    When R offers to create a personal library in your home folder, answer **yes**.

    ---

    ## Recommended final configuration

    For your teaching and academic-research work, I recommend keeping:

    - **R 4.6.x** from Debian sid

    - **RStudio Desktop** as the primary interface

    - **RKWard** as an optional KDE/menu-driven interface

    - **Quarto** for reports, manuscripts, presentations, and book projects

    - **TinyTeX** for PDF production

    - `tidyverse`, `rio`, `janitor`, `skimr`, `psych`, `effectsize`, `performance`, `gtsummary`, `gt`, `flextable`, `esquisse`, `DataEditR`, `here`, and `renv` as the initial package collection

    [1]: https://cran.r-project.org/bin/linux/debian/ "Debian Packages of R Software"

    [2]: https://docs.posit.co/ide/user/ "RStudio IDE User Guide – RStudio User Guide"

    [3]: https://posit.co/downloads "Download RStudio Desktop and Server | Posit Data Science Tools"

    [4]: https://docs.posit.co/ide/user/ide/get-started/index.html?utm_source=chatgpt.com "Get Started – RStudio User Guide"

    [5]: https://docs.posit.co/ide/user/ide/guide/accessibility/accessibility.html?utm_source=chatgpt.com "Simplified Interface – RStudio User Guide"

    [6]: https://pak.r-lib.org/reference/install.html "All about installing pak. — Installing pak • pak"

    [7]: https://cran.r-project.org/package%3Drio "CRAN: Package rio"

    [8]: https://cran.r-project.org/package%3Desquisse "CRAN: Package esquisse"

    [9]: https://rstudio.github.io/renv/articles/renv.html?utm_source=chatgpt.com "Introduction to renv • renv"

    [10]: https://docs.posit.co/ide/user/ide/guide/documents/quarto-project.html?utm_source=chatgpt.com "Quarto Integration – RStudio User Guide"

    [11]: https://yihui.org/tinytex/?utm_source=chatgpt.com "TinyTeX - A lightweight, cross-platform, portable, and easy-to-maintain LaTeX distribution based on TeX Live - Yihui Xie | 谢益辉"

    [12]: https://quarto.org/docs/get-started/hello/rstudio.html "Tutorial: Hello, Quarto – Quarto"

    [13]: https://packages.debian.org/sid/rkward?utm_source=chatgpt.com "Debian -- Details of package rkward in sid"

