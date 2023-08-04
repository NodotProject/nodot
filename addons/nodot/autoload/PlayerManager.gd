## An autoload script to manage a player
extends Node

## Triggered when a player setting is changed
signal settings_changed(settings: Dictionary)

## The current player root node
var node: Node
## Settings for the player
var settings: Dictionary = {}: set = _settings_set
## A list of all players in the game
var players: UniqueSet = UniqueSet.new()

func _settings_set(new_settings: Dictionary):
	settings = new_settings
	emit_signal("settings_changed", settings)
