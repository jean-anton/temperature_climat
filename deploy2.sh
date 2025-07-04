#!/bin/bash

set -e

echo "🛠️ Building Flutter web..."
flutter build web

# Modifier <base href="/">
INDEX_FILE="build/web/index.html"
echo "🔧 Modifying <base href> in $INDEX_FILE..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD sed)
    sed -i '' 's|<base href="/[^"]*">|<base href="/temperature_climat/">|' "$INDEX_FILE"
else
    # Linux (GNU sed)
    sed -i 's|<base href="/[^"]*">|<base href="/temperature_climat/">|' "$INDEX_FILE"
fi

cd build/web

# Check if SSH key is configured
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH authentication configured"
    REPO_URL="git@github.com:jean-anton/temperature_climat.git"
else
    echo "⚠️  SSH not configured, using HTTPS (will prompt for credentials)"
    REPO_URL="https://github.com/jean-anton/temperature_climat.git"
fi

if [ ! -d ".git" ]; then
    echo "🔧 Initializing new Git repo in build/web..."
    git init
    git remote add origin "$REPO_URL"
    git checkout -b gh-pages
else
    echo "🔁 Reusing existing Git repo..."
    git checkout gh-pages || git checkout -b gh-pages
    # Update remote URL in case it changed
    git remote set-url origin "$REPO_URL"
fi

echo "➕ Adding files..."
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo "ℹ️ No changes to commit"
else
    COMMIT_MSG="Update deployment - $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"

    echo "🚀 Pushing to gh-pages..."
    git push -f origin gh-pages

    echo "✅ Deploy complete!"
fi