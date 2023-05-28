## Manage input logic
extends Node

## Is input enabled
@export var enabled := true

func register_action(action_name: String, default_key: int = -1) -> void:
	if InputMap.has_action(action_name):
		return
		
	InputMap.add_action(action_name)
	if default_key >= 0:
		var input_key = InputEventKey.new()
		input_key.keycode = default_key
		InputMap.action_add_event(action_name, input_key)

## Disable input
func disable() -> void:
	enabled = false

## Enable input
func enable() -> void:
	enabled = true
