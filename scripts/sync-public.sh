#!/usr/bin/env bash
set -Eeuo pipefail

VAULT="/mnt/usb-SanDisk_Extreme_55AE_323432373153343031333038-0:0-part1/Obsidian"
SOURCE="$VAULT/60 Public/Website"
PROJECT="$HOME/Projects/PKM"
DESTINATION="$PROJECT/content"

if [[ ! -d "$VAULT" ]]; then
  echo "STOP: The Obsidian vault is not mounted at:"
  echo "$VAULT"
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "STOP: The curated website folder does not exist:"
  echo "$SOURCE"
  exit 1
fi

if [[ ! -d "$PROJECT/.git" ]]; then
  echo "STOP: The Quartz Git repository was not found:"
  echo "$PROJECT"
  exit 1
fi

mkdir -p "$DESTINATION"

echo
echo "DRY RUN — review what would be copied or removed"
echo "Source:      $SOURCE"
echo "Destination: $DESTINATION"
echo

rsync -avhn --delete \
  --exclude='.obsidian/' \
  --exclude='.trash/' \
  --exclude='.DS_Store' \
  --exclude='Thumbs.db' \
  --exclude='*.tmp' \
  "$SOURCE/" "$DESTINATION/"

echo
read -r -p "Mirror these public files into Quartz? [y/N] " REPLY

if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Cancelled. Nothing was copied or deleted."
  exit 0
fi

rsync -avh --delete \
  --exclude='.obsidian/' \
  --exclude='.trash/' \
  --exclude='.DS_Store' \
  --exclude='Thumbs.db' \
  --exclude='*.tmp' \
  "$SOURCE/" "$DESTINATION/"

echo
echo "Mirror complete. Nothing has been pushed to GitHub yet."
echo "Review the Git changes shown below:"
git -C "$PROJECT" status --short

