---
type: Page
collections: Public Pages
title: Firefox install
aliases:
description:
icon:
createdAt: 2025-03-26T12:58:24.863Z
lastUpdated: 2026-06-28T12:57:40.883Z
tags: []
coverImage: "[Untitled](../Images/Untitled%20(132).md)"
---

# Firefox install

[filips/FirefoxPWA - Packages · packagecloud](https://packagecloud.io/filips/FirefoxPWA)[filips/FirefoxPWA - Packages · packagecloud - Notes](../Weblinks/filipsFirefoxPWA%20-%20Packages%20%C2%B7%20packagecloud.md)

```text
# Install required packages for third-party repositories
sudo apt update
sudo apt install debian-archive-keyring # Debian-only
sudo apt install curl gpg apt-transport-https

# Import GPG key and enable the repository
curl -fsSL https://packagecloud.io/filips/FirefoxPWA/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/firefoxpwa-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/firefoxpwa-keyring.gpg] https://packagecloud.io/filips/FirefoxPWA/any any main" | sudo tee /etc/apt/sources.list.d/firefoxpwa.list > /dev/null

# Refresh repositories and install the package
sudo apt update
sudo apt install firefoxpwa
```
