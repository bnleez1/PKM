---
type: Page
collections: Public Pages
title: Forticlient install
aliases:
description:
icon:
createdAt: 2025-02-02T14:26:37.094Z
lastUpdated: 2026-06-28T12:57:02.039Z
tags:
  - Ubuntu
coverImage: "[Untitled](../Images/Untitled%20(385).md)"
---

# Forticlient install

# Ubuntu 24.04

- Download FortiClient VPN-Only from [https://www.fortinet.com/support/product-downloads](https://www.fortinet.com/support/product-downloads).

- Update system: 

```text
sudo apt update && sudo apt upgrade
```

- **Install necessary dependencies**: FortiClient requires some additional packages. Install them using:

```text
sudo apt install libappindicator1 libayatana-appindicator1
```

Install FortiClient

```text
cd ~/Downloads
sudo dpkg -i forticlient_vpn_*_amd64.deb
```

Fix any dependency issues

```text
sudo apt --fix-broken install
```

Launch FortiClient

```text
forticlient
```

# Fedora

To install FortiClient on Fedora via the terminal, follow these steps:

1. **Add the Fortinet repository**: Open your terminal and add the Fortinet repository using the following command:

```bash
sudo dnf config-manager --add-repo https://repo.fortinet.com/repo/forticlient/7.4/centos/8/os/x86_64/fortinet.repo
```

1. **Install FortiClient**: Once the repository is added, install FortiClient with:

```bash
sudo dnf install forticlient
```

1. **Launch FortiClient**: After installation, you can launch FortiClient from the application menu or by running:

```bash
forticlient
```

These steps should help you get FortiClient up and running on your Fedora system[[1]](https://www.fortinet.com/support/product-downloads/linux)[[2]](https://community.fortinet.com/t5/FortiClient/Technical-Tip-How-to-install-and-configure-SSL-VPN-client-in/ta-p/196863). If you encounter any issues or need further assistance, feel free to ask!

References

[1] [FortiClient Linux Product Downloads Information](https://www.fortinet.com/support/product-downloads/linux)

[2] [Technical Tip: How to install and configure SSL VP ... - Fortinet Community](https://community.fortinet.com/t5/FortiClient/Technical-Tip-How-to-install-and-configure-SSL-VPN-client-in/ta-p/196863)
