#!/bin/bash

# Script to download the latest firmware from GitHub Actions

set -e

echo "Downloading latest firmware from GitHub Actions..."

# Get the repository info
REPO=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/.]*\).*/\1/')
echo "Repository: $REPO"

# Get the latest successful workflow run
echo "Fetching latest successful build..."
LATEST_RUN=$(curl -s "https://api.github.com/repos/$REPO/actions/runs?status=success&per_page=1" | grep -o '"id": [0-9]*' | head -1 | awk '{print $2}')

if [ -z "$LATEST_RUN" ]; then
    echo "Error: No successful builds found"
    echo "Please check: https://github.com/$REPO/actions"
    exit 1
fi

echo "Latest build ID: $LATEST_RUN"

# Create download directory
mkdir -p firmware-downloads
cd firmware-downloads

# Download artifacts
echo "Downloading artifacts..."
echo "Please visit: https://github.com/$REPO/actions/runs/$LATEST_RUN"
echo ""
echo "Click on each artifact to download:"
echo "- For Standard Mode: alliecat_keeb_studio_left + alliecat_keeb_standard_right"
echo "- For Dongle Mode: alliecat_keeb_dongle_central + alliecat_keeb_left_peripheral + alliecat_keeb_right_peripheral"
echo "- For Reset: settings_reset_left + settings_reset_right + settings_reset_dongle"
echo ""
echo "Note: GitHub requires authentication to download artifacts via API"
