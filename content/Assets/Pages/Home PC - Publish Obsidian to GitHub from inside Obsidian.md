---
title:
tags:
  - Obsidian
subject: []
formalDefinition:
relatedTerms: []
pages:
notes: []
gh-publish: true
gh-path:
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/content/New Page Template
banner: https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEihLwYOhSwIlJjyWIIxe17o67-c6IYoBRb0cY9D2rx3AASHh6fhIZmNfWS4j7fFi1-SKRjNKRCCLb_6gOyI_Kl7cC0e04SHL9GQQSU-ezncN1Eu2fVE-RQ-zDhEXi7DutO0LpkJN6WR5iDSA7qgezXmxaNs6ENgjH7rJXj52CKU3kEIMhME8KKuxv2yOGI/s1080/rainbow-obsidian.jpg
---
Here is a reusable **Home PC tutorial** that reproduces the office setup as closely as possible.

# Home PC: Publish Obsidian → GitHub from inside Obsidian

The finished workflow will be:

**Obsidian → Ctrl+Alt+P or ribbon button → `publish-public.sh` → `60 Public/Website` → Quartz `content` → GitHub branch `v5`**

## 1. Verify the Quartz/GitHub repository

Open Terminal:

```bash
cd "$HOME/Projects/PKM"

git branch --show-current
git remote -v
git status --short
```

You want the branch to be:

```text
v5
```

and `origin` to point to:

```text
https://github.com/bnleez1/PKM.git
```

Ideally, `git status --short` should show nothing before proceeding.

---

# 2. Confirm the Home PC Obsidian path

Run:

```bash
find /mnt /run/media/"$USER" \
  -type d \
  -path "*/Obsidian/60 Public/Website" \
  2>/dev/null
```

On your Home PC, your path has previously been:

```text
/mnt/usb-SanDisk_Extreme_55AE_323432353642343032323032-0:0-part1/Obsidian/60 Public/Website
```

Still verify it before creating the script.

---

# 3. Create the local scripts directory

```bash
cd "$HOME/Projects/PKM"
mkdir -p scripts
```

## 4. Create `sync-public.sh`

If the path above is still correct, paste:

```bash
cat > scripts/sync-public.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SOURCE="/mnt/usb-SanDisk_Extreme_55AE_323432353642343032323032-0:0-part1/Obsidian/60 Public/Website/"
DEST="$HOME/Projects/PKM/content/"

if [[ ! -d "$SOURCE" ]]; then
  echo "ERROR: Public Obsidian folder not found:"
  echo "$SOURCE"
  exit 1
fi

echo
echo "DRY RUN — review what would be copied or removed"
echo "Source:      $SOURCE"
echo "Destination: $DEST"
echo

rsync -avhn --delete "$SOURCE" "$DEST"

echo
read -r -p "Proceed with synchronization? [y/N] " answer

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
  echo "Synchronization cancelled."
  exit 0
fi

echo
echo "Copying public Obsidian files into Quartz..."
rsync -avh --delete "$SOURCE" "$DEST"

echo
echo "Synchronization complete."
EOF
```

---

# 5. Create `publish-public.sh`

```bash
cat > scripts/publish-public.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/PKM"

echo "Downloading any changes from GitHub..."
git pull origin v5

echo
echo "Copying public Obsidian files into Quartz..."
printf 'y\n' | ./scripts/sync-public.sh

git add -A content

if git diff --cached --quiet -- content; then
  echo
  echo "No public changes to publish."
  exit 0
fi

git commit \
  -m "Publish public notes $(date '+%Y-%m-%d %H:%M')" \
  -- content

echo
echo "Uploading to GitHub..."
git push origin v5

echo
echo "Publishing complete."
EOF
```

Make them executable:

```bash
chmod +x scripts/sync-public.sh
chmod +x scripts/publish-public.sh
```

---

# 6. Keep the machine-specific scripts out of Git

Because the external-drive path differs between your Home and Office PCs, keep the scripts local:

```bash
printf '\n# Machine-specific publishing scripts\n/scripts/\n' >> .git/info/exclude
```

Check:

```bash
git status --short
```

You should **not** see:

```text
?? scripts/
```

---

# 7. Test synchronization

First:

```bash
./scripts/sync-public.sh
```

Check that the source and destination are correct.

Then test the entire publishing process:

```bash
cd "$HOME/Projects/PKM" && ./scripts/publish-public.sh
```

A normal result when nothing has changed is:

```text
Synchronization complete.

No public changes to publish.
```

Do not continue with Obsidian until this works from Terminal.

---

# 8. Install the Obsidian plugins

In Obsidian:

**Settings → Community plugins → Browse**

Install and enable:

- **Shell commands**
    
- **Commander**
    

You do **not** need Obsidian Git for this publishing workflow.

---

# 9. Fix the Shell commands settings display if necessary

With Obsidian 1.13.x and Shell commands 0.23.0, we found that the settings content may appear blank.

If that happens, create this CSS snippet:

```bash
VAULT="/mnt/usb-SanDisk_Extreme_55AE_323432353642343032323032-0:0-part1/Obsidian"

mkdir -p "$VAULT/.obsidian/snippets"

cat > "$VAULT/.obsidian/snippets/shellcommands-1-13-fix.css" <<'EOF'
#SC-tab-main-shell-commands {
  display: block !important;
}

/* Shell Commands 0.23.0 / Obsidian 1.13.x modal-tab workaround */
.modal .SC-tab-content {
  display: block !important;
}
EOF
```

Then in Obsidian:

**Settings → Appearance → CSS snippets**

Enable:

**shellcommands-1-13-fix**

You should then see the **New shell command** control.

---

# 10. Allow Flatpak Obsidian to execute host commands

Because your Obsidian installation is Flatpak-based, completely close Obsidian and run:

```bash
flatpak override --user \
  --talk-name=org.freedesktop.Flatpak \
  md.obsidian.Obsidian
```

Reopen Obsidian.

This is necessary because `rsync` and the publishing script need to run on Nobara itself rather than inside the Flatpak sandbox.

---

# 11. Create the publishing command in Shell commands

Go to:

**Settings → Shell commands → New shell command**

Use this command:

```bash
flatpak-spawn --host bash -lc 'cd "$HOME/Projects/PKM" && ./scripts/publish-public.sh'
```

Do **not** use the simpler version:

```bash
cd "$HOME/Projects/PKM" && ./scripts/publish-public.sh
```

inside Flatpak Obsidian, because `rsync` may not be available in the sandbox.

Click the command's **gear ⚙️**.

Under **General**, set the alias to:

```text
Publish Website to GitHub
```

---

# 12. Make publishing quiet

The Git command may otherwise produce a little popup such as:

```text
[0]: From https://github.com/...
```

`[0]` means success, but we don't need to see it every time.

In the command's **Output** settings, set normal output notifications to **Ignore**.

If there is a separate stdout/stderr setting, set both to:

```text
Ignore
```

Then publishing becomes effectively silent.

---

# 13. Assign Ctrl + Alt + P

The easiest way is:

**Settings → Hotkeys**

Search:

```text
Publish Website to GitHub
```

Assign:

**Ctrl + Alt + P**

If the UI gives you trouble, we can use the same Terminal method we used on the Office PC to edit `.obsidian/hotkeys.json`.

Also make sure KDE does **not** have an old global `Ctrl+Alt+P` shortcut that launches Konsole. We want this shortcut assigned inside Obsidian only.

---

# 14. Add the Commander ribbon button

Open:

**Settings → Commander → Ribbon**

Choose **Add Command**.

Search for:

```text
Publish Website to GitHub
```

Select the Shell commands entry.

Choose an icon such as:

- upload
    
- cloud upload
    
- arrow up
    
- Git branch
    

The new icon should appear in Obsidian's **left ribbon**.

---

# 15. Final Home PC setup

You will then have three ways to publish:

**Keyboard**

```text
Ctrl + Alt + P
```

**Ribbon**

Click the Commander **Publish** icon.

**Command Palette**

```text
Ctrl + P
→ Publish Website to GitHub
```

All three execute:

```bash
flatpak-spawn --host bash -lc 'cd "$HOME/Projects/PKM" && ./scripts/publish-public.sh'
```

which ultimately performs:

```text
Pull latest GitHub v5
        ↓
Read Home PC 60 Public/Website
        ↓
rsync into ~/Projects/PKM/content
        ↓
Stage only content/
        ↓
Commit public-note changes
        ↓
Push v5
        ↓
GitHub Pages / Quartz rebuild
```

Most importantly, **your private Obsidian material remains outside the publishing workflow**. Only the contents of:

```text
60 Public/Website
```

are copied into the Quartz website repository.

I would keep this tutorial as your canonical **“New PC / Obsidian GitHub Publishing Setup”** procedure, because the same process can be reused on either machine; normally the only machine-specific item is the external-drive `SOURCE=` path.