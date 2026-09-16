#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="${PROJECT:-$HOME/Projects/PKM}"
BRANCH="${BRANCH:-v5}"
REMOTE="${REMOTE:-origin}"
CONFIG="${PKM_PUBLISH_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/pkm-publish.conf}"

die() {
    echo
    echo "ERROR: $*" >&2
    exit 1
}

echo
echo "=========================================="
echo "       PKM / QUARTZ PUBLISHER"
echo "=========================================="

# ------------------------------------------------------------
# Local machine configuration
# ------------------------------------------------------------

[[ -f "$CONFIG" ]] || die "Configuration file not found: $CONFIG"

# shellcheck disable=SC1090
source "$CONFIG"

[[ -n "${VAULT:-}" ]] || die "VAULT is not defined in $CONFIG"

SOURCE="${SOURCE:-$VAULT/60 Public/Website}"
DEST="${DEST:-$PROJECT/content}"

[[ -d "$VAULT" ]] || die "Obsidian vault not found: $VAULT"
[[ -d "$SOURCE" ]] || die "Public website folder not found: $SOURCE"
[[ -d "$PROJECT/.git" ]] || die "Quartz repository not found: $PROJECT"

cd "$PROJECT"

echo
echo "Computer:    $(hostname)"
echo "Vault:       $VAULT"
echo "Source:      $SOURCE"
echo "Repository:  $PROJECT"
echo "Branch:      $BRANCH"
echo

# ------------------------------------------------------------
# Make sure this is the correct branch
# ------------------------------------------------------------

CURRENT_BRANCH="$(git branch --show-current)"

[[ "$CURRENT_BRANCH" == "$BRANCH" ]] ||
    die "Expected branch '$BRANCH', but currently on '$CURRENT_BRANCH'."

# ------------------------------------------------------------
# Protect hand-edited Quartz changes
# ------------------------------------------------------------

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Tracked repository changes are present:"
    git status --short
    die "Commit, restore, or otherwise resolve tracked Quartz changes before publishing."
fi

# ------------------------------------------------------------
# Fetch GitHub
# ------------------------------------------------------------

echo "Checking GitHub for newer changes..."
git fetch "$REMOTE" "$BRANCH"

REMOTE_REF="$REMOTE/$BRANCH"

# ------------------------------------------------------------
# Determine whether local-only commits are disposable
# publication commits.
#
# Publication commits are generated from Obsidian and can
# safely be regenerated. Ordinary Quartz/code commits are NOT
# discarded automatically.
# ------------------------------------------------------------

only_publish_commits() {
    local commits
    commits="$(git log --format='%s' "$REMOTE_REF"..HEAD 2>/dev/null || true)"

    [[ -n "$commits" ]] || return 1

    while IFS= read -r subject; do
        [[ "$subject" == "Publish public notes "* ]] || return 1
    done <<< "$commits"

    return 0
}

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "$REMOTE_REF")"

if [[ "$LOCAL_HEAD" == "$REMOTE_HEAD" ]]; then
    echo "Local repository is already synchronized with GitHub."

elif git merge-base --is-ancestor HEAD "$REMOTE_REF"; then
    echo "GitHub is ahead. Fast-forwarding..."
    git merge --ff-only "$REMOTE_REF"

elif git merge-base --is-ancestor "$REMOTE_REF" HEAD; then
    if only_publish_commits; then
        echo
        echo "Found stale local publication commit(s)."
        echo "They will be regenerated from the Obsidian vault."
        git reset --hard "$REMOTE_REF"
    else
        echo
        git log --oneline "$REMOTE_REF"..HEAD
        die "Local non-publication commits have not been pushed. Resolve them before publishing."
    fi

else
    if only_publish_commits; then
        echo
        echo "Local publication history diverged from GitHub."
        echo "Discarding stale generated publication commit(s)."
        echo "The authoritative notes remain in the Obsidian vault."
        git reset --hard "$REMOTE_REF"
    else
        echo
        echo "Local and remote histories have diverged:"
        git log --left-right --graph --oneline HEAD..."$REMOTE_REF"
        die "Non-publication commits are involved. Manual Git resolution is required."
    fi
fi

# ------------------------------------------------------------
# Synchronize Obsidian public folder into Quartz
# ------------------------------------------------------------

sync_content() {
    echo
    echo "Synchronizing Obsidian → Quartz..."

    rsync -avh --delete \
        --exclude='.obsidian/' \
        --exclude='.trash/' \
        --exclude='.DS_Store' \
        --exclude='Thumbs.db' \
        --exclude='*.tmp' \
        "$SOURCE/" \
        "$DEST/"
}

sync_content

git add -A -- content

if git diff --cached --quiet; then
    echo
    echo "No public changes to publish."
    echo "Quartz is already current."
    exit 0
fi

echo
echo "Changes to publish:"
git status --short

git commit -m "Publish public notes $(date '+%Y-%m-%d %H:%M')"

# ------------------------------------------------------------
# Push.
#
# If another computer updates v5 between our fetch and push,
# discard ONLY our generated publication commit, update from
# GitHub, regenerate content from Obsidian, and try again.
# ------------------------------------------------------------

for attempt in 1 2 3; do

    echo
    echo "Push attempt $attempt of 3..."

    if git push "$REMOTE" "$BRANCH"; then
        echo
        echo "=========================================="
        echo " Published successfully to GitHub."
        echo "=========================================="
        exit 0
    fi

    echo
    echo "Push was rejected or GitHub changed."
    echo "Checking remote state..."

    if ! git fetch "$REMOTE" "$BRANCH"; then
        echo
        echo "Could not contact GitHub."
        echo "Your Obsidian source files are safe."
        echo "Run the publisher again when the connection is available."
        exit 1
    fi

    if ! only_publish_commits; then
        die "Unexpected local non-publication commit detected after failed push."
    fi

    echo "Removing stale generated publication commit..."
    git reset --hard "$REMOTE_REF"

    echo "Regenerating publication from current Obsidian source..."
    sync_content

    git add -A -- content

    if git diff --cached --quiet; then
        echo
        echo "GitHub already contains the same public content."
        echo "Nothing further needs to be pushed."
        exit 0
    fi

    git commit -m "Publish public notes $(date '+%Y-%m-%d %H:%M')"
done

echo
echo "GitHub changed repeatedly during publication."

git fetch "$REMOTE" "$BRANCH" || true

if only_publish_commits; then
    git reset --hard "$REMOTE_REF"
fi

die "Publication was not completed. Your authoritative files remain safely in Obsidian. Run the publisher again."
