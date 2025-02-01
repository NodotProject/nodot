#!/bin/bash

print "::group::Run GUT"
godot -s addons/gut/gut_cmdln.gd -d --path "$PWD" -gdir="res://test" -gprefix="" -ginclude_subdirs -gexit
print "::endgroup::"