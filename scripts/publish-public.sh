#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/Projects/PKM"

cd "$REPO"

echo "Downloading any changes from GitHub..."
git pull --rebase --autostash origin v5

echo "Copying public Obsidian files into Quartz..."
printf 'y\n' | ./scripts/sync-public.sh

echo "Preparing public files..."
git add -A content

if git diff --cached --quiet -- content; then
  echo "No new public changes were found."
  exit 0
fi

git commit \
  -m "Publish public notes $(date '+%Y-%m-%d %H:%M')" \
  -- content

echo "Uploading to GitHub..."
git push origin v5

echo
echo "Publish complete. GitHub Pages will update after deployment finishes."
