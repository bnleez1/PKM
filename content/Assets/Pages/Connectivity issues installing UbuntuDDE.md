---
type: Page
collections: Public Pages
title: Connectivity issues installing UbuntuDDE
aliases:
description:
icon:
createdAt: 2025-03-15T21:58:05.319Z
lastUpdated: 2026-06-28T12:57:30.828Z
tags:
  - Linux
  - Ubuntu
coverImage:
---

# Connectivity issues installing UbuntuDDE

If your wired connection is not being detected while installing UbuntuDDE, here are some troubleshooting steps you can try:

1. Check the Network Cable & Port

Ensure the Ethernet cable is properly plugged into your computer and router/modem.

Try a different port on the router or switch.

Use a different Ethernet cable if possible.

2. Restart Network Services

Once you're in the live session (if using a live USB/DVD), open a terminal (Ctrl + Alt + T) and try restarting the network services:

sudo systemctl restart NetworkManager

3. Check Network Interfaces

Run the following command to see if your Ethernet interface is detected:

ip link show

or

nmcli device status

If you see something like eth0 or enpXsY but it's marked as DOWN, bring it up:

sudo ip link set eth0 up

(Replace eth0 with the actual interface name shown in ip link show)

4. Check Network Drivers

Run:

lspci -nnk | grep -iA3 net

or

sudo dmesg | grep -i ethernet

This will show if the correct drivers are being loaded. If no driver is listed, you may need to manually install or update it.

5. Install Missing Network Drivers

If your Ethernet adapter requires proprietary drivers, you might need to install them. Try:

sudo apt update && sudo apt install linux-firmware

For Realtek adapters, install:

sudo apt install r8168-dkms

For Intel adapters, install:

sudo apt install intel-microcode

6. Disable and Re-enable Network Interface

Try disabling and enabling your network interface:

sudo ifconfig eth0 down
sudo ifconfig eth0 up

(Replace eth0 with your actual interface name)

7. Enable Wired Connection in Network Manager

If you're using the graphical interface:

Go to Settings > Network

Click on the wired connection and toggle it ON

8. Boot with an Older Kernel (If Applicable)

If the issue started after a kernel update, try booting with an older kernel:

Reboot and hold Shift to access GRUB

Select Advanced Options

Choose an older kernel and boot

9. Manually Assign an IP Address

If DHCP is not working, manually set an IP:

sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0
sudo route add default gw 192.168.1.1 eth0

(Modify IP and gateway based on your network settings)

10. Check BIOS/UEFI Settings

Some BIOS versions have an option to disable onboard LAN. Ensure it's enabled.

Disable Secure Boot if necessary.

11. Try a Different Live USB or Distro

If none of the above works, try booting another Linux distro (Ubuntu, Fedora, etc.) from a Live USB and see if the Ethernet works. This can help determine if it’s a hardware or software issue.

If none of these solutions work, let me know what network card you have (lspci -nnk | grep -iA3 net output) so we can troubleshoot further!
