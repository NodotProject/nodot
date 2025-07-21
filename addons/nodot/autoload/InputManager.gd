## Manage input logic
extends Node

signal input_actions_update

var mouse_sensitivity: float = 0.1
var default_input_actions: Dictionary
var INPUT_KEY_SOURCE = {
	KEYBOARD = 0,
	MOUSE = 1,
	JOYPAD = 2,
	JOYPAD_MOTION = 3
}

func _ready():
	default_input_actions = get_all_input_actions()
	load_config()

func bulk_register_actions_once(uid: String, action_names: Array[String], default_keys: Array[int], input_source: int = 0) -> void:
	var storage_key: String = "%s:register_actions" % uid
	if GlobalStorage.has_item(storage_key): return
	
	for i in action_names.size():
		var action_name = action_names[i]
		register_action(action_name, default_keys[i], input_source)
		
	GlobalStorage.set_item(storage_key, true)

func register_action(action_name: String, default_key: int = -1, input_source: int = 0, value: float = 0.0) -> void:
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	add_action(action_name, InputKeyCode.create({
			"code": default_key,
			"type": input_source,
			"value": value
		}))
	
func add_action(action_name: String, ikc: InputKeyCode):
	if !InputMap.has_action(action_name):
		return

	match ikc.type:
		0:
			add_action_event_key(
				action_name,
				ikc.code,
				ikc.alt_pressed,
				ikc.ctrl_pressed,
				ikc.shift_pressed,
				ikc.meta_pressed,
				ikc.command_or_control_autoremap,
			)
		1:
			add_action_event_mouse(
				action_name,
				ikc.code,
				ikc.alt_pressed,
				ikc.ctrl_pressed,
				ikc.shift_pressed,
				ikc.meta_pressed,
				ikc.command_or_control_autoremap,
			)
		2:
			add_action_event_joypad(
				action_name,
				ikc.code,
			)
		3:
			add_action_event_joypad_motion(
				action_name,
				ikc.value,
				ikc.code,
			)
		
func add_action_event_key(
		action_name: String,
		key: int = -1,
		alt_pressed: bool = false,
		ctrl_pressed: bool = false,
		shift_pressed: bool = false,
		meta_pressed: bool = false,
		command_or_control_autoremap: bool = false):
	if key > 0:
		var input_key = InputEventKey.new()
		if key > 10000:
			input_key.keycode = 0
			input_key.physical_keycode = key
		else:
			input_key.keycode = key
		input_key.alt_pressed = alt_pressed
		input_key.ctrl_pressed = ctrl_pressed
		input_key.shift_pressed = shift_pressed
		input_key.meta_pressed = meta_pressed
		input_key.command_or_control_autoremap = command_or_control_autoremap
		InputMap.action_add_event(action_name, input_key)
		
func add_action_event_mouse(
		action_name: String,
		button_index: int = -1,
		alt_pressed: bool = false,
		ctrl_pressed: bool = false,
		shift_pressed: bool = false,
		meta_pressed: bool = false,
		command_or_control_autoremap: bool = false):
	if button_index >= 0:
		var input_key = InputEventMouseButton.new()
		input_key.button_index = button_index
		input_key.alt_pressed = alt_pressed
		input_key.ctrl_pressed = ctrl_pressed
		input_key.shift_pressed = shift_pressed
		input_key.meta_pressed = meta_pressed
		input_key.command_or_control_autoremap = command_or_control_autoremap
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
		if get_action_name_from_event(event) == key:
			InputMap.action_erase_event(action_name, event)
			break
			
	input_actions_update.emit()

func get_action_key(action: String) -> String:
	var evs = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventKey or ev is InputEventMouse:
			return get_action_name_from_event(ev)
	return ""
	
func get_action_joy(action: String) -> String:
	var evs = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			return get_action_name_from_event(ev)
	return ""
	
func get_action_name_from_event(event: InputEvent) -> String:
	if event is InputEventKey or event is InputEventMouseButton:
		if event is InputEventKey:
			var key_name := ""
			if event.keycode == 0:
				var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
				key_name = OS.get_keycode_string(keycode)
			else:
				key_name = OS.get_keycode_string(event.keycode)
			return key_name
		elif event is InputEventMouseButton:
			return event.as_text()
	return event.as_text()

func load_config():
	if SaveManager.config.has_item("mouse_sensitivity"):
		mouse_sensitivity = SaveManager.config.get_item("mouse_sensitivity")
	if SaveManager.config.has_item("input_actions"):
		var input_actions_exported = SaveManager.config.get_item("input_actions")
		var input_actions = {}
		for action_name in input_actions_exported:
			var keycode_dicts = input_actions_exported[action_name]
			var keycodes = []
			for keycode_dict in keycode_dicts:
				if keycode_dict is Array:
					return reset_to_defaults()
				keycodes.append(InputKeyCode.create(keycode_dict))
			input_actions[action_name] = keycodes
		set_all_input_actions(input_actions)
	else:
		reset_to_defaults()

func save_config():
	SaveManager.config.set_item("mouse_sensitivity", mouse_sensitivity)
	var input_actions = get_all_input_actions()
	var input_actions_exported = {}
	for action_name in input_actions:
		var keycodes = input_actions[action_name]
		var exported_keycodes = []
		for keycode in keycodes:
			exported_keycodes.append(keycode.export())
		input_actions_exported[action_name] = exported_keycodes
	SaveManager.config.set_item("input_actions", input_actions_exported)
	SaveManager.save_config()
	input_actions_update.emit()

func reset_to_defaults():
	set_all_input_actions(default_input_actions)

func set_all_input_actions(input_actions: Dictionary):
	for action_name in input_actions:
		if InputMap.has_action(action_name):
			InputMap.action_erase_events(action_name)
		for key_code in input_actions[action_name]:
			if typeof(key_code) == TYPE_ARRAY:
				# We have an outdated format saved. Restore default settings.
				reset_to_defaults()
				return
			add_action(action_name, key_code)
	input_actions_update.emit()
				
func get_all_input_actions() -> Dictionary:
	var input_actions = {}
	var actions = InputMap.get_actions()
	for action_name in actions:
		if action_name.begins_with("ui_") or action_name == "escape":
			continue
		
		var key_codes = []
		for event in InputMap.action_get_events(action_name):
			var ikc = event_to_input_key_code(event)
			if ikc:
				key_codes.append(ikc)
		input_actions[action_name] = key_codes
	
	return input_actions
	
func event_to_input_key_code(event: InputEvent):
	if event is InputEventKey:
		var code = event.keycode if event.keycode > 0 else event.physical_keycode
		return InputKeyCode.create({
			"type": 0,
			"code": code,
			"alt_pressed": event.alt_pressed,
			"ctrl_pressed": event.ctrl_pressed,
			"shift_pressed": event.shift_pressed,
			"meta_pressed": event.meta_pressed,
			"command_or_control_autoremap": event.command_or_control_autoremap
		})
	elif event is InputEventMouseButton:
		return InputKeyCode.create({
			"type": 1,
			"code": event.button_index,
			"alt_pressed": event.alt_pressed,
			"ctrl_pressed": event.ctrl_pressed,
			"shift_pressed": event.shift_pressed,
			"meta_pressed": event.meta_pressed,
			"command_or_control_autoremap": event.command_or_control_autoremap
		})
	elif event is InputEventJoypadButton:
		return InputKeyCode.create({
			"type": 2,
			"code": event.button_index
		})
	elif event is InputEventJoypadMotion:
		return InputKeyCode.create({
			"type": 3,
			"code": event.axis,
			"value": event.axis_value
		})
	
	return null

class InputKeyCode:
	var type: int = 0
	var code: int = 0
	var value: float = 0
	var alt_pressed: bool = false
	var ctrl_pressed: bool = false
	var shift_pressed: bool = false
	var meta_pressed: bool = false
	var command_or_control_autoremap: bool = false
	
	static func create(config: Dictionary):
		var new_ikc := InputKeyCode.new()
		new_ikc.type = config.get("type", 0)
		new_ikc.code = config.get("code", 0)
		new_ikc.value = config.get("value", 0.0)
		new_ikc.alt_pressed = config.get("alt_pressed", false)
		new_ikc.ctrl_pressed = config.get("ctrl_pressed", false)
		new_ikc.shift_pressed = config.get("shift_pressed", false)
		new_ikc.meta_pressed = config.get("meta_pressed", false)
		new_ikc.command_or_control_autoremap = config.get("command_or_control_autoremap", false)
		return new_ikc
		
	func export() -> Dictionary:
		var data: Dictionary = {
			"type": type,
			"code": code,
			"value": value,
			"alt_pressed": alt_pressed,
			"ctrl_pressed": ctrl_pressed,
			"shift_pressed": shift_pressed,
			"meta_pressed": meta_pressed,
			"command_or_control_autoremap": command_or_control_autoremap
		}
		return data
