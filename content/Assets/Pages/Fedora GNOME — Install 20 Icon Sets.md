---
title: Fedora GNOME — Install 20 Icon Sets
tags:
  - Linux
  - fedora
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/top-20-icon-themes-for-fedora-gnome
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Fedora GNOME — Install 20 Icon Sets

A curated collection of 20 icon families, including additional variants where supplied. The numbering is not a popularity ranking.

These instructions target Fedora Workstation with GNOME. Run each Bash block in order.

## Icon collection

| # | Icon family | Style |
|---|---|---|
| 1 | [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) | Colorful, extensive application coverage |
| 2 | [Numix](https://github.com/numixproject/numix-icon-theme) | Classic flat design |
| 3 | [Numix Circle](https://github.com/numixproject/numix-icon-theme-circle) | Circular application icons |
| 4 | [Breeze](https://develop.kde.org/frameworks/breeze-icons/) | Clean KDE styling |
| 5 | [Oxygen](https://invent.kde.org/frameworks/oxygen-icons) | Detailed, traditional desktop icons |
| 6 | [elementary](https://github.com/elementary/icons) | Soft colors and dimensional shapes |
| 7 | [WhiteSur](https://github.com/vinceliuice/WhiteSur-icon-theme) | macOS inspired |
| 8 | [Tela](https://github.com/vinceliuice/Tela-icon-theme) | Colorful flat icons |
| 9 | [Tela Circle](https://github.com/vinceliuice/Tela-circle-icon-theme) | Circular Tela styling |
| 10 | [Fluent](https://github.com/vinceliuice/Fluent-icon-theme) | Microsoft Fluent inspired |
| 11 | [Colloid](https://github.com/vinceliuice/Colloid-icon-theme) | Soft, modern styling |
| 12 | [Qogir](https://github.com/vinceliuice/Qogir-icon-theme) | Colorful, clean shapes |
| 13 | [McMojave Circle](https://github.com/vinceliuice/McMojave-circle) | Circular macOS-inspired icons |
| 14 | [Vimix](https://github.com/vinceliuice/Vimix-icon-theme) | Material-inspired colors |
| 15 | [Reversal](https://github.com/yeyushengfan258/Reversal-icon-theme) | Colorful rectangular icons |
| 16 | [Flat Remix](https://github.com/daniruiz/flat-remix) | Flat shapes with gradients and shadows |
| 17 | [Candy](https://github.com/EliverLara/candy-icons) | Bright gradient colors |
| 18 | [Kora](https://github.com/bikass/kora) | Detailed SVG icons |
| 19 | [La Capitaine](https://github.com/keeferrourke/la-capitaine-icon-theme) | macOS and Material Design influences |
| 20 | [Suru++](https://github.com/suru-plus/suru-plus) | Colorful Suru-inspired styling |

> [!info] What changes?
> Icon themes affect supported application launchers, folders, files, and interface icons. They do not change your GTK theme or install a dock.
>
> Some applications use embedded or absolute-path icons and may retain their original appearance. Flatpak and symbolic toolbar icons may also behave differently.

## 1. Install tools and six Fedora-packaged icon sets

```bash
sudo dnf install git gtk3 gnome-tweaks \
  papirus-icon-theme \
  numix-icon-theme \
  numix-icon-theme-circle \
  breeze-icon-theme \
  oxygen-icon-theme \
  elementary-icon-theme
```

These icon sets install system-wide and receive updates through DNF.

## 2. Install nine sets using upstream installers

This installs:

- WhiteSur
- Tela
- Tela Circle
- Fluent
- Colloid
- Qogir
- McMojave Circle
- Vimix
- Reversal

Run the entire block **without sudo**. It downloads and executes each project's installer, targeting your personal icon directory.

```bash
(
  set -e

  icon_dest="$HOME/.local/share/icons"
  mkdir -p "$icon_dest" "$HOME/.cache"
  icon_work="$(mktemp -d "$HOME/.cache/icon-installers.XXXXXX")"

  repos=(
    vinceliuice/WhiteSur-icon-theme
    vinceliuice/Tela-icon-theme
    vinceliuice/Tela-circle-icon-theme
    vinceliuice/Fluent-icon-theme
    vinceliuice/Colloid-icon-theme
    vinceliuice/Qogir-icon-theme
    vinceliuice/McMojave-circle
    vinceliuice/Vimix-icon-theme
    yeyushengfan258/Reversal-icon-theme
  )

  for repo in "${repos[@]}"; do
    repo_name="${repo##*/}"
    printf '\nInstalling %s...\n' "$repo_name"

    git clone --depth 1 \
      "https://github.com/${repo}.git" \
      "$icon_work/$repo_name"

    (
      cd "$icon_work/$repo_name"
      test -f install.sh
      bash ./install.sh -d "$icon_dest"
    )
  done

  printf '\nUpstream icon installers finished.\n'
)
```

Default variants are installed. Re-running these installers may replace existing variants of the same icon families.

## 3. Install five sets supplied as ready-to-use files

This installs Flat Remix, Candy, Kora, La Capitaine, and Suru++.

The script checks for `index.theme`, preserves symbolic links, and skips destination folders that already exist.

Run without sudo:

```bash
(
  set -e

  icon_dest="$HOME/.local/share/icons"
  mkdir -p "$icon_dest" "$HOME/.cache"
  icon_work="$(mktemp -d "$HOME/.cache/icon-files.XXXXXX")"

  copy_icon_theme() {
    local source="$1"
    local name="$2"
    local target="$icon_dest/$name"

    if [ -e "$target" ] || [ -L "$target" ]; then
      printf 'Already exists; skipping: %s\n' "$name"
      return
    fi

    test -f "$source/index.theme"
    cp -a "$source" "$target"
    printf 'Installed: %s\n' "$name"
  }

  repos=(
    daniruiz/flat-remix
    EliverLara/candy-icons
    bikass/kora
    keeferrourke/la-capitaine-icon-theme
    suru-plus/suru-plus
  )

  for repo in "${repos[@]}"; do
    repo_name="${repo##*/}"
    source_dir="$icon_work/$repo_name"

    printf '\nDownloading %s...\n' "$repo_name"

    git clone --depth 1 \
      "https://github.com/${repo}.git" \
      "$source_dir"

    if [ -f "$source_dir/index.theme" ]; then
      copy_icon_theme "$source_dir" "$repo_name"
    else
      found=0

      for theme_dir in "$source_dir/"*; do
        [ -f "$theme_dir/index.theme" ] || continue

        copy_icon_theme "$theme_dir" "$(basename "$theme_dir")"
        found=$((found + 1))
      done

      if [ "$found" -eq 0 ]; then
        printf 'No ready-to-use icon themes found in %s\n' "$repo" >&2
        exit 1
      fi
    fi
  done

  printf '\nIcon file installation finished.\n'
)
```

> [!tip] Installation errors
> If a block fails, save the error output and resolve it before continuing. Previously completed installations remain in place.
>
> These instructions were checked against upstream documentation and repository layouts, but were not executed on this computer.

## 4. Refresh the personal icon caches

```bash
for icon_dir in "$HOME/.local/share/icons/"*; do
  [ -f "$icon_dir/index.theme" ] || continue

  gtk-update-icon-cache -f -t "$icon_dir" ||
    printf 'Cache refresh failed for: %s\n' "$icon_dir"
done
```

## 5. List installed icon-theme names

The folder names are the identifiers used by `gsettings`.

```bash
(
  for icon_root in \
    "$HOME/.local/share/icons" \
    "$HOME/.icons" \
    /usr/share/icons
  do
    [ -d "$icon_root" ] || continue

    for theme_file in "$icon_root/"*/index.theme; do
      [ -f "$theme_file" ] || continue
      grep -q '^Directories=' "$theme_file" || continue

      basename "$(dirname "$theme_file")"
    done
  done
) | sort -u
```

## 6. Apply an icon set

Run **one** of these examples.

### Papirus

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
```

### Papirus for a dark desktop

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
```

### Numix Circle

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
```

### WhiteSur

```bash
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur'
```

### Candy

```bash
gsettings set org.gnome.desktop.interface icon-theme 'candy-icons'
```

### Kora

```bash
gsettings set org.gnome.desktop.interface icon-theme 'kora'
```

For other sets, use their exact folder name from Step 5.

Reopen Thunar or other applications if their icons do not update immediately. If the application grid still shows old icons, log out and back in.

## 7. Choose icons visually

```bash
gnome-tweaks
```

Go to **Appearance → Icons**.

## 8. Check the active icon set

```bash
gsettings get org.gnome.desktop.interface icon-theme
```

## 9. Restore GNOME's Adwaita icons

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
```

The other icon sets remain installed.

## Maintenance

- Fedora-packaged icon sets update through DNF.
- GitHub-installed sets do not update through DNF.
- Step 2 installers can be rerun to reinstall current upstream versions.
- Step 3 skips existing folders; rerunning it does not update those installed copies.
- Downloaded source directories remain under `~/.cache/icon-installers.*` and `~/.cache/icon-files.*`.