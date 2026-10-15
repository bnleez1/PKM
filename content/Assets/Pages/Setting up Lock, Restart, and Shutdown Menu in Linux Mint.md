---
title: Setting up Lock, Restart, and Shutdown Menu in Linux Mint
tags:
  - Linux
  - Linux_Mint
notes: []
gh-publish: true
gh-path: content/Assets/Pages
gh-published: true
gh-published-url: https://bnleez1.github.io/PKM/assets/pages/setting-up-lock-restart-and-shutdown-menu-in-linux-mint
banner: https://cdn.pixabay.com/photo/2022/09/27/19/44/ai-generated-7483569_1280.jpg
---
# Setting up Lock, Restart, and Shutdown Menu in Linux Mint
Run this in Terminal—**no sudo needed**:

</> Bash`

```
python3 /home/ben/Documents/Codex/2026-10-15/set/outputs/system-menu.py --install
```

It registers **Super + Shift + L** for a popup containing **Lock, Suspend, Log out, Restart, and Shut down**. Press **Esc** to dismiss it.

The installer checks for shortcut conflicts. I couldn’t install it directly because the sandbox error persists.