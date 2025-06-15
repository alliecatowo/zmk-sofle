#!/bin/bash

# Build and Bond Dongle Script
# This script triggers a GitHub Actions build and provides instructions for bonding

set -e

echo "Starting dongle build and bond process..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Warning: You have uncommitted changes"
    echo "   These changes will be included in the build"
    echo "   Press Enter to continue or Ctrl+C to abort"
    read -r
fi

# Trigger build by pushing to GitHub
echo "Pushing to GitHub to trigger build..."
git push origin main

echo "Build triggered successfully!"
echo ""
echo "Next steps:"
REPO_URL=$(git config --get remote.origin.url)
REPO_PATH=$(echo "$REPO_URL" | sed 's#.*github.com[:/]\\([^/]*\\/[^/.]*\\).*#\\1#')
echo "1. Go to: https://github.com/$REPO_PATH/actions"
echo "2. Wait for the build to complete (usually 2-3 minutes)"
echo "3. Download the firmware from the Artifacts section"
echo ""
echo "Bonding instructions:"
echo "1. Flash the dongle first: alliecatkeeb_dongle_central.uf2"
echo "2. Flash left half: alliecatkeeb_left_peripheral.uf2"
echo "3. Flash right half: alliecatkeeb_right_peripheral.uf2"
echo "4. The halves will automatically bond to the dongle"
echo ""
echo "Tip: If bonding fails, use the settings_reset firmware first"
