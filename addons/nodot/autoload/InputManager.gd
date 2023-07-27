## Manage input logic
extends Node

var mouse_sensitivity: float = 0.5

func register_action(action_name: String, default_key: int = -1) -> void:
	if InputMap.has_action(action_name):
		return
		
	InputMap.add_action(action_name)
	add_action(action_name, default_key)
		
func add_action(action_name: String, key: int = -1):
	if key >= 0:
		var input_key = InputEventKey.new()
		input_key.keycode = key
		InputMap.action_add_event(action_name, input_key)
		
func remove_action(action_name: String, key: String):
	if !InputMap.has_action(action_name):
		return
	
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event.as_text() == key:
			InputMap.action_erase_event(action_name, event)
			break

func get_action_key(action: String):
	var ev = InputMap.action_get_events(action)[0]
	var key = ev.as_text()
	return key
