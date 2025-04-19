#!/bin/bash

# auto-pull-all-repos.sh — clone or pull all repos for a GitHub org or user

# === Configuration ===
GITHUB_USER=""          # Your GitHub username (if pulling user repos)
GITHUB_ORG=""           # Organization name (if pulling org repos)
TOKEN=""                # Your GitHub personal access token

# === Prepare workspace ===
TARGET_DIR="${GITHUB_ORG:-$GITHUB_USER}-repos"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

# === Pagination & API URL ===
PAGE=1
PER_PAGE=100
if [[ -n "$GITHUB_ORG" ]]; then
  API_URL="https://api.github.com/orgs/$GITHUB_ORG/repos"
else
  API_URL="https://api.github.com/users/$GITHUB_USER/repos"
fi

# === Fetch, clone or pull ===
while true; do
  echo "Fetching page $PAGE..."
  RESPONSE=$(curl -s -H "Authorization: token $TOKEN" \
    "$API_URL?per_page=$PER_PAGE&page=$PAGE")

  # count repos on this page
  COUNT=$(echo "$RESPONSE" | jq 'length')
  if [[ $COUNT -eq 0 ]]; then
    echo "No more repositories to process."
    break
  fi

  # extract SSH URLs
  REPOS=$(echo "$RESPONSE" | jq -r '.[].ssh_url')

  for REPO_URL in $REPOS; do
    REPO_DIR=$(basename "$REPO_URL" .git)
    if [[ -d "$REPO_DIR" ]]; then
      echo "↻ Updating existing repo: $REPO_DIR"
      cd "$REPO_DIR" && git pull --ff-only && cd ..
    else
      echo "⬇️  Cloning new repo: $REPO_DIR"
      git clone "$REPO_URL"
    fi
  done

  ((PAGE++))
done

echo "✅ All repositories are up to date."
