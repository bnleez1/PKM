---
type: 'Page'
title: Installing Mullvad VPN
aliases: null
description: null
icon: null
createdAt: '2026-07-24T00:12:24.830Z'
lastUpdated: '2026-07-24T00:17:56.144Z'
tags: []
coverImage: null
---

# Installing Mullvad VPN

Assuming you mean **Mullvad VPN**: CachyOS is Arch-based, and Mullvad is available in Arch’s official repositories—no AUR package or downloaded `.deb` is needed. [Mullvad’s Linux guide](https://mullvad.net/en/help/install-mullvad-app-linux) confirms this.

1. Update CachyOS and install Mullvad:

```bash
sudo pacman -Syu mullvad-vpn
```

1. Enable and start its background service:

```bash
sudo systemctl enable --now mullvad-daemon.service
```

1. Open **Mullvad VPN** from your application menu, enter your Mullvad account number, choose a location, and connect.

Alternatively, use the terminal:

```bash
mullvad account login YOUR_ACCOUNT_NUMBER
mullvad connect
mullvad status
```

Enable automatic connection at startup:

```bash
mullvad auto-connect set on
```

If the GUI remains stuck on “Connecting to Mullvad system service,” check:

```bash
systemctl status mullvad-daemon.service
```

You can verify that the VPN and DNS protection are working at [Mullvad Connection Check](https://mullvad.net/check). The package itself is listed in the [official Arch repository](https://archlinux.org/packages/extra/x86_64/mullvad-vpn/), although Mullvad notes that Arch-based distributions aren’t officially supported by its own support team.

## Autostart (CachyOS)

Only if you enable auto-connect.

The service command starts Mullvad in the background after reboot:

```bash
sudo systemctl enable --now mullvad-daemon.service
```

But to have it actually connect automatically, run once after signing in:

```bash
mullvad auto-connect set on
```

Check it with:

```bash
mullvad auto-connect get
```

For maximum protection before it reconnects, enable Lockdown Mode too:

```bash
mullvad lockdown-mode set on
```

That blocks internet traffic until Mullvad is connected.

