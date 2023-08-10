#!/bin/bash

# npm i -g krazyjakee/GDScriptify2
# npm i -g docsify-cli
rm -rf docs
docsify init ./docs
gdscriptify2 -d addons/nodot -o docs/src
mv addons/nodot/docs/src/* docs
rm -rf addons/nodot/docs
sed -i 's/\\/\//g' docs/index.md
cp scripts/_sidebar.md docs/_sidebar.md
cp scripts/index.html docs/index.html
cp logo.png docs/logo.png
cp addons/nodot/icons docs/icons -r