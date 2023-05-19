## An autoload script to manage a player
extends Node

## Triggered when a player setting is changed
signal settings_changed(settings: Dictionary)

## The player root node
var node: Node
## Settings for the player
var settings: Dictionary = {}: set = _settings_set

func _settings_set(new_settings: Dictionary):
	settings = new_settings
	emit_signal("settings_changed", settings)
