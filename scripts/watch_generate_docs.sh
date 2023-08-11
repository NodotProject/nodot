#!/bin/bash

gdscriptify2 -d addons/nodot -o docs/src
mv addons/nodot/docs/src/* docs
rm -rf addons/nodot/docs
sed -i 's/\\/\//g' docs/index.md
cp addons/nodot/icons docs -r