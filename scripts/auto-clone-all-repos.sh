#!/bin/bash

# Variables
GITHUB_USER=""          # Replace with your GitHub username
GITHUB_ORG=""  # Organization name
TOKEN=""        # Your token

# Create a directory to store all repositories
mkdir -p "$GITHUB_ORG-repos"
cd "$GITHUB_ORG-repos"

# Fetch all repository names with pagination support
page=1
while true; do
    echo "Fetching repositories page $page..."
    
    # Get repositories for current page
    response=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/orgs/$GITHUB_ORG/repos?per_page=100&page=$page")
    
    # Debug: Print the first part of the response to verify it's working
    echo "API Response sample:"
    echo "$response" | jq -r '. | length'
    
    # Extract SSH URLs instead of HTTPS URLs
    repos=$(echo "$response" | jq -r '.[].ssh_url')
    
    # Break if no repositories on this page
    if [ -z "$repos" ] || [ "$repos" == "" ]; then
        echo "No repositories found or end of pagination reached."
        break
    fi
    
    # Clone all repositories on this page using SSH
    for repo in $repos; do
        echo "Cloning $repo..."
        git clone "$repo"
    done
    
    # Next page
    page=$((page+1))
done

echo "Cloning complete!"