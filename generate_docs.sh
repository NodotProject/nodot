#!/bin/bash

# npm i -g fcingolani/GDScriptify
# npm i -g gdscriptify
# npm i -g markdown-folder-to-html
rm -rf docs
gdscriptify -o docs/src
mv docs/src/addons/nodot/* docs/src
rm -rf docs/src/addons
node scripts/cleanup_docs_raw.js
markdown-folder-to-html docs/src
mv docs/_src/* docs
rm -rf docs/_src
cp scripts/images docs/images