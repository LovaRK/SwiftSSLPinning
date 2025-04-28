#!/bin/bash

# This script helps set up your SwiftSSLPinning package on GitHub
# Usage: ./github_setup.sh <your-github-username>

if [ -z "$1" ]; then
  echo "Error: GitHub username not provided"
  echo "Usage: ./github_setup.sh <your-github-username>"
  exit 1
fi

GITHUB_USERNAME=$1
REPO_NAME="SwiftSSLPinning"

echo "Setting up $REPO_NAME for GitHub user: $GITHUB_USERNAME"

# Add the remote repository
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# Push the code to GitHub
git push -u origin main

echo "Done! Your repository has been pushed to GitHub."
echo "You can now access it at: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "To use this package in other projects, add the following to your Package.swift:"
echo "dependencies: ["
echo "    .package(url: \"https://github.com/$GITHUB_USERNAME/$REPO_NAME.git\", from: \"1.0.0\")"
echo "]" 