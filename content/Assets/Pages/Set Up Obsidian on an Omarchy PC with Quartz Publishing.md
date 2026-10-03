---
title: Set Up Obsidian on an Omarchy PC with Quartz Publishing
tags:
  - Linux
  - Omarchy
  - Guide
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/obsidian-setup-in-omarchy
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Set Up Obsidian on an Omarchy PC with Quartz Publishing
````
# Set Up Obsidian on an Omarchy PC with Quartz Publishing

This guide documents my working Obsidian setup on an Omarchy PC.

The setup uses:

- **Omarchy / Arch Linux**
- **Obsidian**
- An Obsidian vault stored on an external SanDisk drive
- GitHub for version control and publishing
- Quartz v5 for the public website
- Obsidian Shell Commands for one-key publishing

My public Quartz site is:

`https://bnleez1.github.io/PKM/`

---

# 1. Overall Setup

The publishing workflow is:

```text
Obsidian vault on SanDisk
        ↓
60 Public/Website
        ↓
~/Projects/PKM/content
        ↓
GitHub repository: bnleez1/PKM
        ↓
branch: v5
        ↓
GitHub Actions / Quartz
        ↓
https://bnleez1.github.io/PKM/
````

Only the following folder is published:

```
60 Public/Website
```

The rest of the Obsidian vault remains private.

---

# 2. Obsidian Vault Location

On the Office Omarchy PC, the vault is located at:

```
/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian
```

Set a temporary shell variable when needed:

```
VAULT="/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian"
```

Verify that the vault exists:

```
ls -ld "$VAULT"
```

Verify the public website folder:

```
ls -ld "$VAULT/60 Public/Website"
```

Both commands should return directory information without errors.

---

# 3. Open the Vault in Obsidian

Open Obsidian.

Choose:

**Open folder as vault**

Select:

```
/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian
```

Obsidian should now use the SanDisk vault directly.

Do not create a second copy of the vault on the internal drive unless intentionally changing the setup.

---

# 4. Verify Required Publishing Tools

Check the required tools:

```
git --version
gh --version
node --version
npm --version
rsync --version | head -n 1
```

The working Omarchy setup had:

```
Git
GitHub CLI
Node.js
npm
rsync
```

If needed, install the main tools with:

```
sudo pacman -S --needed git github-cli nodejs npm rsync
```

---

# 5. Authenticate GitHub

Check authentication:

```
gh auth status
```

If not authenticated:

```
gh auth login --web --git-protocol https
```

Follow the browser authentication procedure.

Then configure Git to use the GitHub CLI credentials:

```
gh auth setup-git
```

Verify:

```
gh auth status
```

The account should show:

```
bnleez1
```

---

# 6. Clone the Existing Quartz Repository

Do **not** create a new Quartz site.

The existing configured repository should be cloned instead.

Create the project directory:

```
mkdir -p "$HOME/Projects"
```

Clone the `v5` branch:

```
git clone \
  --branch v5 \
  https://github.com/bnleez1/PKM.git \
  "$HOME/Projects/PKM"
```

Verify:

```
git -C "$HOME/Projects/PKM" status --short --branch
```

Expected:

```
## v5...origin/v5
```

Check the branch:

```
git -C "$HOME/Projects/PKM" branch --show-current
```

Expected:

```
v5
```

Check the remote:

```
git -C "$HOME/Projects/PKM" remote -v
```

It should point to:

```
https://github.com/bnleez1/PKM.git
```

---

# 7. Verify the Publishing Scripts

The Quartz repository already contains the required scripts:

```
~/Projects/PKM/scripts/publish-public.sh
~/Projects/PKM/scripts/sync-public.sh
```

Check them:

```
ls -lh "$HOME/Projects/PKM/scripts/"
```

They should be executable.

If necessary:

```
chmod +x \
  "$HOME/Projects/PKM/scripts/publish-public.sh" \
  "$HOME/Projects/PKM/scripts/sync-public.sh"
```

---

# 8. Create the Machine-Specific Publishing Configuration

The same publishing scripts can be used on different computers because the vault location is stored separately.

Create:

```
~/.config/pkm-publish.conf
```

Run:

```
mkdir -p "$HOME/.config"

cat > "$HOME/.config/pkm-publish.conf" <<'EOF'
VAULT="/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian"
PROJECT="$HOME/Projects/PKM"
BRANCH="v5"
REMOTE="origin"
EOF
```

Verify:

```
cat "$HOME/.config/pkm-publish.conf"
```

It should contain:

```
VAULT="/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian"
PROJECT="$HOME/Projects/PKM"
BRANCH="v5"
REMOTE="origin"
```

---

# 9. Verify All Paths

Run:

```
source "$HOME/.config/pkm-publish.conf"

test -d "$VAULT" \
  && echo "Vault: OK" \
  || echo "Vault: NOT FOUND"

test -d "$VAULT/60 Public/Website" \
  && echo "Public Website: OK" \
  || echo "Public Website: NOT FOUND"

test -d "$PROJECT/.git" \
  && echo "Quartz repo: OK" \
  || echo "Quartz repo: NOT FOUND"
```

Expected:

```
Vault: OK
Public Website: OK
Quartz repo: OK
```

---

# 10. How Publishing Works

The source content is:

```
$VAULT/60 Public/Website
```

The Quartz destination is:

```
~/Projects/PKM/content
```

The publishing scripts synchronize the public files into the Quartz repository.

They do **not** publish the entire Obsidian vault.

---

# 11. Test the Synchronization Script

Run:

```
cd "$HOME/Projects/PKM"

./scripts/sync-public.sh
```

The script can show the changes that will be made before synchronizing.

Review the proposed changes carefully.

This is especially useful after setting up a new machine.

---

# 12. Test Full Publishing from the Terminal

Run:

```
cd "$HOME/Projects/PKM"

./scripts/publish-public.sh
```

This should:

1. Read the Office-PC vault location.
2. Synchronize `60 Public/Website`.
3. Update the Quartz `content` folder.
4. Commit changes when necessary.
5. Push them to the `v5` branch.
6. Trigger the GitHub/Quartz publishing workflow.

Check recent GitHub Actions runs with:

```
gh run list \
  --repo bnleez1/PKM \
  --limit 5
```

The finished site should appear at:

```
https://bnleez1.github.io/PKM/
```

---

# 13. Configure Obsidian Shell Commands

Install or enable the **Shell Commands** community plugin in Obsidian.

Open:

**Settings → Shell Commands**

Create a command called:

```
Publish Website to GitHub
```

Use:

```
bash -lc "$HOME/Projects/PKM/scripts/publish-public.sh"
```

Assign the keyboard shortcut:

```
Ctrl + Alt + P
```

This makes publishing available directly from Obsidian.

---

# 14. Fix the Omarchy/Fcitx5 Preedit Conflict

Omarchy's Fcitx5 input system also uses:

```
Ctrl + Alt + P
```

for toggling **Preedit**.

This can cause a popup such as:

> Preedit  
> Preedit disabled

when trying to publish from Obsidian.

The solution is to move the Fcitx5 shortcut somewhere else.

Create or replace:

```
~/.config/fcitx5/config
```

with:

```
mkdir -p "$HOME/.config/fcitx5"

cat > "$HOME/.config/fcitx5/config" <<'EOF'
[Hotkey/TogglePreedit]
0=Control+Alt+Shift+F12
EOF
```

Verify:

```
cat "$HOME/.config/fcitx5/config"
```

Expected:

```
[Hotkey/TogglePreedit]
0=Control+Alt+Shift+F12
```

Restart Fcitx5:

```
pkill fcitx5
sleep 2
fcitx5 -d
```

The shortcuts are now:

```
Obsidian Publish
Ctrl + Alt + P

Fcitx5 Preedit
Ctrl + Alt + Shift + F12
```

---

# 15. Optional: Preview Quartz Locally

Move to the project:

```
cd "$HOME/Projects/PKM"
```

Install dependencies if this is the first setup:

```
npm ci
```

Then run:

```
npx quartz build --serve
```

Open:

```
http://localhost:8080
```

Stop the preview with:

```
Ctrl + C
```

---

# 16. Normal Daily Workflow

My normal workflow is now very simple.

### Edit

Open Obsidian and work normally in the SanDisk vault.

### Public material

Place material intended for the website somewhere under:

```
60 Public/Website
```

### Publish

Press:

```
Ctrl + Alt + P
```

Obsidian runs:

```
Publish Website to GitHub
```

The publishing script handles the synchronization and GitHub push.

---

# 17. Important Rules

## Do not run `npx quartz create`

The Quartz repository is already configured.

Creating a new Quartz installation can overwrite or conflict with the existing configuration.

Always clone:

```
https://github.com/bnleez1/PKM.git
```

and use branch:

```
v5
```

---

## Do not publish the entire vault

Only:

```
60 Public/Website
```

belongs in Quartz `content`.

Private folders such as notes, people, research material, and other vault content should remain outside the public website tree.

---

## Keep machine-specific paths out of GitHub

Different computers can use different vault locations.

Store the local path in:

```
~/.config/pkm-publish.conf
```

rather than hard-coding the external-drive path into the publishing scripts.

---

# 18. Quick Diagnostic

If publishing stops working, run:

```
echo "========== VAULT =========="
test -d "/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian" \
  && echo "Vault: OK" \
  || echo "Vault: NOT FOUND"

echo
echo "========== PUBLIC SOURCE =========="
test -d "/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian/60 Public/Website" \
  && echo "Public Website: OK" \
  || echo "Public Website: NOT FOUND"

echo
echo "========== QUARTZ =========="
git -C "$HOME/Projects/PKM" status --short --branch

echo
echo "========== BRANCH =========="
git -C "$HOME/Projects/PKM" branch --show-current

echo
echo "========== REMOTE =========="
git -C "$HOME/Projects/PKM" remote -v

echo
echo "========== NODE =========="
node --version

echo
echo "========== GITHUB =========="
gh auth status

echo
echo "========== SCRIPTS =========="
ls -lh \
  "$HOME/Projects/PKM/scripts/sync-public.sh" \
  "$HOME/Projects/PKM/scripts/publish-public.sh"

echo
echo "========== CONFIG =========="
cat "$HOME/.config/pkm-publish.conf"
```

A healthy system should show:

```
Vault: OK
Public Website: OK
branch: v5
GitHub authenticated as bnleez1
publishing scripts present
pkm-publish.conf present
```

---

# Final Setup

The completed Omarchy Obsidian system is:

```
SanDisk
└── Obsidian
    └── 60 Public
        └── Website
              │
              ▼
       sync-public.sh
              │
              ▼
~/Projects/PKM/content
              │
              ▼
     publish-public.sh
              │
              ▼
        GitHub / v5
              │
              ▼
          Quartz
              │
              ▼
https://bnleez1.github.io/PKM/
```

And publishing from Obsidian requires only:

```
Ctrl + Alt + P
```