---
title: Preserve Open Apps and Workspaces Across Power Cycles
tags:
  - Linux
  - Linux_Mint
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/saving-workspaces-and-open-windows-when-rebooting-linux-mint
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Linux Mint: Preserve Open Apps and Workspaces Across Power Cycles

## Purpose

This guide explains how to configure **Linux Mint Cinnamon** so that open applications, windows, and workspaces can survive a complete power-off/power-on cycle.

The reliable method is **hibernation**, not a normal reboot.

With hibernation:

- RAM is written to swap.
- The computer powers completely off.
- On the next power-on, Linux restores the saved RAM image.
- Cinnamon returns with the same applications, windows, and workspaces.

A normal reboot starts a new kernel and user session, so it cannot preserve arbitrary running processes in exactly the same state.

---

# Important Scope and Safety Notes

This guide is intended primarily for:

- Linux Mint 22.x
- Cinnamon desktop
- an `ext4` root filesystem
- a swapfile located at `/swapfile`
- systems booting with GRUB

Do **not** blindly copy commands from this guide onto a system using:

- Btrfs root
- LUKS/full-disk encryption with a custom resume setup
- LVM swap
- a dedicated swap partition
- another bootloader
- another Linux distribution

Those configurations may require different hibernation procedures.

Before making changes:

1. Save all open work.
2. Make sure you have a current backup of important files.
3. Confirm your current swap and filesystem layout.
4. Do not reuse UUIDs or resume offsets copied from another computer.

Every machine must use its **own filesystem UUID and swapfile resume offset**.

---

# 1. Inspect the System

Start by collecting system information.

```
echo "===== HOST ====="
hostname

echo
echo "===== MEMORY ====="
free -h

echo
echo "===== ACTIVE SWAP ====="
swapon --show

echo
echo "===== ROOT FILESYSTEM ====="
findmnt /

echo
echo "===== BLOCK DEVICES ====="
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

echo
echo "===== FREE SPACE ====="
df -h /

echo
echo "===== SECURE BOOT ====="
mokutil --sb-state 2>/dev/null || true
```

Check the results carefully.

For this guide, you ideally want something resembling:

```
/dev/nvme0n1p2  ext4  /
```

You also need enough free SSD space for a hibernation-capable swapfile.

If the root filesystem is **Btrfs**, stop here and use a Btrfs-specific hibernation procedure instead.

---

# 2. Determine the Required Swap Size

Check installed RAM:

```
free -h
```

Check current swap:

```
swapon --show
```

For hibernation, swap should generally be at least large enough to hold the hibernation image.

A practical guideline is:

|Installed RAM|Suggested swap|
|---|---|
|8 GiB|16 GiB|
|16 GiB|24 GiB|
|32 GiB|40 GiB|
|64 GiB|72–80 GiB|

The exact image size may be smaller than installed RAM because some pages are excluded or compressed, but allocating additional margin makes configuration more reliable.

---

# 3. Replace an Undersized `/swapfile`

## Warning

Only perform this section if:

- `swapon --show` confirms that `/swapfile` is your current swap;
- your root filesystem is `ext4`;
- you have enough free RAM to temporarily disable swap;
- you have enough free disk space;
- you understand that these commands delete and recreate `/swapfile`.

Do **not** run:

```
sudo rm -f /swapfile
```

unless you have verified that `/swapfile` is actually the swapfile you intend to replace.

## Example: Create a 40 GiB Swapfile

A 40 GiB swapfile is a reasonable example for a system with approximately 32 GiB RAM.

Disable the existing swapfile:

```
sudo swapoff /swapfile
```

Remove it:

```
sudo rm -f /swapfile
```

Create the new file:

```
sudo touch /swapfile
sudo chmod 600 /swapfile
```

Allocate 40 GiB:

```
sudo dd if=/dev/zero \
  of=/swapfile \
  bs=1M \
  count=40960 \
  status=progress
```

Format it as swap:

```
sudo mkswap /swapfile
```

Enable it:

```
sudo swapon /swapfile
```

Verify:

```
swapon --show
free -h
```

You should see something similar to:

```
NAME      TYPE SIZE USED PRIO
/swapfile file  40G   0B   -1
```

Check `/etc/fstab`:

```
grep -n swap /etc/fstab
```

A typical entry is:

```
/swapfile none swap sw 0 0
```

If `/swapfile` is not already listed in `/etc/fstab`, add the appropriate entry before relying on it after reboot.

---

# 4. Determine the Root Device and UUID

Run:

```
ROOT_DEV=$(findmnt -no SOURCE /)
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_DEV")

echo "Root device: $ROOT_DEV"
echo "Root UUID:   $ROOT_UUID"
```

Example output:

```
Root device: /dev/nvme0n1p2
Root UUID:   <YOUR_ROOT_UUID>
```

Do not publish or copy a UUID from another computer into your configuration.

---

# 5. Calculate the Swapfile Resume Offset

Linux needs to know where the swapfile physically begins on the filesystem.

Inspect it first:

```
sudo filefrag -v /swapfile | head -n 10
```

You may see something similar to:

```
ext: logical_offset: physical_offset: length: expected: flags:
0:   0..2047:        123456789..123458836: 2048:
```

The first physical block is not necessarily the final kernel resume offset if filesystem and memory page sizes differ.

Use this calculation instead:

```
OFFSET_BLOCK=$(sudo filefrag -v /swapfile | \
  awk '$1=="0:" {
      x=$4
      sub(/\.\..*/, "", x)
      print x
      exit
  }')

BLOCK_SIZE=$(sudo tune2fs -l "$ROOT_DEV" 2>/dev/null | \
  awk -F: '/Block size:/ {
      gsub(/[[:space:]]/,"",$2)
      print $2
  }')

PAGE_SIZE=$(getconf PAGESIZE)

RESUME_OFFSET=$(( OFFSET_BLOCK * BLOCK_SIZE / PAGE_SIZE ))

echo
echo "===== HIBERNATION VALUES ====="
echo "Root device:           $ROOT_DEV"
echo "Root UUID:             $ROOT_UUID"
echo "Filesystem block size: $BLOCK_SIZE"
echo "Memory page size:      $PAGE_SIZE"
echo "Resume offset:         $RESUME_OFFSET"
```

Record:

```
Root UUID:     <YOUR_ROOT_UUID>
Resume offset: <YOUR_RESUME_OFFSET>
```

These values are specific to the current system.

---

# 6. Configure Initramfs Resume

Create or replace:

```
/etc/initramfs-tools/conf.d/resume
```

using the values calculated above:

```
echo "RESUME=UUID=$ROOT_UUID resume_offset=$RESUME_OFFSET" | \
sudo tee /etc/initramfs-tools/conf.d/resume
```

Verify:

```
cat /etc/initramfs-tools/conf.d/resume
```

It should resemble:

```
RESUME=UUID=<YOUR_ROOT_UUID> resume_offset=<YOUR_RESUME_OFFSET>
```

---

# 7. Add the Resume Parameters to GRUB

Create a dedicated GRUB fragment:

```
sudo mkdir -p /etc/default/grub.d
```

Then:

```
sudo tee /etc/default/grub.d/99-hibernate.cfg >/dev/null <<EOF
GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID=$ROOT_UUID resume_offset=$RESUME_OFFSET"
EOF
```

Verify:

```
cat /etc/default/grub.d/99-hibernate.cfg
```

You should see:

```
GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID=<YOUR_ROOT_UUID> resume_offset=<YOUR_RESUME_OFFSET>"
```

---

# 8. Rebuild Initramfs and GRUB

Run:

```
sudo update-initramfs -u -k all
```

Then:

```
sudo update-grub
```

Some Linux Mint installations may display a warning similar to:

```
W: initramfs-tools configuration sets RESUME=UUID=...
W: but no matching swap device is available.
```

This can happen with swapfile-based hibernation because the resume device is the filesystem partition containing the swapfile, rather than a dedicated swap partition.

Do not assume that warning alone means the configuration failed.

Verify that GRUB contains the expected parameters:

```
sudo grep -oE 'resume=[^ ]+|resume_offset=[^ ]+' \
  /boot/grub/grub.cfg | sort -u
```

Expected:

```
resume=UUID=<YOUR_ROOT_UUID>
resume_offset=<YOUR_RESUME_OFFSET>
```

---

# 9. Reboot Once

Perform one normal reboot:

```
sudo reboot
```

This loads the newly configured kernel parameters.

After logging back in, verify:

```
echo "===== KERNEL COMMAND LINE ====="
cat /proc/cmdline

echo
echo "===== SWAP ====="
swapon --show

echo
echo "===== RESUME DEVICE ====="
cat /sys/power/resume

echo
echo "===== RESUME OFFSET ====="
cat /sys/power/resume_offset
```