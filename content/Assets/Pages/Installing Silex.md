---
type: 'Page'
title: Installing Silex
aliases: null
description: null
icon: null
createdAt: '2026-08-31T12:25:52.767Z'
lastUpdated: '2026-08-31T15:42:30.816Z'
tags: [Website]
coverImage: null
---

# Installing Silex

- Setting up pCloud

    **In your installed Silex 3.9.0, set the destination using** `SILEX_HOSTING_PATH` **when launching the app.** The “File system hosting” dialog does not provide a folder selector. [Silex configuration](https://github.com/silexlabs/Silex/blob/v3.9.0/server-rust/src/config.rs)

    **Your pCloud** `Website` **folder already contains a website. Back it up before publishing—Silex will overwrite files with matching names, including** `index.html`**.** I haven’t changed anything.

    1. **Close Silex completely**, and make sure pCloud Drive is running.

    2. Open a terminal and run:

        ```bash
        env SILEX_HOSTING_PATH="/home/ben/pCloudDrive/Public Folder/Website" /usr/bin/silex-desktop
        ```

    3. Open your project and click **Publish**.

    4. Click **Open published folder**. It should now open:

        ```text
        /home/ben/pCloudDrive/Public Folder/Website
        ```

    Silex writes the website directly into that folder; pCloud handles uploading it. Your editable Silex project stays in its existing location. [Publishing implementation](https://github.com/silexlabs/Silex/blob/v3.9.0/server-rust/src/connectors/fs_hosting.rs)

    To make this work when opening Silex from your application menu, create a personal copy of its launcher:

    ```bash
    cp -n /usr/share/applications/Silex.desktop /home/ben/.local/share/applications/Silex.desktop
    ```

    Open that copied file in a text editor and replace:

    ```text
    Exec=silex-desktop
    ```

    with:

    ```text
    Exec=env "SILEX_HOSTING_PATH=/home/ben/pCloudDrive/Public Folder/Website" /usr/bin/silex-desktop
    ```

    Save it, then launch Silex from the menu.

    **This destination applies to every project published from that configured app.** Publishing another Silex project could overwrite the same website.

    Once pCloud finishes uploading, get the **direct link** to `Website` from the Public Folder section of [my.pcloud.com](https://my.pcloud.com). That is the address to share with learners; the `/home/ben/…` path works only on your computer. [pCloud instructions](https://help.pcloud.com/article/public-folder)

- Syncing Silex between PCs (Nobara)

    Use **pCloud Sync to synchronize Silex’s editable projects between the two PCs**, while keeping your published website in `Public Folder/Website`.

    pCloud Sync keeps local copies and transfers changes in both directions. This lets you edit locally on either computer. [pCloud’s explanation](https://help.pcloud.com/article/pcloud-drive-vs-pcloud-sync)

    1. **Prepare the Office PC first.**

        Close Silex and make a backup copy of this entire folder somewhere outside the folder being synchronized:

        ```text
        /home/ben/.local/share/org.silex.desktop/websites
        ```

        This contains your editable websites, pages, and templates. **Synchronize only** `websites`**, not the entire** `org.silex.desktop` **folder.**

        In Dolphin, press **Ctrl+L** and paste the path to open this hidden location.

    2. **Connect the Office projects to pCloud.**

        Create a private folder in your pCloud account named:

        ```text
        Silex Projects
        ```

        Keep it **outside Public Folder** so your editable projects are not public.

        Open **pCloud → Preferences → Sync → Add new sync** and select:

        | Setting       | Folder                                              |
        | :------------ | :-------------------------------------------------- |
        | Local folder  | `/home/ben/.local/share/org.silex.desktop/websites` |
        | pCloud folder | `Silex Projects`                                    |

        Wait until pCloud finishes uploading before proceeding.

    3. **Install matching software on the Home PC.**

        Install pCloud and sign in to **the same pCloud account**.

        Install the same Silex version as Office. Your current installation is **Silex 3.9.0**. You can check either computer with:

        ```bash
        rpm -q silex
        ```

        Open Silex once, then close it before setting up synchronization.

    4. **Connect the Home project folder to the same cloud folder.**

        On Home, the local folder should be:

        ```text
        /home/YOUR-HOME-USERNAME/.local/share/org.silex.desktop/websites
        ```

        If it already contains projects, **move those projects to a separate backup folder first**, leaving an empty `websites` folder. Do this before adding the sync connection.

        In **pCloud → Preferences → Sync → Add new sync**, connect that empty local folder to the existing **Silex Projects** cloud folder. pCloud documents this approach for Linux. [Linux sync instructions](https://help.pcloud.com/article/offline-access)

        Wait for the download to finish, then open Silex. Your Office websites and templates should appear automatically—no separate template import is needed.

    5. **Copy your publishing launcher to Home.**

        Your Office Silex launcher contains the setting that publishes to pCloud. Copy this file to the **same relative location on Home**:

        ```text
        ~/.local/share/applications/Silex.desktop
        ```

        Its publishing line currently reads:

        ```text
        Exec=env "SILEX_HOSTING_PATH=/home/ben/pCloudDrive/Public Folder/Website" /usr/bin/silex-desktop
        ```

        If your Home username is different, replace `/home/ben` with the actual Home directory. Also confirm that pCloud mounts at that location.

        Start Silex using this application-menu launcher, with pCloud running. This launcher is separate from the synchronized projects, so it needs to be configured on each PC.

    6. **Follow this routine whenever you switch PCs.**

        - Finish editing and close Silex on the first PC.

        - Wait for pCloud to finish syncing before shutting down.

        - On the other PC, wait for pCloud to finish downloading changes.

        - Then open Silex and continue working.

        **Keep Silex open on only one PC at a time.** Treat this as transferring your work between computers, rather than simultaneous editing.

    Your edits and templates synchronize **without clicking Publish**. Click **Publish** only when you want to update the public website. Keep occasional separate backups, since synchronization also carries deletions and mistakes to the other PC.

