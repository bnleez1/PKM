#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="${PROJECT:-$HOME/Projects/PKM}"
CONFIG="${PKM_PUBLISH_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/pkm-publish.conf}"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ -f "$CONFIG" ]] || die "Configuration file not found: $CONFIG"

# shellcheck disable=SC1090
source "$CONFIG"

[[ -n "${VAULT:-}" ]] || die "VAULT is not defined in $CONFIG"

SOURCE="${SOURCE:-$VAULT/60 Public/Website}"
DEST="${DEST:-$PROJECT/content}"

[[ -d "$VAULT" ]] || die "Obsidian vault not found: $VAULT"
[[ -d "$SOURCE" ]] || die "Public website folder not found: $SOURCE"
[[ -d "$PROJECT/.git" ]] || die "Quartz Git repository not found: $PROJECT"

echo
echo "DRY RUN — no files have been changed"
echo
echo "Source:"
echo "$SOURCE"
echo
echo "Destination:"
echo "$DEST"
echo

rsync -avhn --delete \
    --exclude='.obsidian/' \
    --exclude='.trash/' \
    --exclude='.DS_Store' \
    --exclude='Thumbs.db' \
    --exclude='*.tmp' \
    "$SOURCE/" \
    "$DEST/"

echo
read -r -p "Mirror these files into Quartz? [y/N] " answer

case "$answer" in
    y|Y)
        ;;
    *)
        echo "Nothing was copied or deleted."
        exit 0
        ;;
esac

echo
echo "Synchronizing..."

rsync -avh --delete \
    --exclude='.obsidian/' \
    --exclude='.trash/' \
    --exclude='.DS_Store' \
    --exclude='Thumbs.db' \
    --exclude='*.tmp' \
    "$SOURCE/" \
    "$DEST/"

echo
echo "Sync complete."
echo "Nothing has been committed or pushed."
echo
git -C "$PROJECT" status --short
