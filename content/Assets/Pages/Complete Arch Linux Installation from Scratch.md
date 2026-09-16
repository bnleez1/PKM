---
title: "Complete Arch Linux Installation from Scratch: UEFI, KDE Plasma, systemd-boot, and NetworkManager"
tags:
  - Linux
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/untitled
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Complete Arch Linux Installation from Scratch: UEFI, KDE Plasma, systemd-boot, and NetworkManager

This version is designed as a genuinely usable fresh installation rather than an ultra-minimal Arch base. It assumes **UEFI/GPT**, dedicates the **entire selected disk to Arch**, uses **ext4**, **systemd-boot**, **NetworkManager**, an **8 GiB swap file**, and optionally installs **KDE Plasma + SDDM + PipeWire + Firefox**. KDE is enabled by default. Current Arch documentation supports `pacstrap -K`, UUID-based `fstab`, systemd-boot, and NetworkManager in this configuration. [ArchWiki](https://wiki.archlinux.org/title/Pacstrap?utm_source=chatgpt.com)

**Important:** this script **erases the entire target disk**. It is not for Windows/Arch dual boot. If you intend to retain Windows, do not run this version.

### 1. Before running the script

Boot the Arch USB in **UEFI mode**, not legacy/CSM mode. You can confirm with:

```
ls /sys/firmware/efi/efivars
```

If that directory exists, you are in UEFI mode. Arch also recommends confirming network connectivity and enabling time synchronization before installation. [ArchWiki](https://wiki.archlinux.org/title/User%3AOliver/New_Install_Guide?utm_source=chatgpt.com)

For Ethernet, the network will usually work automatically.

For Wi-Fi, first identify the wireless interface:

```
iwctl device list
```

Then connect, replacing `wlan0` and the network name:

```
iwctl station wlan0 connect "YOUR WIFI NAME"
```

Test:

```
ping -c 3 archlinux.org
```

Then check your disks:

```
lsblk -o NAME,SIZE,MODEL,TYPE
```

You might see, for example:

```
NAME        SIZE MODEL                 TYPE
sda        28.7G SanDisk USB          disk
nvme0n1   953.9G Samsung SSD          disk
```

In this example:

```
/dev/sda       = Arch installation USB
/dev/nvme0n1   = internal SSD
```

You absolutely do not want to select the USB accidentally.

---

# 2. Complete installer script

Create the installer:

```
nano arch-install.sh
```

Paste this entire script:

```
#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# ARCH LINUX FULL-DISK INSTALLER
#
# UEFI + GPT
# ext4
# systemd-boot
# NetworkManager
# swap file
# optional KDE Plasma desktop
#
# WARNING:
# THE SELECTED DISK WILL BE COMPLETELY ERASED.
###############################################################################

# ============================================================================
# USER CONFIGURATION
# ============================================================================

# CHANGE THIS after checking `lsblk`
DISK="/dev/nvme0n1"

# Computer name
HOSTNAME="archlinux"

# Your normal user account
USERNAME="archuser"

# Locale
LOCALE="en_US.UTF-8"

# Console keyboard
KEYMAP="us"

# Time zone
TIMEZONE="America/Mexico_City"

# Swap file size in GiB
SWAP_GIB=8

# Install KDE Plasma desktop?
INSTALL_KDE=true

# Install Bluetooth support?
INSTALL_BLUETOOTH=true

# Install printing support?
INSTALL_PRINTING=true


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

info() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$1"
}

success() {
    printf '\n\033[1;32m==> %s\033[0m\n' "$1"
}

error() {
    printf '\n\033[1;31mERROR: %s\033[0m\n' "$1" >&2
    exit 1
}

partition_name() {
    local disk="$1"
    local number="$2"

    if [[ "$disk" =~ [0-9]$ ]]; then
        echo "${disk}p${number}"
    else
        echo "${disk}${number}"
    fi
}


# ============================================================================
# BASIC CHECKS
# ============================================================================

[[ $EUID -eq 0 ]] || error "Run this script as root."

[[ -d /sys/firmware/efi/efivars ]] || \
    error "The Arch ISO was not booted in UEFI mode."

[[ -b "$DISK" ]] || \
    error "$DISK is not a valid block device."

DISK_TYPE=$(lsblk -dn -o TYPE "$DISK")

[[ "$DISK_TYPE" == "disk" ]] || \
    error "$DISK does not appear to be a physical disk."

[[ -e "/usr/share/zoneinfo/$TIMEZONE" ]] || \
    error "Invalid timezone: $TIMEZONE"


# ============================================================================
# NETWORK CHECK
# ============================================================================

info "Checking Internet connection..."

if ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
    error "No Internet connection. Connect Ethernet or Wi-Fi first."
fi

success "Internet connection is working."


# ============================================================================
# TIME
# ============================================================================

info "Enabling network time synchronization..."

timedatectl set-ntp true || true


# ============================================================================
# DISPLAY DISKS
# ============================================================================

echo
echo "Detected storage devices:"
echo

lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS

echo
echo "================================================================="
echo " WARNING"
echo
echo " Everything on:"
echo
echo "     $DISK"
echo
echo " WILL BE PERMANENTLY ERASED."
echo "================================================================="
echo

read -r -p "Type exactly ERASE $DISK to continue: " CONFIRM

[[ "$CONFIRM" == "ERASE $DISK" ]] || {
    echo "Installation cancelled."
    exit 1
}


# ============================================================================
# PARTITION NAMES
# ============================================================================

ESP_PART=$(partition_name "$DISK" 1)
ROOT_PART=$(partition_name "$DISK" 2)

info "EFI partition will be: $ESP_PART"
info "Root partition will be: $ROOT_PART"


# ============================================================================
# CLEAN PREVIOUS MOUNTS
# ============================================================================

info "Unmounting existing filesystems on target disk..."

while read -r dev; do
    swapoff "$dev" 2>/dev/null || true
    umount "$dev" 2>/dev/null || true
done < <(
    lsblk -lnpo NAME,TYPE "$DISK" |
    awk '$2 == "part" {print $1}'
)

umount -R /mnt 2>/dev/null || true


# ============================================================================
# ERASE PARTITION TABLE
# ============================================================================

info "Erasing old partition signatures..."

wipefs --all --force "$DISK"

sfdisk --delete "$DISK" 2>/dev/null || true


# ============================================================================
# CREATE GPT PARTITIONS
# ============================================================================

info "Creating GPT partition table..."

sfdisk "$DISK" <<EOF
label: gpt
size=1G, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="EFI System"
type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="Arch Linux"
EOF

partprobe "$DISK"
udevadm settle

sleep 2


# ============================================================================
# FORMAT
# ============================================================================

info "Formatting EFI partition as FAT32..."

mkfs.fat -F 32 -n EFI "$ESP_PART"

info "Formatting root partition as ext4..."

mkfs.ext4 -F -L ArchRoot "$ROOT_PART"


# ============================================================================
# MOUNT
# ============================================================================

info "Mounting root filesystem..."

mount "$ROOT_PART" /mnt

mkdir -p /mnt/boot

info "Mounting EFI System Partition at /boot..."

mount "$ESP_PART" /mnt/boot


# ============================================================================
# CPU MICROCODE
# ============================================================================

MICROCODE=""

if grep -q "GenuineIntel" /proc/cpuinfo; then
    MICROCODE="intel-ucode"
    info "Intel CPU detected."
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    MICROCODE="amd-ucode"
    info "AMD CPU detected."
else
    info "CPU manufacturer not recognized; skipping microcode package."
fi


# ============================================================================
# PACKAGE LIST
# ============================================================================

PACKAGES=(
    base
    linux
    linux-firmware
    base-devel
    sudo
    networkmanager
    git
    nano
    vim
    man-db
    man-pages
    texinfo
    dosfstools
    efibootmgr
)

if [[ -n "$MICROCODE" ]]; then
    PACKAGES+=("$MICROCODE")
fi


# ============================================================================
# KDE PLASMA
# ============================================================================

if [[ "$INSTALL_KDE" == true ]]; then

    info "KDE Plasma installation enabled."

    PACKAGES+=(
        plasma-meta
        sddm
        konsole
        dolphin
        firefox
        pipewire
        pipewire-alsa
        pipewire-pulse
        wireplumber
        mesa
        noto-fonts
        noto-fonts-emoji
    )

fi


# ============================================================================
# BLUETOOTH
# ============================================================================

if [[ "$INSTALL_BLUETOOTH" == true ]]; then

    PACKAGES+=(
        bluez
        bluez-utils
    )

fi


# ============================================================================
# PRINTING
# ============================================================================

if [[ "$INSTALL_PRINTING" == true ]]; then

    PACKAGES+=(
        cups
        cups-pdf
    )

fi


# ============================================================================
# INSTALL BASE SYSTEM
# ============================================================================

info "Installing Arch Linux packages..."

pacstrap -K /mnt "${PACKAGES[@]}"


# ============================================================================
# CREATE SWAP FILE
# ============================================================================

if (( SWAP_GIB > 0 )); then

    info "Creating ${SWAP_GIB} GiB swap file..."

    mkswap \
        -U clear \
        --size "${SWAP_GIB}G" \
        --file /mnt/swapfile

fi


# ============================================================================
# FSTAB
# ============================================================================

info "Generating /etc/fstab..."

genfstab -U /mnt > /mnt/etc/fstab

if (( SWAP_GIB > 0 )); then
    echo '/swapfile none swap defaults 0 0' >> /mnt/etc/fstab
fi

echo
echo "Generated fstab:"
echo
cat /mnt/etc/fstab


# ============================================================================
# TIMEZONE
# ============================================================================

info "Configuring timezone: $TIMEZONE"

ln -sf \
    "/usr/share/zoneinfo/$TIMEZONE" \
    /mnt/etc/localtime

arch-chroot /mnt hwclock --systohc


# ============================================================================
# LOCALE
# ============================================================================

info "Configuring locale: $LOCALE"

sed -i \
    "s/^#${LOCALE} UTF-8/${LOCALE} UTF-8/" \
    /mnt/etc/locale.gen

if ! grep -Fqx "${LOCALE} UTF-8" /mnt/etc/locale.gen; then
    echo "${LOCALE} UTF-8" >> /mnt/etc/locale.gen
fi

arch-chroot /mnt locale-gen

echo "LANG=$LOCALE" > /mnt/etc/locale.conf


# ============================================================================
# CONSOLE KEYBOARD
# ============================================================================

echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf


# ============================================================================
# HOSTNAME
# ============================================================================

info "Setting hostname to: $HOSTNAME"

echo "$HOSTNAME" > /mnt/etc/hostname

cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF


# ============================================================================
# INITRAMFS
# ============================================================================

info "Generating initramfs..."

arch-chroot /mnt mkinitcpio -P


# ============================================================================
# USER
# ============================================================================

info "Creating user: $USERNAME"

arch-chroot /mnt \
    useradd \
    -m \
    -G wheel \
    -s /bin/bash \
    "$USERNAME"


# ============================================================================
# PASSWORDS
# ============================================================================

echo
echo "Set the ROOT password:"
echo

arch-chroot /mnt passwd root

echo
echo "Set the password for $USERNAME:"
echo

arch-chroot /mnt passwd "$USERNAME"


# ============================================================================
# SUDO
# ============================================================================

info "Configuring sudo..."

mkdir -p /mnt/etc/sudoers.d

echo '%wheel ALL=(ALL:ALL) ALL' \
    > /mnt/etc/sudoers.d/10-wheel

chmod 440 /mnt/etc/sudoers.d/10-wheel

arch-chroot /mnt visudo -cf /etc/sudoers


# ============================================================================
# NETWORKMANAGER
# ============================================================================

info "Enabling NetworkManager..."

arch-chroot /mnt \
    systemctl enable NetworkManager.service


# ============================================================================
# TIME SYNCHRONIZATION
# ============================================================================

arch-chroot /mnt \
    systemctl enable systemd-timesyncd.service


# ============================================================================
# BLUETOOTH
# ============================================================================

if [[ "$INSTALL_BLUETOOTH" == true ]]; then

    info "Enabling Bluetooth..."

    arch-chroot /mnt \
        systemctl enable bluetooth.service

fi


# ============================================================================
# PRINTING
# ============================================================================

if [[ "$INSTALL_PRINTING" == true ]]; then

    info "Enabling CUPS printing..."

    arch-chroot /mnt \
        systemctl enable cups.service

fi


# ============================================================================
# KDE / SDDM
# ============================================================================

if [[ "$INSTALL_KDE" == true ]]; then

    info "Enabling SDDM graphical login..."

    arch-chroot /mnt \
        systemctl enable sddm.service

fi


# ============================================================================
# SYSTEMD-BOOT
# ============================================================================

info "Installing systemd-boot..."

bootctl \
    --esp-path=/mnt/boot \
    install


# ============================================================================
# ROOT UUID
# ============================================================================

ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")

[[ -n "$ROOT_UUID" ]] || \
    error "Unable to determine root filesystem UUID."


# ============================================================================
# SYSTEMD-BOOT LOADER CONFIGURATION
# ============================================================================

mkdir -p /mnt/boot/loader/entries

cat > /mnt/boot/loader/loader.conf <<EOF
default arch.conf
timeout 4
console-mode max
editor no
EOF


# ============================================================================
# ARCH BOOT ENTRY
# ============================================================================

cat > /mnt/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw
EOF


# ============================================================================
# FALLBACK BOOT ENTRY
# ============================================================================

cat > /mnt/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=UUID=${ROOT_UUID} rw
EOF


# ============================================================================
# VERIFY BOOT FILES
# ============================================================================

info "Checking EFI boot installation..."

bootctl \
    --esp-path=/mnt/boot \
    status || true

echo
echo "Boot entries:"
echo

cat /mnt/boot/loader/entries/arch.conf

echo


# ============================================================================
# FINAL PACKAGE DATABASE UPDATE
# ============================================================================

info "Refreshing package database inside installed system..."

arch-chroot /mnt pacman -Syy


# ============================================================================
# FINISH
# ============================================================================

sync

echo
echo "================================================================="
echo
echo " ARCH LINUX INSTALLATION COMPLETE"
echo
echo "================================================================="
echo
echo
echo "Disk:          $DISK"
echo "EFI:           $ESP_PART"
echo "Root:          $ROOT_PART"
echo "Hostname:      $HOSTNAME"
echo "User:          $USERNAME"
echo "Timezone:      $TIMEZONE"
echo "Locale:        $LOCALE"
echo "Swap:          ${SWAP_GIB} GiB"
echo "KDE Plasma:    $INSTALL_KDE"
echo "Bluetooth:     $INSTALL_BLUETOOTH"
echo "Printing:      $INSTALL_PRINTING"
echo
echo "DO NOT run the script again."
echo
echo "Next:"
echo
echo "    umount -R /mnt"
echo "    reboot"
echo
echo "Remove the Arch USB drive during reboot."
echo
echo "================================================================="
```

### 3. Edit these values first

At the very top, pay particular attention to:

```
DISK="/dev/nvme0n1"
HOSTNAME="archlinux"
USERNAME="archuser"
TIMEZONE="America/Mexico_City"
SWAP_GIB=8
INSTALL_KDE=true
```

For example, if you want your username to be `ben`:

```
USERNAME="ben"
```

If the internal disk appears as `/dev/sda` rather than NVMe:

```
DISK="/dev/sda"
```

**Do not guess the disk name. Run `lsblk` first.**

The timezone shown above is a valid Arch timezone for central Mexico. The installer generates `en_US.UTF-8` according to the standard Arch locale procedure. [ArchWiki](https://wiki.archlinux.org/title/Locale?utm_source=chatgpt.com)

### 4. Run it

Save in nano with `Ctrl+O`, Enter, then `Ctrl+X`.

Make it executable:

```
chmod +x arch-install.sh
```

Then:

```
./arch-install.sh
```

The script deliberately requires you to enter something such as:

```
ERASE /dev/nvme0n1
```

before partitioning begins.

It will later stop twice so you can securely enter the root password and your normal user's password.

### 5. When it finishes

Run:

```
umount -R /mnt
```

Then:

```
reboot
```

Remove the Arch USB.

If everything has gone correctly, **systemd-boot → Arch Linux → SDDM → KDE Plasma** should appear. Arch currently recommends `plasma-meta` as one of the standard ways to install Plasma, and enabling `sddm.service` provides graphical login. [ArchWiki](https://wiki.archlinux.org/title/KDE?utm_source=chatgpt.com)

NetworkManager is enabled, so both Ethernet and Wi-Fi can be managed normally once you reach Plasma. The current Arch NetworkManager package includes `wpa_supplicant`, so an additional Wi-Fi daemon does not need to be manually enabled. [Arch Linux](https://archlinux.org/packages/extra/x86_64/networkmanager/?utm_source=chatgpt.com)

The script also installs the appropriate Intel or AMD microcode package. Current Arch guidance recommends these updates for both Intel and AMD processors, and modern `mkinitcpio` can incorporate microcode into the generated initramfs. [ArchWiki](https://wiki.archlinux.org/title/Microcode?utm_source=chatgpt.com)

One change I would make **before you actually run this on your machine** is tailor the installation to your hardware—particularly **NVIDIA vs AMD/Intel graphics, laptop vs desktop, SSD/NVMe layout, and whether Windows should be preserved**. If this is going onto one of your existing Windows/Nobara computers, I would use a hardware-specific version rather than blindly running the generic full-disk installer above.