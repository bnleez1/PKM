---
title: Installing Core Applications and WinBoat on Omarchy
tags:
  - Linux
  - Omarchy
  - Guide
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/installing-apps-on-omarchy
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Installing Core Applications and WinBoat on Omarchy

This guide documents the installation of the following applications on **Omarchy**:

- Obsidian
- OBS Studio
- Kdenlive
- Okular
- PDF Arranger
- Microsoft Teams
- Thunderbird
- PSPP
- WinBoat
- WinBoat dependencies: Docker, Docker Compose, FreeRDP, and KVM

The setup uses native Arch packages whenever possible and AUR packages where necessary.

---

## 1. Update Omarchy

Before installing applications, update Omarchy:

```bash
omarchy update
```

It is preferable to use Omarchy's own update mechanism rather than manually performing a full Arch system upgrade with `pacman -Syu`.

---

# 2. Install the Main Applications

Install the applications available through the normal Arch repositories:

```bash
yay -S --needed \
  obsidian \
  obs-studio \
  obs-studio-plugin-browser \
  kdenlive \
  okular \
  pdfarranger \
  thunderbird \
  docker \
  docker-compose \
  freerdp
```

The `--needed` option prevents packages that are already installed from being unnecessarily reinstalled.

Some Omarchy installations may already include applications such as Obsidian, OBS Studio, or Kdenlive.

---

# 3. Install Teams, PSPP, and WinBoat

Install the remaining applications through the AUR:

```bash
yay -S --needed \
  aur/teams-for-linux \
  aur/pspp \
  aur/winboat
```

## Microsoft Teams

The Linux application used here is:

```text
teams-for-linux
```

This is a Linux desktop wrapper for the Microsoft Teams web application rather than Microsoft's discontinued native Linux Teams client.

## PSPP

PSPP provides a free statistical-analysis environment similar in purpose to SPSS.

## WinBoat

WinBoat runs Windows in a virtualized environment while integrating Windows applications with the Linux desktop.

The WinBoat AUR package may take considerably longer to install because `yay` builds the Electron application locally.

During the build, messages such as these may appear:

```text
building
electron-builder
building target=AppImage
downloading
```

Yellow warnings from npm, Tailwind, Electron, or related build tools do not necessarily indicate a failure.

Allow the build to continue until the normal terminal prompt returns.

Do **not** interrupt the build with:

```text
Ctrl+C
```

unless an actual error occurs.

---

# 4. Enable Docker

WinBoat requires Docker.

Enable Docker immediately and configure it to start automatically at boot:

```bash
sudo systemctl enable --now docker
```

---

# 5. Add the User to Docker and KVM Groups

Add the current user to the required groups:

```bash
sudo usermod -aG docker,kvm "$USER"
```

Then reboot:

```bash
reboot
```

A reboot is important because the new group memberships need to be loaded into the login session.

---

# 6. Verify WinBoat Dependencies

After rebooting, run:

```bash
echo "===== Docker ====="
docker --version

echo
echo "===== Docker Compose ====="
docker compose version

echo
echo "===== FreeRDP ====="
xfreerdp3 /version

echo
echo "===== KVM ====="
ls -l /dev/kvm

echo
echo "===== Groups ====="
groups

echo
echo "===== Docker test ====="
docker run --rm hello-world
```

On this Omarchy installation, the successful results were:

```text
===== Docker =====
Docker version 29.7.2

===== Docker Compose =====
Docker Compose version 5.5.1

===== FreeRDP =====
FreeRDP version 3.31.1

===== KVM =====
/dev/kvm exists

===== Groups =====
ben docker kvm wheel
```

The Docker test finished with:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

This confirms that:

- Docker is installed.
- The Docker daemon is running.
- Docker works without `sudo`.
- Docker can download images.
- Docker Compose is installed.
- FreeRDP 3 is installed.
- KVM virtualization is available.
- The user belongs to the `docker` group.
- The user belongs to the `kvm` group.

---

# 7. Verify WinBoat

Check whether the WinBoat package installed successfully:

```bash
pacman -Q winboat
```

Then locate its executable:

```bash
command -v winboat
```

If both commands return valid results, launch WinBoat with:

```bash
winboat
```

Alternatively, press:

```text
Super
```

and search for:

```text
WinBoat
```

in the Omarchy application launcher.

---

# 8. Check Docker Status Later

To confirm that Docker starts automatically:

```bash
systemctl status docker
```

A healthy installation should display something similar to:

```text
Active: active (running)
```

Exit the status display with:

```text
q
```

---

# 9. Useful WinBoat Diagnostics

If WinBoat has problems later, check Docker first:

```bash
docker ps
```

Check KVM:

```bash
ls -l /dev/kvm
```

Check group membership:

```bash
groups
```

Check FreeRDP:

```bash
xfreerdp3 /version
```

Check Docker Compose:

```bash
docker compose version
```

Check whether Docker can run a container:

```bash
docker run --rm hello-world
```

---

# 10. Installed Application Summary

| Application | Package |
|---|---|
| Obsidian | `obsidian` |
| OBS Studio | `obs-studio` |
| OBS browser support | `obs-studio-plugin-browser` |
| Kdenlive | `kdenlive` |
| Okular | `okular` |
| PDF Arranger | `pdfarranger` |
| Thunderbird | `thunderbird` |
| Microsoft Teams | `teams-for-linux` |
| PSPP | `pspp` |
| WinBoat | `winboat` |
| Docker | `docker` |
| Docker Compose | `docker-compose` |
| FreeRDP | `freerdp` |
| Hardware virtualization | KVM |

---

# 11. Complete Installation Commands

For a fresh Omarchy installation, the essential process can be summarized as follows.

## Update Omarchy

```bash
omarchy update
```

## Install native packages

```bash
yay -S --needed \
  obsidian \
  obs-studio \
  obs-studio-plugin-browser \
  kdenlive \
  okular \
  pdfarranger \
  thunderbird \
  docker \
  docker-compose \
  freerdp
```

## Install AUR applications

```bash
yay -S --needed \
  aur/teams-for-linux \
  aur/pspp \
  aur/winboat
```

## Configure Docker and KVM

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker,kvm "$USER"
```

Then:

```bash
reboot
```

## Verify everything after reboot

```bash
echo "===== Docker ====="
docker --version

echo
echo "===== Docker Compose ====="
docker compose version

echo
echo "===== FreeRDP ====="
xfreerdp3 /version

echo
echo "===== KVM ====="
ls -l /dev/kvm

echo
echo "===== Groups ====="
groups

echo
echo "===== Docker test ====="
docker run --rm hello-world
```

## Verify WinBoat

```bash
pacman -Q winboat
command -v winboat
```

Launch it with:

```bash
winboat
```

---

# Result

The Omarchy system now has the main productivity, video, PDF, communication, statistical-analysis, and Windows-integration applications installed.

Most applications require no additional configuration beyond installation. **WinBoat is the exception** because it depends on Docker, Docker Compose, FreeRDP, KVM virtualization, and the correct user permissions.

Once the Docker `hello-world` test succeeds, `/dev/kvm` is available, `docker` and `kvm` appear in the user's groups, and FreeRDP 3 is detected, the Linux side of the WinBoat environment is ready for its Windows setup.