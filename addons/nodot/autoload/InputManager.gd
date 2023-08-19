## Manage input logic
extends Node

var mouse_sensitivity: float = 0.5

var INPUT_KEY_SOURCE = {
	KEYBOARD = 0,
	MOUSE = 1,
	JOYPAD = 2
}

func _ready():
	if SaveManager.config.hasItem("mouse_sensitivity"):
		mouse_sensitivity = SaveManager.config.getItem("mouse_sensitivity")
	if SaveManager.config.hasItem("input_actions"):
		var input_actions = SaveManager.config.getItem("input_actions")
		for action_name in input_actions:
			if InputMap.has_action(action_name):
				InputMap.action_erase_events(action_name)
			for key_code in input_actions[action_name]:
				add_action(action_name, key_code[1], key_code[0])

func register_action(action_name: String, default_key: int = -1, input_source: int = 0) -> void:
	if InputMap.has_action(action_name):
		return
		
	InputMap.add_action(action_name)
	add_action(action_name, default_key, input_source)
	
func add_action(action_name: String, key_code: int, input_source: int):
	if !InputMap.has_action(action_name):
		return
		
	match input_source:
		0: add_action_event_key(action_name, key_code)
		1: add_action_event_mouse(action_name, key_code)
		1: add_action_event_joypad(action_name, key_code)
		
func add_action_event_key(action_name: String, key: int = -1):
	if key > 0:
		var input_key = InputEventKey.new()
		input_key.keycode = key
		InputMap.action_add_event(action_name, input_key)
		
func add_action_event_mouse(action_name: String, button_index: int = -1):
	if button_index >= 0:
		var input_key = InputEventMouseButton.new()
		input_key.button_index = button_index
		InputMap.action_add_event(action_name, input_key)
		
func add_action_event_joypad(action_name: String, button_index: int = -1):
	if button_index >= 0:
		var input_key = InputEventJoypadButton.new()
		input_key.button_index = button_index
		InputMap.action_add_event(action_name, input_key)
		
func remove_action(action_name: String, key: String):
	if !InputMap.has_action(action_name):
		return
	
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event.as_text() == key:
			InputMap.action_erase_event(action_name, event)
			break

func get_action_key(action: String) -> String:
	var evs = InputMap.action_get_events(action)
	if evs.size() > 0:
		var ev = evs[0]
		var key = ev.as_text()
		return key
	return ""

func save_config():
	SaveManager.config.setItem("mouse_sensitivity", mouse_sensitivity)
	
	var input_actions = {}
	var actions = InputMap.get_actions()
	for action_name in actions:
		if action_name.begins_with("ui_") or action_name == "escape":
			continue
		
		# An array of tuples [INPUT_KEY_SOURCE, key_code]
		var key_codes = []
		for event in InputMap.action_get_events(action_name):
			if event is InputEventKey:
				key_codes.append([0, event.keycode])
			if event is InputEventMouseButton:
				key_codes.append([1, event.button_index])
			if event is InputEventJoypadButton:
				key_codes.append([2, event.button_index])
		input_actions[action_name] = key_codes
	SaveManager.config.setItem("input_actions", input_actions)
	SaveManager.save_config()
