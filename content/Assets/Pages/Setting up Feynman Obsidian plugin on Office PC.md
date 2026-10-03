---
title: Feynman + Obsidian Setup on CYXPCO
aliases:
  - Feynman Office PC Setup
tags:
  - Feynman
  - Obsidian
  - Docker
  - Nobara
  - CYXPCO
status: active
banner: https://wallpapercave.com/wp/wp4906049.jpg
---
# Setting up Feynman Obsidian plugin on Office PC

> [!important]
> This tutorial reproduces the working setup from **CYXPCH** on the office PC **CYXPCO**, including the workarounds that were necessary for the current Feynman Obsidian plugin/server combination.
>
> The final working stack is:
>
> **KDE launcher → Obsidian AppImage → `DOCKER_DEFAULT_PLATFORM=linux/arm64` → persistent colon-free vault alias → Docker → `icariansystems/feynman-server:v1.0.0` → ChatGPT Plus/Pro OAuth → alphaXiv API-key authentication**

## 1. What this setup works around

The current setup has several important quirks:

1. **Flatpak Obsidian cannot reach the Docker socket reliably for this plugin.** Use the official Obsidian AppImage instead.
2. `icariansystems/feynman-server:v1.0.0` is currently published as **ARM64 only**, while CYXPCO is AMD64/x86-64. Docker therefore needs ARM64 emulation and `DOCKER_DEFAULT_PLATFORM=linux/arm64`.
3. External-drive mount paths such as `/mnt/usb-...-0:0-part1/...` contain `:`. The Feynman plugin uses Docker `-v source:destination` syntax, so a colon in the host path breaks the volume specification. A colon-free bind mount such as `/home/ben/FeynmanVault` solves this.
4. The alphaXiv OAuth flow bundled with `@companion-ai/alpha-hub 0.1.3` points to `clerk.alphaxiv.org`, which currently does not resolve. Use an **alphaXiv API key** instead.
5. The Obsidian plugin's **Active model** dropdown may remain on `Loading...`. In `feynman-server:v1.0.0`, `/v1/manifest` intentionally returns an empty `models` array. The actual CLI model registry still works.
6. The Feynman CLI launcher in this Docker image expects a missing compiled `dist/index.js`. Use the included `tsx` runner directly when checking or changing models.

---

# Part A — Identify the office vault

## 2. Find the actual Obsidian vault path

Do not assume the CYXPCH path is the same on CYXPCO.

Run:

```bash
find /mnt -type d -name .obsidian -print 2>/dev/null | sed 's#/.obsidian$##'
```

Identify the **office vault you actually open in Obsidian**.

Then set a shell variable for the remainder of the setup. Replace the example path:

```bash
VAULT="/mnt/REPLACE-WITH-CYXPCO-OFFICE-DRIVE/Obsidian"
```

Verify:

```bash
test -d "$VAULT/.obsidian" && echo "Vault found: $VAULT"
```

Also determine the underlying filesystem mount:

```bash
findmnt -T "$VAULT" -no SOURCE,TARGET,FSTYPE
```

Keep the `TARGET` value handy. It will be used when making the bind mount persistent.

---

# Part B — Verify Docker first

## 3. Confirm Docker is installed and usable without `sudo`

Run:

```bash
docker --version
docker ps
```

The important point is that `docker ps` works **without `sudo`**.

If it says permission denied, add your account to the Docker group:

```bash
sudo usermod -aG docker "$USER"
```

Then log out and log back in before continuing.

## 4. Verify ARM64 emulation

Run:

```bash
docker run --rm --platform linux/arm64 alpine uname -m
```

Expected result:

```text
aarch64
```

If you get `aarch64`, ARM64 emulation is already working.

> [!warning]
> Do not continue with Feynman until this command works.

## 5. Inspect and pre-pull the Feynman image

Optional inspection:

```bash
docker buildx imagetools inspect icariansystems/feynman-server:v1.0.0
```

At the time this setup was tested, the runnable manifest was:

```text
linux/arm64
```

Pre-pull the ARM64 image explicitly:

```bash
docker pull --platform linux/arm64 icariansystems/feynman-server:v1.0.0
```

Verify:

```bash
docker image inspect icariansystems/feynman-server:v1.0.0 \
  --format '{{.Os}}/{{.Architecture}}'
```

Expected:

```text
linux/arm64
```

---

# Part C — Replace Flatpak Obsidian with AppImage

## 6. Check whether Obsidian is currently Flatpak

Run:

```bash
flatpak list | grep -i obsidian
```

If you see something like:

```text
Obsidian    md.obsidian.Obsidian
```

you are using the Flatpak build.

## 7. Download the official Obsidian AppImage

Download the current official Linux AppImage from the Obsidian website.

After downloading it, create a dedicated Applications directory:

```bash
mkdir -p "$HOME/Applications"
```

Move or copy the downloaded AppImage there and give it a fixed filename:

```bash
mv "$HOME"/Downloads/Obsidian*.AppImage \
  "$HOME/Applications/Obsidian.AppImage"
```

Make it executable:

```bash
chmod +x "$HOME/Applications/Obsidian.AppImage"
```

Test it:

```bash
"$HOME/Applications/Obsidian.AppImage"
```

Open the existing CYXPCO vault.

## 8. Remove the Flatpak copy

Once the AppImage opens the correct vault successfully, quit Obsidian.

Check whether the Flatpak is installed system-wide:

```bash
flatpak list --system | grep -i obsidian
```

If it is system-wide:

```bash
sudo flatpak uninstall md.obsidian.Obsidian
```

If it is a user Flatpak instead:

```bash
flatpak uninstall md.obsidian.Obsidian
```

Do **not** add `--delete-data`.

If a graphical uninstaller asks whether to delete user data, choose **Keep User Data** during this transition.

---

# Part D — Create the permanent KDE Obsidian launcher

## 9. Create the wrapper

The wrapper forces Docker commands launched by the Feynman plugin to default to ARM64.

Run:

```bash
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/obsidian-feynman" <<'EOF'
#!/usr/bin/env bash

export DOCKER_DEFAULT_PLATFORM=linux/arm64

exec "$HOME/Applications/Obsidian.AppImage" "$@"
EOF

chmod +x "$HOME/.local/bin/obsidian-feynman"
```

Test:

```bash
"$HOME/.local/bin/obsidian-feynman"
```

Quit Obsidian again after confirming it launches.

## 10. Create the KDE application entry

Run:

```bash
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/obsidian-feynman.desktop" <<'EOF'
[Desktop Entry]
Name=Obsidian
Comment=Obsidian AppImage with Docker support for Feynman
Exec=/home/ben/.local/bin/obsidian-feynman %U
Terminal=false
Type=Application
Categories=Office;Utility;
StartupNotify=true
EOF
```

Refresh the desktop database:

```bash
update-desktop-database "$HOME/.local/share/applications"
```

You should now be able to search for **Obsidian** in KDE and launch it normally.

After it appears, you can pin it to the KDE Task Manager/Favorites.

> [!important]
> From now on, launch Obsidian through this KDE entry rather than by double-clicking the AppImage directly. The launcher supplies `DOCKER_DEFAULT_PLATFORM=linux/arm64`, which Feynman needs.

---

# Part E — Create a colon-free alias for the vault

## 11. Why this is necessary

A CYXPCO external-drive path may contain a segment such as:

```text
...-0:0-part1/Obsidian
```

Docker's short volume syntax is:

```text
host-path:container-path
```

The colon in `0:0-part1` can therefore be misread as another Docker volume separator.

We solve this with:

```text
/home/ben/FeynmanVault
```

## 12. Create a temporary bind mount first

Make sure Obsidian is closed.

Create the target:

```bash
sudo mkdir -p /home/ben/FeynmanVault
sudo chown ben:ben /home/ben/FeynmanVault
```

Ensure the Feynman workspace exists in the vault:

```bash
mkdir -p "$VAULT/Feynman"
```

Bind the real vault to the clean alias:

```bash
sudo mount --bind "$VAULT" /home/ben/FeynmanVault
```

Verify:

```bash
findmnt /home/ben/FeynmanVault
ls -ld /home/ben/FeynmanVault/Feynman
```

## 13. Make the bind mount persistent

First get the underlying external-drive mount target:

```bash
UNDERLYING_MOUNT=$(findmnt -T "$VAULT" -no TARGET)
echo "$UNDERLYING_MOUNT"
```

Back up `/etc/fstab`:

```bash
sudo cp /etc/fstab /etc/fstab.backup-before-feynman
```

Check that you do not already have a FeynmanVault line:

```bash
grep -n 'FeynmanVault' /etc/fstab || true
```

If no line exists, append one:

```bash
printf '%s %s none bind,x-systemd.requires-mounts-for=%s 0 0\n' \
  "$VAULT" \
  "/home/ben/FeynmanVault" \
  "$UNDERLYING_MOUNT" | sudo tee -a /etc/fstab
```

Reload and test:

```bash
sudo systemctl daemon-reload
sudo mount -a
```

If `mount -a` returns no errors, verify:

```bash
findmnt /home/ben/FeynmanVault
ls -la /home/ben/FeynmanVault/Feynman
```

> [!warning]
> If `sudo mount -a` reports an error, fix that before rebooting.

---

# Part F — Install or verify the Feynman Obsidian plugin

## 14. Open Obsidian from the new KDE launcher

Launch **Obsidian** from KDE.

If the plugin is already present because the vault is synchronized, verify:

```bash
cat "$VAULT/.obsidian/plugins/feynman-research-agent/manifest.json"
```

If it is not present, install **Feynman - AI research assistant** through Obsidian Community Plugins and enable it.

The working home-PC installation used plugin version:

```text
1.0.5
```

If CYXPCO sees a newer plugin version, do not downgrade automatically; verify whether its Docker/image behavior has changed.

---

# Part G — Configure the Feynman Docker path correctly

## 15. Set the plugin to the clean mount path

The most reliable method is to edit `data.json` **while Obsidian is completely closed**.

Quit Obsidian and verify:

```bash
pgrep -a obsidian
```

No output means it is closed.

Now run:

```bash
python3 - <<PY
import json
from pathlib import Path

p = Path("$VAULT/.obsidian/plugins/feynman-research-agent/data.json")

with p.open() as f:
    d = json.load(f)

d["backend"] = "docker"

docker = d.setdefault("docker", {})
docker["imageTag"] = "icariansystems/feynman-server:v1.0.0"
docker["hostPort"] = docker.get("hostPort", 0)
docker["vaultMountPath"] = "/home/ben/FeynmanVault/Feynman"
docker.setdefault("authToken", "")
docker.setdefault("apiKeys", {})

with p.open("w") as f:
    json.dump(d, f, indent=2)

print(json.dumps(d["docker"], indent=2))
PY
```

Verify specifically:

```bash
grep '"vaultMountPath"' \
  "$VAULT/.obsidian/plugins/feynman-research-agent/data.json"
```

Expected:

```text
"vaultMountPath": "/home/ben/FeynmanVault/Feynman",
```

---

# Part H — Start Feynman

## 16. Remove any stale failed container

Before the first clean setup on CYXPCO:

```bash
docker rm -f feynman-server 2>/dev/null || true
```

## 17. Launch Obsidian through KDE

Open the **Obsidian** KDE launcher created earlier.

Go to:

**Settings → Feynman**

Use **Set up Docker** / **Start container**.

A successful state should show something like:

```text
Container: running
http://127.0.0.1:7777
```

## 18. Verify from Terminal

Run:

```bash
docker ps -a | grep feynman
```

Then:

```bash
docker logs --tail 100 feynman-server
```

Healthy startup includes:

```text
[feynman-server] listening on http://0.0.0.0:7777
```

## 19. Make the container restart automatically

Run:

```bash
docker update --restart unless-stopped feynman-server
```

Verify:

```bash
docker inspect feynman-server \
  --format 'Restart policy: {{.HostConfig.RestartPolicy.Name}}'
```

Expected:

```text
Restart policy: unless-stopped
```

---

# Part I — Configure ChatGPT Plus/Pro

## 20. Test the local Feynman connection

In:

**Obsidian → Settings → Feynman**

click **Test connection**.

It should succeed before configuring providers.

## 21. Sign into ChatGPT Plus/Pro

Under provider authentication, find:

```text
ChatGPT Plus/Pro (Codex Subscription)
```

Click **Sign in**.

Complete the browser login.

### If the browser ends at localhost and shows `ERR_CONNECTION_REFUSED`

This happened on CYXPCH.

The browser may land on a URL similar to:

```text
http://localhost:1455/auth/callback?code=...&state=...
```

The failed page itself is not necessarily a problem.

Do this:

1. Copy the **entire callback URL** from the browser address bar.
2. Return to the Feynman sign-in dialog in Obsidian.
3. Paste the callback URL into the field labeled approximately:
   **Paste the redirect URL or auth code from your browser**
4. Click **Submit**.

> [!warning]
> Treat the callback URL as a temporary credential. Do not post it in notes, screenshots, chat messages, or public issue reports.

Afterward the provider should show:

```text
Signed in
```

## 22. Verify provider state from the server

Load the local server token without printing it:

```bash
TOKEN=$(python3 - <<'PY'
import json, os
p = os.path.expanduser("~/.feynman/secrets.json")
with open(p) as f:
    print(json.load(f)["docker"]["authToken"])
PY
)
```

Check configured providers:

```bash
curl -sS \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Feynman-Client: obsidian-plugin/1.0.5" \
  http://127.0.0.1:7777/v1/auth/configured |
python3 -m json.tool

unset TOKEN
```

Expected provider:

```text
openai-codex
```

with type:

```text
oauth
```

---

# Part J — Configure alphaXiv

## 23. Do not rely on the bundled alphaXiv browser login

On the tested setup, alpha-hub `0.1.3` tried to use:

```text
https://clerk.alphaxiv.org
```

and failed with:

```text
getaddrinfo ENOTFOUND clerk.alphaxiv.org
```

The current MCP endpoint itself was reachable:

```text
https://api.alphaxiv.org/mcp/v1
```

Therefore use an **alphaXiv API key** instead of the plugin's browser-login button.

## 24. Create an alphaXiv API key

In the alphaXiv website:

**Settings → API Keys**

Create a key. A useful label is:

```text
Feynman Obsidian CYXPCO
```

Do not paste the key into an Obsidian note.

## 25. Store the API key in Alpha Hub

Use this command. The key is entered invisibly and does not appear in shell history:

```bash
read -rsp "Paste alphaXiv API key: " ALPHAXIV_KEY
echo

printf '%s' "$ALPHAXIV_KEY" | \
docker exec -i -u feynman feynman-server node -e '
const fs = require("fs");

let key = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", d => key += d);
process.stdin.on("end", () => {
  key = key.trim();

  if (!key) {
    console.error("No key supplied.");
    process.exit(1);
  }

  const dir = "/home/feynman/.ahub";
  fs.mkdirSync(dir, { recursive: true });

  fs.writeFileSync(
    dir + "/auth.json",
    JSON.stringify({ access_token: key }, null, 2),
    { mode: 0o600 }
  );

  console.log("alphaXiv credential saved.");
});
'

unset ALPHAXIV_KEY
```

Expected:

```text
alphaXiv credential saved.
```

Verify:

```bash
docker exec feynman-server \
  /app/node_modules/.bin/alpha --json status
```

Expected:

```text
Logged in to alphaXiv
```

Verify permissions without exposing the key:

```bash
docker exec feynman-server sh -lc '
ls -l /home/feynman/.ahub/auth.json
'
```

Expected ownership/mode:

```text
-rw------- ... feynman feynman ... auth.json
```

Now return to:

**Obsidian → Settings → Feynman → alphaXiv**

and click **Refresh status**.

It should show:

```text
Signed in
```

> [!note]
> The alphaXiv credential is currently stored in the running container's `/home/feynman/.ahub`. It survives ordinary restarts and computer reboots, but if the `feynman-server` container is deleted and recreated, you may need to import the alphaXiv key again.

---

# Part K — Check the model

## 26. Ignore the Obsidian `Active model: Loading...` bug

In this server image, the manifest builder intentionally returns:

```json
"models": []
```

Therefore the Obsidian plugin may leave the model dropdown at:

```text
Loading...
```

even when the model is correctly configured.

This is a UI/server-manifest mismatch, not proof that the model is unavailable.

## 27. List models through the bundled TypeScript CLI

Do **not** run:

```text
node /app/packages/cli/bin/feynman.js ...
```

because this Docker image does not include the expected compiled:

```text
/app/packages/cli/dist/index.js
```

Instead run the CLI source with the included `tsx` runner:

```bash
docker exec -it \
  -w /app/packages/cli \
  feynman-server \
  /app/node_modules/.bin/tsx src/index.ts model list
```

On the working CYXPCH setup, this returned:

```text
◆ openai-codex
  openai-codex/gpt-5.5 (current, recommended)
  openai-codex/gpt-5.4
  openai-codex/gpt-5.1
  openai-codex/gpt-5.1-codex-max
  openai-codex/gpt-5.1-codex-mini
  openai-codex/gpt-5.2
  openai-codex/gpt-5.2-codex
  openai-codex/gpt-5.3-codex
  openai-codex/gpt-5.3-codex-spark
  openai-codex/gpt-5.4-mini
```

If `openai-codex/gpt-5.5` is already marked:

```text
(current, recommended)
```

do nothing else.

If no current model is set, set it with:

```bash
docker exec -it \
  -w /app/packages/cli \
  feynman-server \
  /app/node_modules/.bin/tsx src/index.ts \
  model set openai-codex/gpt-5.5
```

Then rerun `model list`.

---

# Part L — Final reboot test

## 28. Reboot CYXPCO

```bash
systemctl reboot
```

After logging back in:

1. Do **not** manually mount anything.
2. Open **Obsidian** from the KDE application launcher.
3. Go to **Settings → Feynman**.

Check:

```bash
findmnt /home/ben/FeynmanVault
```

Check Docker:

```bash
docker ps -a | grep feynman
```

Check restart policy:

```bash
docker inspect feynman-server \
  --format 'Restart policy: {{.HostConfig.RestartPolicy.Name}}'
```

Feynman should show:

```text
Container: running
```

and **Test connection** should succeed.

---

# Part M — First functional test

Once all infrastructure checks pass, run a small research task from Obsidian/Feynman.

Example:

```text
Find 3–5 recent research papers on generative AI in second-language writing instruction. Create a concise research note that identifies the research problem, participants/context, methods, key findings, limitations, and implications for English-language teachers. Save the note in the Feynman workspace.
```

This tests the complete chain:

```text
Obsidian
→ Feynman plugin
→ local Docker server
→ ChatGPT Plus/Pro Codex OAuth
→ alphaXiv
→ note written back into the vault
```

---

# Part N — Troubleshooting reference

## Flatpak sandbox error

Symptom:

```text
Sandboxed Obsidian (Flatpak/Snap) cannot reach the Docker socket
```

Fix:

Use the official AppImage launched through:

```text
/home/ben/.local/bin/obsidian-feynman
```

---

## Docker says no matching manifest

Symptom:

```text
no matching manifest for linux/amd64/v3
```

Fix:

```bash
docker pull --platform linux/arm64 \
  icariansystems/feynman-server:v1.0.0
```

and always launch Obsidian through the wrapper containing:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/arm64
```

---

## Docker volume error: `invalid mode`

Likely cause:

The real external-drive path contains `:`.

Fix:

Use:

```text
/home/ben/FeynmanVault/Feynman
```

as the Feynman `vaultMountPath`.

---

## Docker mount refers to pCloud or another old path

Check:

```bash
grep '"vaultMountPath"' \
  "$VAULT/.obsidian/plugins/feynman-research-agent/data.json"
```

Correct value:

```text
/home/ben/FeynmanVault/Feynman
```

If it is wrong, close Obsidian before editing `data.json`.

---

## ChatGPT browser ends at localhost and will not load

Copy the entire callback URL from the browser and paste it into Feynman's manual redirect/auth-code field.

Do not share the URL.

---

## alphaXiv shows `Login failed: fetch failed`

Do not keep retrying browser login.

Check:

```bash
docker exec feynman-server \
  /app/node_modules/.bin/alpha --json status
```

If not logged in, use the API-key procedure in **Part J**.

---

## Active model stays on `Loading...`

This is expected with `feynman-server:v1.0.0`.

Check the real registry instead:

```bash
docker exec -it \
  -w /app/packages/cli \
  feynman-server \
  /app/node_modules/.bin/tsx src/index.ts model list
```

---

## Feynman container exists but is stopped after boot

Set:

```bash
docker update --restart unless-stopped feynman-server
```

Verify:

```bash
docker inspect feynman-server \
  --format 'Restart policy: {{.HostConfig.RestartPolicy.Name}}'
```

---

# Part O — Important maintenance notes

> [!warning]
> Avoid deleting and recreating `feynman-server` unless necessary. ChatGPT OAuth and alphaXiv state currently live under `/home/feynman` inside the container and may need to be restored after a container recreation.

> [!tip]
> Normal operations such as:
>
> - rebooting CYXPCO,
> - restarting Docker,
> - restarting Obsidian,
> - restarting `feynman-server`
>
> should not require repeating provider authentication.

Useful health checks:

```bash
docker ps -a | grep feynman
```

```bash
docker logs --tail 100 feynman-server
```

```bash
findmnt /home/ben/FeynmanVault
```

```bash
docker exec feynman-server \
  /app/node_modules/.bin/alpha --json status
```

```bash
docker exec -it \
  -w /app/packages/cli \
  feynman-server \
  /app/node_modules/.bin/tsx src/index.ts model list
```

---

# CYXPCO Setup Checklist

- [ ] Confirm correct office vault path
- [ ] Docker works without `sudo`
- [ ] ARM64 emulation returns `aarch64`
- [ ] Pull `icariansystems/feynman-server:v1.0.0` as `linux/arm64`
- [ ] Install official Obsidian AppImage
- [ ] Remove Flatpak Obsidian
- [ ] Create `obsidian-feynman` wrapper
- [ ] Create KDE `.desktop` launcher
- [ ] Create `/home/ben/FeynmanVault`
- [ ] Add persistent bind mount to `/etc/fstab`
- [ ] Verify `sudo mount -a`
- [ ] Verify/install Feynman Obsidian plugin
- [ ] Set `vaultMountPath` to `/home/ben/FeynmanVault/Feynman`
- [ ] Start Feynman Docker container
- [ ] Set restart policy to `unless-stopped`
- [ ] Test connection
- [ ] Sign in to ChatGPT Plus/Pro via OAuth
- [ ] Create/import alphaXiv API key
- [ ] Refresh alphaXiv status
- [ ] Verify model through `tsx ... model list`
- [ ] Reboot CYXPCO
- [ ] Confirm bind mount, container, OAuth, alphaXiv, and model still work
- [ ] Run one small end-to-end research task
