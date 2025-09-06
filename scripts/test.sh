#!/bin/bash
# echo "Import project"
# godot --headless --import .

echo "Run vest"
godot --headless -s "addons/vest/cli/vest-cli.gd" \
      --vest-report-format tap --vest-report-file "vest.log" \
      --vest-glob "res://tests/unit/**/*.test.gd"
echo "Done"