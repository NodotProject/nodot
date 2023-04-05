#!/bin/bash

# npm i -g krazyjakee/GDScriptify2
# npm i -g markdown-folder-to-html
rm -rf docs/src
rm -rf docs/addons
gdscriptify2 -o docs/src
sed -i 's/\\/\//g' docs/src/index.md
markdown-folder-to-html docs/src
mv docs/_src/* docs
rm -rf docs/_src