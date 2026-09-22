---
title: Top 20 GNOME Themes for Fedora
tags:
  - Linux
  - fedora
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: "https://bnleez1.github.io/PKM/assets/pages/top-20-gnome-themes-for-fedora"
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# 🏆 Top 10 (of 20) GNOME Themes for Fedora

[[Fedora GNOME — Install 20 Icon Sets]]

Install **10 theme families with light and dark versions**, plus additional variants. This is a curated selection, not an official ranking.

> [!info] Compatibility
> These themes primarily style GTK applications such as Thunar. Modern GNOME apps using libadwaita may retain their standard appearance. GNOME Shell theme compatibility varies, especially on GNOME 50.

## Theme collection

| Theme family | Style |
|---|---|
| [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme) | macOS inspired |
| [Orchis](https://github.com/vinceliuice/Orchis-theme) | Rounded, Material Design |
| [Fluent](https://github.com/vinceliuice/Fluent-gtk-theme) | Microsoft Fluent inspired |
| [Graphite](https://github.com/vinceliuice/Graphite-gtk-theme) | Neutral and minimal |
| [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme) | Soft, modern styling |
| [Qogir](https://github.com/vinceliuice/Qogir-theme) | Flat and clean |
| [Matcha](https://github.com/vinceliuice/Matcha-gtk-theme) | Flat with colored accents |
| [Layan](https://github.com/vinceliuice/Layan-gtk-theme) | Rounded with purple accents |
| [Canta](https://github.com/vinceliuice/Canta-theme) | Material Design |
| [Vimix](https://github.com/vinceliuice/vimix-gtk-themes) | Colorful Material Design |

## 1. Install dependencies

```bash
sudo dnf install git sassc \
  gnome-themes-extra gtk-murrine-engine \
  gnome-tweaks gnome-shell-extension-user-theme
```

## 2. Install the themes

Paste the entire block into a terminal.

It downloads the upstream GitHub repositories and runs their installers as your user. Themes go into `~/.themes`; downloaded sources remain in a temporary directory under `~/.cache`.

**Do not run this block with sudo.**

```bash
(
  set -e

  mkdir -p "$HOME/.themes" "$HOME/.cache"
  theme_work="$(mktemp -d "$HOME/.cache/gnome-themes.XXXXXX")"

  repos=(
    WhiteSur-gtk-theme
    Orchis-theme
    Fluent-gtk-theme
    Graphite-gtk-theme
    Colloid-gtk-theme
    Qogir-theme
    Matcha-gtk-theme
    Layan-gtk-theme
    Canta-theme
    vimix-gtk-themes
  )

  for repo in "${repos[@]}"; do
    printf '\nInstalling %s...\n' "$repo"

    git clone --depth 1 \
      "https://github.com/vinceliuice/${repo}.git" \
      "$theme_work/$repo"

    (
      cd "$theme_work/$repo"
      bash ./install.sh -d "$HOME/.themes"
    )
  done

  printf '\nTheme installation finished.\n'
)
```

> [!tip] Installation errors
> If an installer fails, save its error output and resolve the problem before continuing. Earlier themes may already have installed successfully.

## 3. List installed application themes

```bash
find "$HOME/.themes" -mindepth 2 -maxdepth 2 \
  -type d -name gtk-3.0 -printf '%h\n' |
  sed 's|.*/||' | sort
```

## 4. Apply an application theme

Example: **Orchis Dark**.

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

To use another theme, replace `Orchis-Dark` with its exact name from the installed-theme list.

Close and reopen Thunar to see the change.

### Select visually

```bash
gnome-tweaks
```

Go to **Appearance → Legacy Applications**.

## 5. Optional: theme GNOME’s top panel

After installing the User Themes extension, **log out and back in**.

Then run:

```bash
gnome-extensions enable 'user-theme@gnome-shell-extensions.gcampax.github.com'
```

Open GNOME Tweaks:

```bash
gnome-tweaks
```

Select **Appearance → Shell**.

> [!info] Shell compatibility
> Try one shell theme at a time. Successful installation does not guarantee compatibility with GNOME 50.

## 6. Restore the standard appearance

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface color-scheme 'default'
gnome-extensions disable 'user-theme@gnome-shell-extensions.gcampax.github.com'
```

This restores the standard appearance without uninstalling the downloaded themes.

---

---
tags:
  - linux
  - fedora
  - gnome
  - customization
---

# Ten More Theme Families for Fedora Gnome

Ten additional themes to complement the previous collection. This is a curated selection, not a verified popularity ranking.

## Theme selection

| Theme | Appearance | Installation |
|---|---|---|
| [Arc](https://github.com/jnsh/arc-theme) | Flat styling with transparent elements | Fedora package |
| [adw-gtk3](https://github.com/lassekongo83/adw-gtk3) | Makes GTK3 apps resemble modern GNOME | Fedora package |
| [Nordic](https://github.com/EliverLara/Nordic) | Cool blue-gray Nord palette | Upstream files |
| [Dracula](https://github.com/dracula/gtk) | Dark purple with bright accents | Upstream files |
| [Sweet](https://github.com/EliverLara/Sweet) | Bold colors and neon accents | Upstream files |
| [Flat Remix GTK](https://github.com/daniruiz/flat-remix-gtk) | Colorful Material-inspired styling | Upstream files |
| [Gruvbox GTK](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) | Warm, earthy colors | Upstream installer |
| [Tokyo Night GTK](https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme) | Blue and purple palette | Upstream installer |
| [Everforest GTK](https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme) | Muted greens and earthy colors | Upstream installer |
| [Catppuccin GTK](https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme) | Soft pastel palette | Community GTK port installer |

> [!info] Fedora GNOME compatibility
> These instructions primarily target GTK3 applications such as Thunar. Installing a GTK theme does not automatically restyle modern libadwaita apps, Flatpak apps, icons, or GNOME’s top panel.
>
> GNOME Shell themes require version-specific compatibility. The commands below install application themes without enabling a shell theme or applying global GTK4 CSS overrides.

## 1. Install dependencies

Run in Bash on Fedora Workstation:

```bash
sudo dnf install git sassc \
  gtk-murrine-engine gnome-themes-extra gnome-tweaks
```

## 2. Install Arc and adw-gtk3

```bash
sudo dnf install arc-theme adw-gtk3-theme
```

These packages install system-wide and receive updates through DNF.

## 3. Install Nordic, Dracula, and Sweet

Run this entire block without sudo.

It downloads each project into a fresh working directory and copies it into `~/.themes`. Existing destination folders are skipped.

```bash
(
  set -e

  mkdir -p "$HOME/.themes" "$HOME/.cache"
  theme_work="$(mktemp -d "$HOME/.cache/extra-gtk-themes.XXXXXX")"

  install_theme_files() {
    local repo="$1"
    local name="$2"
    local dest="$HOME/.themes/$name"

    if [ -e "$dest" ]; then
      printf 'Already exists; skipping: %s\n' "$dest"
      return
    fi

    git clone --depth 1 \
      "https://github.com/${repo}.git" \
      "$theme_work/$name"

    test -f "$theme_work/$name/gtk-3.0/gtk.css"
    cp -a "$theme_work/$name" "$dest"

    printf 'Installed: %s\n' "$name"
  }

  install_theme_files EliverLara/Nordic Nordic
  install_theme_files dracula/gtk Dracula
  install_theme_files EliverLara/Sweet Sweet
)
```

## 4. Install Flat Remix GTK

This copies the project's prebuilt theme folders, including its available variants.

```bash
(
  set -e

  mkdir -p "$HOME/.themes" "$HOME/.cache"
  theme_work="$(mktemp -d "$HOME/.cache/flat-remix.XXXXXX")"

  git clone --depth 1 \
    https://github.com/daniruiz/flat-remix-gtk.git \
    "$theme_work/repo"

  theme_count=0

  for theme_dir in "$theme_work/repo/themes/"*; do
    [ -f "$theme_dir/gtk-3.0/gtk.css" ] || continue

    theme_name="$(basename "$theme_dir")"
    theme_dest="$HOME/.themes/$theme_name"

    if [ -e "$theme_dest" ]; then
      printf 'Already exists; skipping: %s\n' "$theme_name"
    else
      cp -a "$theme_dir" "$theme_dest"
      printf 'Installed: %s\n' "$theme_name"
    fi

    theme_count=$((theme_count + 1))
  done

  if [ "$theme_count" -eq 0 ]; then
    printf 'No prebuilt GTK3 themes found; check the upstream project.\n' >&2
    exit 1
  fi
)
```

## 5. Install Gruvbox, Tokyo Night, Everforest, and Catppuccin

These projects provide installers inside their `themes/` directories.

Run the entire block without sudo. It installs the default variants for each family. Re-running it may replace previously installed variants of these four themes.

```bash
(
  set -e

  mkdir -p "$HOME/.themes" "$HOME/.cache"
  theme_work="$(mktemp -d "$HOME/.cache/palette-themes.XXXXXX")"

  repos=(
    Gruvbox-GTK-Theme
    Tokyonight-GTK-Theme
    Everforest-GTK-Theme
    Catppuccin-GTK-Theme
  )

  for repo in "${repos[@]}"; do
    printf '\nInstalling %s...\n' "$repo"

    git clone --depth 1 \
      "https://github.com/Fausto-Korpsvart/${repo}.git" \
      "$theme_work/$repo"

    (
      cd "$theme_work/$repo/themes"
      test -f install.sh
      bash ./install.sh -d "$HOME/.themes"
    )
  done

  printf '\nPalette theme installation finished.\n'
)
```

> [!tip] If installation fails
> Stop at the failing block and save the error output. Earlier themes may already be installed. Upstream project layouts and dependencies can change.

## 6. List installed GTK3 themes

This checks both user-installed themes and Fedora packages:

```bash
(
  for theme_root in \
    "$HOME/.themes" \
    "$HOME/.local/share/themes" \
    /usr/share/themes
  do
    [ -d "$theme_root" ] || continue

    find "$theme_root" -mindepth 2 -maxdepth 2 \
      -type d -name gtk-3.0 -printf '%h\n'
  done
) | sed 's|.*/||' | sort -u
```

Use the exact names shown when applying themes. Some installers add color and size suffixes.

## 7. Apply a theme

Choose one example below.

### Nordic

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### Dracula

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### Sweet

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Sweet'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### Arc Dark

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### adw-gtk3 Dark

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

Close and reopen Thunar after changing the theme.

### Choose visually

```bash
gnome-tweaks
```

Open **Appearance → Legacy Applications** and choose an installed theme.

## 8. Check the active theme

```bash
gsettings get org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.desktop.interface color-scheme
```

## 9. Restore the standard application appearance

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface color-scheme 'default'
```

The downloaded themes remain installed for future use.