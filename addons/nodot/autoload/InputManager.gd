## Manage input logic
extends Node

signal input_actions_update

var mouse_sensitivity: float = 0.5
var default_input_actions: Dictionary
var INPUT_KEY_SOURCE = {
	KEYBOARD = 0,
	MOUSE = 1,
	JOYPAD = 2,
	JOYPAD_MOTION = 3
}

func _ready():
	default_input_actions = get_all_input_actions()
	if SaveManager.config.hasItem("mouse_sensitivity"):
		mouse_sensitivity = SaveManager.config.getItem("mouse_sensitivity")
	if SaveManager.config.hasItem("input_actions"):
		var input_actions = SaveManager.config.getItem("input_actions")
		set_all_input_actions(input_actions)

func register_action(action_name: String, default_key: int = -1, input_source: int = 0, value: float = 0.0) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	add_action(action_name, default_key, input_source, value)
	
func add_action(action_name: String, key_code: int, input_source: int, value: float = 0.0):
	if !InputMap.has_action(action_name):
		return
		
	match input_source:
		0: add_action_event_key(action_name, key_code)
		1: add_action_event_mouse(action_name, key_code)
		2: add_action_event_joypad(action_name, key_code)
		3: add_action_event_joypad_motion(action_name, value, key_code)
		
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

func add_action_event_joypad_motion(action_name: String, axis_value: float, axis: int = -1):
	var input_key = InputEventJoypadMotion.new()
	input_key.axis = axis
	input_key.axis_value = axis_value
	InputMap.action_add_event(action_name, input_key)
		
func remove_action(action_name: String, key: String):
	if !InputMap.has_action(action_name):
		return
	
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event.as_text() == key:
			InputMap.action_erase_event(action_name, event)
			break
			
	emit_signal("input_actions_update")

func get_action_key(action: String) -> String:
	var evs = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventKey:
			var text = ev.as_text()
			return text
	return ""
	
func get_action_joy(action: String) -> String:
	var evs = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			return ev.as_text()
	return ""

func save_config():
	SaveManager.config.setItem("mouse_sensitivity", mouse_sensitivity)
	var input_actions = get_all_input_actions()
	SaveManager.config.setItem("input_actions", input_actions)
	SaveManager.save_config()
	emit_signal("input_actions_update")

func reset_to_defaults():
	set_all_input_actions(default_input_actions)

func set_all_input_actions(input_actions: Dictionary):
	for action_name in input_actions:
		if InputMap.has_action(action_name):
			InputMap.action_erase_events(action_name)
		for key_code in input_actions[action_name]:
			var value = key_code[2] if key_code.size() > 2 else 0
			add_action(action_name, key_code[1], key_code[0], value)
	emit_signal("input_actions_update")
				
func get_all_input_actions() -> Dictionary:
	var input_actions = {}
	var actions = InputMap.get_actions()
	for action_name in actions:
		if action_name.begins_with("ui_") or action_name == "escape":
			continue
		
		# An array of tuples [INPUT_KEY_SOURCE, key_code]
		var key_codes = []
		for event in InputMap.action_get_events(action_name):
			if event is InputEventKey:
				if event.keycode > 0:
					key_codes.append([0, event.keycode])
			if event is InputEventMouseButton:
				key_codes.append([1, event.button_index])
			if event is InputEventJoypadButton:
				key_codes.append([2, event.button_index])
			if event is InputEventJoypadMotion:
				key_codes.append([3, event.axis, event.axis_value])
		input_actions[action_name] = key_codes
	
	return input_actions
	
