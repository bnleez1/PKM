---
title: Fedora GNOME - Stable MT7902 Wi-Fi Setup
type: note
created: 2026-09-18
status: reference
tags:
  - fedora
  - linux
  - wifi
  - mediatek
  - mt7902
  - networkmanager
banner: https://wallpapers.com/images/hd/nature-computer-wind-river-range-0wgltpv3bqyk67kf.jpg
---
# Fedora GNOME - Stable MT7902 Wi-Fi Setup

This note documents the Wi-Fi configuration that produced the most stable results on the Fedora GNOME installation using the **MediaTek MT7902 / Filogic 310** wireless adapter.

## Working hardware and software

- **Wi-Fi adapter:** MediaTek MT7902 802.11ax PCIe Wireless Network Adapter
- **PCI ID:** `14c3:7902`
- **Driver:** `mt7921e`
- **Fedora kernel tested:** `7.2.5-200.fc44.x86_64`
- **Interface:** `wlo1`
- **Home SSID:** `Benz Wifi2`
- **Preferred 5 GHz BSSID:** `BC:07:1D:39:BF:D7`
- **Frequency:** `5200 MHz`
- **Channel:** `40`

The stable configuration required three main changes:

1. Disable PCIe ASPM for `mt7921e`.
2. Disable Wi-Fi power saving.
3. Pin the main Wi-Fi profile to the stable 5 GHz BSSID to prevent roaming between mesh access points.

---

## 1. Confirm that Fedora detects the MT7902

```bash
uname -r

lspci -nnk -d 14c3:7902

nmcli device status
```

Expected driver information:

```text
Kernel driver in use: mt7921e
Kernel modules: mt7921e
```

The Wi-Fi interface should appear as `wlo1`.

---

## 2. Disable PCIe ASPM for the MT7902

Create the module configuration:

```bash
echo 'options mt7921e disable_aspm=1' | sudo tee /etc/modprobe.d/mt7921e.conf
```

Rebuild the Fedora initramfs:

```bash
sudo dracut -f
```

Reboot:

```bash
sudo reboot
```

After reboot, verify:

```bash
cat /sys/module/mt7921e/parameters/disable_aspm
```

Expected result:

```text
Y
```

If it returns `N`, the workaround is not active.

---

## 3. Connect normally to the Wi-Fi network

Connect to:

```text
Benz Wifi2
```

Then verify:

```bash
nmcli device status
```

The Wi-Fi interface should show:

```text
wlo1   wifi   connected
```

---

## 4. Disable Wi-Fi power saving

Disable power saving for the NetworkManager profile:

```bash
nmcli connection modify "Benz Wifi2"   802-11-wireless.powersave 2
```

Reconnect:

```bash
nmcli connection down "Benz Wifi2"
sleep 3
nmcli connection up "Benz Wifi2"
```

Verify the NetworkManager setting:

```bash
nmcli -g 802-11-wireless.powersave connection show "Benz Wifi2"
```

Expected result:

```text
disable
```

Also verify the kernel interface setting:

```bash
iw dev wlo1 get power_save
```

Expected result:

```text
Power save: off
```

---

## 5. Create a dedicated stable Wi-Fi profile

The automatic profile roamed repeatedly between mesh access points. A dedicated pinned profile eliminated that behavior.

Clone the existing profile:

```bash
nmcli connection clone "Benz Wifi2" "Benz Wifi2 Stable"
```

Configure the stable profile:

```bash
nmcli connection modify "Benz Wifi2 Stable"   802-11-wireless.bssid BC:07:1D:39:BF:D7   802-11-wireless.powersave 2   802-11-wireless.cloned-mac-address permanent   connection.autoconnect yes   connection.autoconnect-priority 20
```

Switch to the stable profile:

```bash
nmcli connection down "Benz Wifi2"
sleep 3
nmcli connection up "Benz Wifi2 Stable" ifname wlo1
```

Verify the connected access point:

```bash
nmcli -f IN-USE,BSSID,SSID,FREQ,CHAN,SIGNAL device wifi list ifname wlo1 | grep '^\*'
```

Expected values:

```text
BSSID: BC:07:1D:39:BF:D7
SSID: Benz Wifi2
Frequency: 5200 MHz
Channel: 40
```

---

## 6. Keep the original profile as a fallback

Set the original profile to a lower autoconnect priority:

```bash
nmcli connection modify "Benz Wifi2"   connection.autoconnect yes   connection.autoconnect-priority 0
```

Keep the stable profile at priority `20`:

```bash
nmcli connection modify "Benz Wifi2 Stable"   connection.autoconnect yes   connection.autoconnect-priority 20
```

Verify:

```bash
nmcli -f NAME,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show | grep "Benz Wifi2"
```

The preferred profile should be:

```text
Benz Wifi2 Stable
```

---

## 7. Final verification

Confirm ASPM workaround:

```bash
cat /sys/module/mt7921e/parameters/disable_aspm
```

Expected:

```text
Y
```

Confirm power saving:

```bash
iw dev wlo1 get power_save
```

Expected:

```text
Power save: off
```

Confirm current BSSID:

```bash
nmcli -f IN-USE,BSSID,SSID,FREQ,CHAN,SIGNAL device wifi list ifname wlo1 | grep '^\*'
```

Expected:

```text
BC:07:1D:39:BF:D7
5200 MHz
Channel 40
```

Test the local connection:

```bash
ping -I wlo1 -c 100 192.168.68.1
```

The successful final test produced:

```text
100 packets transmitted, 100 received, 0% packet loss
rtt min/avg/max/mdev = 1.794/10.556/156.712/26.672 ms
```

---

## Why this configuration was chosen

With default Fedora settings, the MT7902 showed severe packet loss and very high latency.

Disabling ASPM substantially improved reliability.

Disabling Wi-Fi power saving further reduced latency.

The remaining instability came from the adapter roaming repeatedly between several mesh access points sharing the same SSID. Kernel logs showed repeated reassociation between BSSIDs and at least one 4-way handshake timeout.

Pinning the dedicated profile to:

```text
BC:07:1D:39:BF:D7
```

stopped the roaming and produced the best stable Fedora result:

```text
100/100 packets received
0% packet loss
```

---

## Do not force the 2.4 GHz BSSIDs on this Fedora installation

Several 2.4 GHz BSSIDs were visible, but Fedora repeatedly timed out when authentication was forced to them.

Examples tested included:

```text
98:03:8E:58:D4:5A
BC:07:1D:39:BF:D6
BC:07:1D:39:BF:3A
```

For this Fedora installation, the pinned 5 GHz profile was more reliable.

---

## Quick rebuild checklist after reinstalling Fedora

```bash
# 1. Confirm MT7902 driver
lspci -nnk -d 14c3:7902

# 2. Disable ASPM
echo 'options mt7921e disable_aspm=1' | sudo tee /etc/modprobe.d/mt7921e.conf
sudo dracut -f
sudo reboot
```

After reboot:

```bash
# 3. Verify ASPM workaround
cat /sys/module/mt7921e/parameters/disable_aspm

# 4. Connect to Benz Wifi2 normally, then disable power saving
nmcli connection modify "Benz Wifi2"   802-11-wireless.powersave 2

# 5. Create stable pinned profile
nmcli connection clone "Benz Wifi2" "Benz Wifi2 Stable"

nmcli connection modify "Benz Wifi2 Stable"   802-11-wireless.bssid BC:07:1D:39:BF:D7   802-11-wireless.powersave 2   802-11-wireless.cloned-mac-address permanent   connection.autoconnect yes   connection.autoconnect-priority 20

# 6. Lower priority of fallback profile
nmcli connection modify "Benz Wifi2"   connection.autoconnect yes   connection.autoconnect-priority 0

# 7. Activate stable profile
nmcli connection up "Benz Wifi2 Stable" ifname wlo1

# 8. Verify
iw dev wlo1 get power_save

nmcli -f IN-USE,BSSID,SSID,FREQ,CHAN,SIGNAL device wifi list ifname wlo1 | grep '^\*'

ping -I wlo1 -c 100 192.168.68.1
```

## Expected final state

```text
Driver: mt7921e
disable_aspm: Y
Wi-Fi power save: off
Profile: Benz Wifi2 Stable
BSSID: BC:07:1D:39:BF:D7
Band: 5 GHz
Frequency: 5200 MHz
Channel: 40
MAC behavior: permanent
Autoconnect priority: 20
Fallback profile priority: 0
```
