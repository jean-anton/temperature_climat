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

if [ ! -d ".git" ]; then
    echo "🔧 Initializing new Git repo in build/web..."
    git init
    git remote add origin https://github.com/jean-anton/temperature_climat.git
    git checkout -b gh-pages
else
    echo "🔁 Reusing existing Git repo..."
    git checkout gh-pages || git checkout -b gh-pages
fi

echo "➕ Adding files..."
git add .

COMMIT_MSG="Update deployment - $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG"

echo "🚀 Pushing to gh-pages..."
git push -f origin gh-pages

echo "✅ Deploy complete!"
