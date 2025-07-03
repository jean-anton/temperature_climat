cd build/web
git init
git remote add origin https://github.com/jean-anton/temperature_climat.git
git checkout -b gh-pages
git add .
git commit -m "Deploy to gh-pages"
git push -f origin gh-pages




cd build/web
git add index.html
git commit -m "Fix base href for GitHub Pages"
git push -f origin gh-pages
