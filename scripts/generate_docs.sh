#!/bin/bash

# npm i -g krazyjakee/GDScriptify2
# npm i -g markdown-folder-to-html
rm -rf docs
gdscriptify2 -d addons/nodot -o docs/src
mv addons/nodot/docs .
sed -i 's/\\/\//g' docs/src/index.md
markdown-folder-to-html docs/src
mv docs/_src/* docs
rm -rf docs/_src