---
type: 'Page'
title: Installing Cosmic Desktop
aliases: null
description: null
icon: ✴️
createdAt: '2026-07-08T17:05:09.319Z'
lastUpdated: '2026-07-08T17:09:01.707Z'
tags: [Linux]
coverImage: '[Untitled](../Images/Untitled%20(52).md)'
---

# Installing Cosmic Desktop

- Bluetooth issues

    This output is useful. Your PC has a **Realtek RTL8852BE Wi-Fi/Bluetooth combo card**:

    ```text
    Bluetooth: 0bda:b85b Realtek Bluetooth Radio
    Wi-Fi:     RTL8852BE PCIe 802.11ax
    ```

    That specific Bluetooth ID, **0bda:b85b**, has had Linux driver/firmware issues. It was specifically added to the Linux Bluetooth `btusb` driver for the Realtek RTL8852BE Bluetooth part, and Realtek RTL8852B Bluetooth firmware files are maintained in `linux-firmware`, so kernel/firmware version matters here. (Patchew)

    ### 1. First, get the missing diagnostic output

    Your `dmesg` command failed because it needs sudo. Run:

    ```bash
    uname -r
    ls -l /lib/firmware/rtl_bt/rtl8852* /usr/lib/firmware/rtl_bt/rtl8852* 2>/dev/null
    sudo dmesg | grep -i -E "bluetooth|btusb|btrtl|rtl|8852|firmware|hci0|opcode" | tail -160
    ```

    That will tell us whether the Realtek Bluetooth firmware is loading correctly.

    ### 2. Update/reinstall the Bluetooth firmware and BlueZ stack

    Run:

    ```bash
    sudo apt update
    sudo apt full-upgrade
    sudo apt install --reinstall linux-firmware bluez bluez-obexd
    sudo reboot
    ```

    After reboot, try Blueman again:

    ```bash
    blueman-manager
    ```

    ### 3. Try pairing with Wi-Fi temporarily off

    Because this is a Realtek Wi-Fi/Bluetooth combo chip, test pairing with Wi-Fi disabled:

    ```bash
    nmcli radio wifi off
    sudo systemctl restart bluetooth
    blueman-manager
    ```

    Put the Bose in pairing mode and search again.

    After the test, turn Wi-Fi back on:

    ```bash
    nmcli radio wifi on
    ```

    ### 4. If it still does not discover anything

    At that point, the practical fix is likely one of these:

    1. Use a newer kernel/firmware stack.

    2. Replace the internal Realtek Wi-Fi/Bluetooth card with an Intel AX200/AX210 card, if your PC supports it.

    3. Use a small Linux-compatible USB Bluetooth adapter.

    For now, please paste the output from step 1. The key thing I want to see is whether `rtl8852bu_fw.bin`, `rtl8852btu_fw.bin`, or a related Realtek firmware file is loading correctly or failing.

    [1]: https://patchew.org/linux/20231012112118.11431-1-guanwentao%40uniontech.com/?utm_source=chatgpt.com "Bluetooth: btusb: Add 0bda:b85b for Fn-Link RTL8852BE"

- Second step

    Your diagnostics show **the Realtek Bluetooth firmware is loading correctly**:

    ```text
    Bluetooth: hci0: RTL: loading rtl_bt/rtl8852bu_fw.bin
    Bluetooth: hci0: RTL: fw version 0x42d34e04
    ```

    So this is probably **not missing firmware**. The problem looks more like the Realtek RTL8852BE combo card is scanning unreliably. The Wi-Fi driver also shows:

    ```text
    rtw89_8852be ... timed out to flush queues
    ```

    That points to the Realtek Wi-Fi/Bluetooth combo chipset acting unstable.

    Try this next.

    ### 1. Do a full power reset

    Do not just reboot.

    1. Shut down the PC completely.

    2. Unplug power.

    3. Hold the physical power button for about 20 seconds.

    4. Plug power back in.

    5. Boot again.

    6. Turn Bluetooth off on your phone so the Bose cannot reconnect there.

    7. Put the Bose in pairing mode.

    8. Try Blueman again.

    ### 2. Test with Wi-Fi fully off

    Run:

    ```bash
    nmcli radio wifi off
    sudo systemctl restart bluetooth
    blueman-manager
    ```

    Then search for the Bose.

    After testing, turn Wi-Fi back on:

    ```bash
    nmcli radio wifi on
    ```

    ### 3. Try a lower-level Bluetooth scan

    Run:

    ```bash
    sudo btmgmt power off
    sudo btmgmt bredr on
    sudo btmgmt le off
    sudo btmgmt power on
    sudo btmgmt find -b
    ```

    Put the Bose in pairing mode while `find -b` is running.

    If the Bose appears there, copy the device address and pair it with:

    ```bash
    bluetoothctl
    ```

    Then:

    ```text
    pair XX:XX:XX:XX:XX:XX
    trust XX:XX:XX:XX:XX:XX
    connect XX:XX:XX:XX:XX:XX
    ```

    ### 4. My practical recommendation

    Since your phone connects to the Bose and your PC’s Realtek adapter loads firmware but discovers nothing, I would **not spend much more time on the internal Bluetooth card**.

    The most reliable fix is either:

    - use a small Linux-compatible **USB Bluetooth adapter**, or

    - replace the internal Realtek RTL8852BE card with an **Intel AX200/AX210 Wi-Fi/Bluetooth card**, if your PC supports replaceable M.2 Wi-Fi cards.

    For now, try the **full power reset** and the **Wi-Fi off test** first. Those are the two most likely no-cost fixes.

