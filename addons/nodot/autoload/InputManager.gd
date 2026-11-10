## Manage input logic
extends Node

signal input_actions_update

## Mouse-look tuning, shared by EVERY mouse-driven camera (single-player, the networked
## controller, spectator/free cameras). Persisted via SaveManager.config (load_config /
## save_config).
##
## [member mouse_sensitivity] is on the Source-engine scale: one mouse COUNT turns the view
## [constant YAW_DEG_PER_COUNT] x sensitivity degrees, so a value copied from CS/Apex/TF2
## feels identical here. Callers must feed [method look_radians] the event's
## [code]screen_relative[/code] (raw counts while the mouse is captured) — NEVER
## [code]relative[/code], which Godot divides by the canvas_items stretch scale, so look
## speed would change with the window size (with a 1152x648 base and canvas_items stretch,
## 1080p turns 1.67x slower than the base and 4K 3.33x). And never multiply a mouse delta by a frame/physics delta: a delta is
## already a distance, not a rate.
const YAW_DEG_PER_COUNT := 0.022
const DEFAULT_MOUSE_SENSITIVITY := 1.5
const MIN_MOUSE_SENSITIVITY := 0.05
const MAX_MOUSE_SENSITIVITY := 10.0
const DEFAULT_MOUSE_DPI := 800
## Zoom must narrow the FOV by more than this before the ADS multiplier fully applies —
## a short ramp so a mid-raise FOV ease never steps the sensitivity.
const _ADS_RAMP := 0.1
## The pre-v2 sensitivity default; a legacy save still holding it is "never touched" and
## takes the new default instead of being converted.
const _LEGACY_DEFAULT_SENSITIVITY := 0.1

## Source-scale look sensitivity (see above). 1.5 = ~35 cm per 360 deg at 800 DPI.
var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
## Vertical multiplier on top of [member mouse_sensitivity] (1.0 = same as horizontal).
var mouse_y_scale: float = 1.0
## Invert vertical mouse look.
var invert_mouse_y: bool = false
## Multiplier on the zoom-matched aim-down-sights / scope sensitivity. 1.0 = 0% monitor
## distance match (things under the crosshair move at the same on-screen speed at every
## zoom level); higher feels faster when zoomed.
var ads_sensitivity_scale: float = 1.0
## The player's mouse DPI. Display-only: drives the cm/360 readout in the options menu.
var mouse_dpi: int = DEFAULT_MOUSE_DPI
var default_input_actions: Dictionary
var INPUT_KEY_SOURCE = {
	KEYBOARD = 0,
	MOUSE = 1,
	JOYPAD = 2,
	JOYPAD_MOTION = 3
}

# --- Input Mode Detection ---

enum InputMode { KEYBOARD_MOUSE, CONTROLLER }
enum ControllerFormat { GENERIC, XBOX, PLAYSTATION, NINTENDO_SWITCH, STEAM_DECK }

signal input_mode_changed(new_mode: InputMode)
signal controller_type_changed(new_type: ControllerFormat)

var current_mode: InputMode = InputMode.KEYBOARD_MOUSE
var current_controller_format: ControllerFormat = ControllerFormat.GENERIC
var stick_deadzone: float = 0.5  # Higher threshold for mode switching (not gameplay)

# InputUI format indices (must match InputUI.input_format_names order)
const INPUTUI_FORMAT_GENERIC := 1
const INPUTUI_FORMAT_KEYBOARD_MOUSE := 2
const INPUTUI_FORMAT_NINTENDO_SWITCH := 3
const INPUTUI_FORMAT_PLAYSTATION := 7
const INPUTUI_FORMAT_STEAM_DECK := 9
const INPUTUI_FORMAT_XBOX := 10

# Button index to texture name mappings for each format
var _button_maps: Dictionary = {}
var _axis_maps: Dictionary = {}


func _ready():
	default_input_actions = get_all_input_actions()
	load_config()

	# Input mode detection setup
	_init_button_maps()
	_init_axis_maps()
	_detect_controller_type()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

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

## View rotation (radians: x = yaw, y = pitch) for one mouse event's raw [param screen_relative]
## motion, with invert-Y and the vertical multiplier folded in. Positive x = mouse moved
## right, positive y = mouse moved down (or up when inverted) — callers SUBTRACT it from yaw
## and pitch. [param zoom] is the FOV sensitivity factor from [method zoom_factor].
func look_radians(screen_relative: Vector2, zoom: float = 1.0) -> Vector2:
	var k := deg_to_rad(YAW_DEG_PER_COUNT) * mouse_sensitivity * zoom
	var y_sign := -1.0 if invert_mouse_y else 1.0
	return Vector2(screen_relative.x * k, screen_relative.y * k * mouse_y_scale * y_sign)

## Sensitivity factor for a camera zoomed from [param fov_rest] to [param fov_now] (degrees,
## either both vertical or both horizontal — the ratio is aspect-independent). The base is
## the zoom ratio tan(now/2)/tan(rest/2) (0% monitor-distance match), so a 15 deg scope no
## longer sweeps the screen ~6x faster than the hip view; [member ads_sensitivity_scale]
## then scales it, ramped in over the first [constant _ADS_RAMP] of zoom so the FOV easing
## in/out of ADS never steps the sensitivity. 1.0 when not zoomed.
func zoom_factor(fov_now: float, fov_rest: float) -> float:
	if fov_now <= 0.0 or fov_rest <= 0.0 or fov_now >= fov_rest:
		return 1.0
	var k := tan(deg_to_rad(fov_now) * 0.5) / tan(deg_to_rad(fov_rest) * 0.5)
	var blend := clampf((1.0 - k) / _ADS_RAMP, 0.0, 1.0)
	return k * lerpf(1.0, ads_sensitivity_scale, blend)

## Centimetres of mouse travel for a full 360 deg turn at [param dpi] (hip, not zoomed).
func cm_per_360(dpi: int = mouse_dpi) -> float:
	if dpi <= 0 or mouse_sensitivity <= 0.0:
		return INF
	return 2.54 * 360.0 / (float(dpi) * mouse_sensitivity * YAW_DEG_PER_COUNT)

## Restore every mouse-look setting to its default (keybindings untouched).
func reset_mouse_settings() -> void:
	mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
	mouse_y_scale = 1.0
	invert_mouse_y = false
	ads_sensitivity_scale = 1.0
	mouse_dpi = DEFAULT_MOUSE_DPI

## Convert a pre-v2 [code]mouse_sensitivity[/code] save. The old value was radians per
## STRETCHED pixel per physics tick (FirstPersonMouseInput multiplied event.relative by it and
## by the physics delta), so its real feel depended on the window. Convert at the most common
## resolution, 1080p: relative = screen counts / stretch scale there.
static func legacy_to_source_scale(legacy: float) -> float:
	var base := Vector2(
		float(ProjectSettings.get_setting("display/window/size/viewport_width", 1152)),
		float(ProjectSettings.get_setting("display/window/size/viewport_height", 648)))
	var stretch := 1.0
	if String(ProjectSettings.get_setting("display/window/stretch/mode", "disabled")) != "disabled" \
			and base.x > 0.0 and base.y > 0.0:
		stretch = minf(1920.0 / base.x, 1080.0 / base.y)
	var rad_per_count := legacy / float(Engine.physics_ticks_per_second) / stretch
	return rad_to_deg(rad_per_count) / YAW_DEG_PER_COUNT

func load_config():
	_load_mouse_config()
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
	_save_mouse_config()
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

func _load_mouse_config() -> void:
	var cfg = SaveManager.config
	if cfg.has_item("mouse_sens"):
		mouse_sensitivity = float(cfg.get_item("mouse_sens"))
	elif cfg.has_item("mouse_sensitivity"):
		# Pre-v2 save (different units, see legacy_to_source_scale). An untouched default
		# takes the new default; a hand-tuned value keeps its 1080p feel.
		var legacy := float(cfg.get_item("mouse_sensitivity"))
		if legacy > 0.0 and not is_equal_approx(legacy, _LEGACY_DEFAULT_SENSITIVITY):
			mouse_sensitivity = legacy_to_source_scale(legacy)
	mouse_sensitivity = clampf(mouse_sensitivity, MIN_MOUSE_SENSITIVITY, MAX_MOUSE_SENSITIVITY)
	if cfg.has_item("mouse_y_scale"):
		mouse_y_scale = clampf(float(cfg.get_item("mouse_y_scale")), 0.1, 3.0)
	if cfg.has_item("invert_mouse_y"):
		invert_mouse_y = bool(cfg.get_item("invert_mouse_y"))
	if cfg.has_item("ads_sensitivity_scale"):
		ads_sensitivity_scale = clampf(float(cfg.get_item("ads_sensitivity_scale")), 0.1, 3.0)
	if cfg.has_item("mouse_dpi"):
		mouse_dpi = clampi(int(cfg.get_item("mouse_dpi")), 50, 32000)

func _save_mouse_config() -> void:
	var cfg = SaveManager.config
	cfg.set_item("mouse_sens", mouse_sensitivity)
	cfg.set_item("mouse_y_scale", mouse_y_scale)
	cfg.set_item("invert_mouse_y", invert_mouse_y)
	cfg.set_item("ads_sensitivity_scale", ads_sensitivity_scale)
	cfg.set_item("mouse_dpi", mouse_dpi)

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


# --- Input Mode Detection Methods ---

func _input(event: InputEvent) -> void:
	var detected_mode := _detect_mode_from_event(event)
	if detected_mode >= 0 and detected_mode != current_mode:
		current_mode = detected_mode
		input_mode_changed.emit(current_mode)


func _detect_mode_from_event(event: InputEvent) -> int:
	# Keyboard/Mouse events
	if event is InputEventKey:
		return InputMode.KEYBOARD_MOUSE
	if event is InputEventMouseButton:
		return InputMode.KEYBOARD_MOUSE
	if event is InputEventMouseMotion:
		# Only switch on significant mouse movement
		if event.relative.length() > 5.0:
			return InputMode.KEYBOARD_MOUSE
		return -1  # Ignore small mouse movements

	# Controller events
	if event is InputEventJoypadButton:
		return InputMode.CONTROLLER
	if event is InputEventJoypadMotion:
		# Only switch mode if stick/trigger moved past deadzone
		if abs(event.axis_value) > stick_deadzone:
			return InputMode.CONTROLLER
		return -1  # Ignore small stick movements

	return -1  # Unknown event type, don't change mode


func _detect_controller_type() -> void:
	var connected_joypads := Input.get_connected_joypads()
	if connected_joypads.is_empty():
		current_controller_format = ControllerFormat.GENERIC
		return

	var joy_name := Input.get_joy_name(0).to_lower()
	var previous_format := current_controller_format

	if "playstation" in joy_name or "dualsense" in joy_name or "dualshock" in joy_name or "ps4" in joy_name or "ps5" in joy_name:
		current_controller_format = ControllerFormat.PLAYSTATION
	elif "xbox" in joy_name or "microsoft" in joy_name:
		current_controller_format = ControllerFormat.XBOX
	elif "nintendo" in joy_name or "switch" in joy_name or "pro controller" in joy_name or "joy-con" in joy_name:
		current_controller_format = ControllerFormat.NINTENDO_SWITCH
	elif "steam" in joy_name or "deck" in joy_name:
		current_controller_format = ControllerFormat.STEAM_DECK
	else:
		current_controller_format = ControllerFormat.GENERIC

	if current_controller_format != previous_format:
		controller_type_changed.emit(current_controller_format)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if device == 0:
		if connected:
			_detect_controller_type()
		else:
			current_controller_format = ControllerFormat.GENERIC
			controller_type_changed.emit(current_controller_format)
			# Also switch back to keyboard/mouse mode if controller disconnected
			if current_mode == InputMode.CONTROLLER:
				current_mode = InputMode.KEYBOARD_MOUSE
				input_mode_changed.emit(current_mode)


# Query Methods

func is_controller_mode() -> bool:
	return current_mode == InputMode.CONTROLLER


func is_keyboard_mouse_mode() -> bool:
	return current_mode == InputMode.KEYBOARD_MOUSE


func should_grab_focus() -> bool:
	return current_mode == InputMode.CONTROLLER


# UI Helper Methods

func get_inputui_format() -> int:
	match current_controller_format:
		ControllerFormat.XBOX:
			return INPUTUI_FORMAT_XBOX
		ControllerFormat.PLAYSTATION:
			return INPUTUI_FORMAT_PLAYSTATION
		ControllerFormat.NINTENDO_SWITCH:
			return INPUTUI_FORMAT_NINTENDO_SWITCH
		ControllerFormat.STEAM_DECK:
			return INPUTUI_FORMAT_STEAM_DECK
		_:
			return INPUTUI_FORMAT_GENERIC


func get_input_prompt(action: String) -> String:
	## Returns the appropriate input prompt string for the current mode
	if is_controller_mode():
		return get_joypad_texture_name(action)
	else:
		return get_action_key(action)


func get_joypad_texture_name(action: String) -> String:
	## Convert an action name to the appropriate texture file name for InputUI
	var events := InputMap.action_get_events(action)
	for event in events:
		if event is InputEventJoypadButton:
			return _get_button_texture_name(event.button_index)
		elif event is InputEventJoypadMotion:
			return _get_axis_texture_name(event.axis, event.axis_value)
	return "generic_button"  # Fallback


func _get_button_texture_name(button_index: int) -> String:
	var format_map: Dictionary = _button_maps.get(current_controller_format, _button_maps[ControllerFormat.GENERIC])
	return format_map.get(button_index, "generic_button")


func _get_axis_texture_name(axis: int, axis_value: float) -> String:
	var format_map: Dictionary = _axis_maps.get(current_controller_format, _axis_maps[ControllerFormat.GENERIC])
	var key := "%d_%s" % [axis, "pos" if axis_value > 0 else "neg"]
	# Try specific direction first, then fall back to general axis
	if format_map.has(key):
		return format_map[key]
	return format_map.get(axis, "generic_stick")


func _init_button_maps() -> void:
	# Generic format (platform-agnostic)
	_button_maps[ControllerFormat.GENERIC] = {
		JOY_BUTTON_A: "generic_button_circle",
		JOY_BUTTON_B: "generic_button_square",
		JOY_BUTTON_X: "generic_button_circle",
		JOY_BUTTON_Y: "generic_button_square",
		JOY_BUTTON_LEFT_SHOULDER: "generic_button_trigger_c",
		JOY_BUTTON_RIGHT_SHOULDER: "generic_button_trigger_c",
		JOY_BUTTON_BACK: "generic_button",
		JOY_BUTTON_START: "generic_button",
		JOY_BUTTON_LEFT_STICK: "generic_stick_press",
		JOY_BUTTON_RIGHT_STICK: "generic_stick_press",
		JOY_BUTTON_GUIDE: "generic_button",
		JOY_BUTTON_MISC1: "generic_button",
		JOY_BUTTON_DPAD_UP: "generic_stick_up",
		JOY_BUTTON_DPAD_DOWN: "generic_stick_down",
		JOY_BUTTON_DPAD_LEFT: "generic_stick_left",
		JOY_BUTTON_DPAD_RIGHT: "generic_stick_right",
	}

	# Xbox format
	_button_maps[ControllerFormat.XBOX] = {
		JOY_BUTTON_A: "xbox_button_a",
		JOY_BUTTON_B: "xbox_button_b",
		JOY_BUTTON_X: "xbox_button_x",
		JOY_BUTTON_Y: "xbox_button_y",
		JOY_BUTTON_LEFT_SHOULDER: "xbox_lb",
		JOY_BUTTON_RIGHT_SHOULDER: "xbox_rb",
		JOY_BUTTON_BACK: "xbox_button_back",
		JOY_BUTTON_START: "xbox_button_start",
		JOY_BUTTON_LEFT_STICK: "xbox_stick_l_press",
		JOY_BUTTON_RIGHT_STICK: "xbox_stick_r_press",
		JOY_BUTTON_GUIDE: "xbox_button_guide",
		JOY_BUTTON_MISC1: "xbox_button_share",
		JOY_BUTTON_DPAD_UP: "xbox_dpad_up",
		JOY_BUTTON_DPAD_DOWN: "xbox_dpad_down",
		JOY_BUTTON_DPAD_LEFT: "xbox_dpad_left",
		JOY_BUTTON_DPAD_RIGHT: "xbox_dpad_right",
	}

	# PlayStation format
	_button_maps[ControllerFormat.PLAYSTATION] = {
		JOY_BUTTON_A: "playstation_button_cross",
		JOY_BUTTON_B: "playstation_button_circle",
		JOY_BUTTON_X: "playstation_button_square",
		JOY_BUTTON_Y: "playstation_button_triangle",
		JOY_BUTTON_LEFT_SHOULDER: "playstation_l1",
		JOY_BUTTON_RIGHT_SHOULDER: "playstation_r1",
		JOY_BUTTON_BACK: "playstation_button_create",
		JOY_BUTTON_START: "playstation_button_options",
		JOY_BUTTON_LEFT_STICK: "playstation_stick_l_press",
		JOY_BUTTON_RIGHT_STICK: "playstation_stick_r_press",
		JOY_BUTTON_GUIDE: "playstation_button_ps",
		JOY_BUTTON_MISC1: "playstation_button_touchpad",
		JOY_BUTTON_DPAD_UP: "playstation_dpad_up",
		JOY_BUTTON_DPAD_DOWN: "playstation_dpad_down",
		JOY_BUTTON_DPAD_LEFT: "playstation_dpad_left",
		JOY_BUTTON_DPAD_RIGHT: "playstation_dpad_right",
	}

	# Nintendo Switch format
	_button_maps[ControllerFormat.NINTENDO_SWITCH] = {
		JOY_BUTTON_A: "switch_button_b",  # Nintendo has A/B swapped
		JOY_BUTTON_B: "switch_button_a",
		JOY_BUTTON_X: "switch_button_y",  # Nintendo has X/Y swapped
		JOY_BUTTON_Y: "switch_button_x",
		JOY_BUTTON_LEFT_SHOULDER: "switch_l",
		JOY_BUTTON_RIGHT_SHOULDER: "switch_r",
		JOY_BUTTON_BACK: "switch_button_minus",
		JOY_BUTTON_START: "switch_button_plus",
		JOY_BUTTON_LEFT_STICK: "switch_stick_l_press",
		JOY_BUTTON_RIGHT_STICK: "switch_stick_r_press",
		JOY_BUTTON_GUIDE: "switch_button_home",
		JOY_BUTTON_MISC1: "switch_button_screenshot",
		JOY_BUTTON_DPAD_UP: "switch_dpad_up",
		JOY_BUTTON_DPAD_DOWN: "switch_dpad_down",
		JOY_BUTTON_DPAD_LEFT: "switch_dpad_left",
		JOY_BUTTON_DPAD_RIGHT: "switch_dpad_right",
	}

	# Steam Deck format (uses similar layout to Xbox but different icons)
	_button_maps[ControllerFormat.STEAM_DECK] = {
		JOY_BUTTON_A: "steamdeck_button_a",
		JOY_BUTTON_B: "steamdeck_button_b",
		JOY_BUTTON_X: "steamdeck_button_x",
		JOY_BUTTON_Y: "steamdeck_button_y",
		JOY_BUTTON_LEFT_SHOULDER: "steamdeck_l1",
		JOY_BUTTON_RIGHT_SHOULDER: "steamdeck_r1",
		JOY_BUTTON_BACK: "steamdeck_button_view",
		JOY_BUTTON_START: "steamdeck_button_options",
		JOY_BUTTON_LEFT_STICK: "steamdeck_stick_l_press",
		JOY_BUTTON_RIGHT_STICK: "steamdeck_stick_r_press",
		JOY_BUTTON_GUIDE: "steamdeck_button_steam",
		JOY_BUTTON_MISC1: "steamdeck_button_quickaccess",
		JOY_BUTTON_DPAD_UP: "steamdeck_dpad_up",
		JOY_BUTTON_DPAD_DOWN: "steamdeck_dpad_down",
		JOY_BUTTON_DPAD_LEFT: "steamdeck_dpad_left",
		JOY_BUTTON_DPAD_RIGHT: "steamdeck_dpad_right",
	}


func _init_axis_maps() -> void:
	# Generic format
	_axis_maps[ControllerFormat.GENERIC] = {
		JOY_AXIS_LEFT_X: "generic_stick_horizontal",
		JOY_AXIS_LEFT_Y: "generic_stick_vertical",
		JOY_AXIS_RIGHT_X: "generic_stick_horizontal",
		JOY_AXIS_RIGHT_Y: "generic_stick_vertical",
		JOY_AXIS_TRIGGER_LEFT: "generic_button_trigger_a",
		JOY_AXIS_TRIGGER_RIGHT: "generic_button_trigger_b",
	}

	# Xbox format
	_axis_maps[ControllerFormat.XBOX] = {
		JOY_AXIS_LEFT_X: "xbox_stick_l_horizontal",
		JOY_AXIS_LEFT_Y: "xbox_stick_l_vertical",
		JOY_AXIS_RIGHT_X: "xbox_stick_r_horizontal",
		JOY_AXIS_RIGHT_Y: "xbox_stick_r_vertical",
		JOY_AXIS_TRIGGER_LEFT: "xbox_lt",
		JOY_AXIS_TRIGGER_RIGHT: "xbox_rt",
	}

	# PlayStation format
	_axis_maps[ControllerFormat.PLAYSTATION] = {
		JOY_AXIS_LEFT_X: "playstation_stick_l_horizontal",
		JOY_AXIS_LEFT_Y: "playstation_stick_l_vertical",
		JOY_AXIS_RIGHT_X: "playstation_stick_r_horizontal",
		JOY_AXIS_RIGHT_Y: "playstation_stick_r_vertical",
		JOY_AXIS_TRIGGER_LEFT: "playstation_l2",
		JOY_AXIS_TRIGGER_RIGHT: "playstation_r2",
	}

	# Nintendo Switch format
	_axis_maps[ControllerFormat.NINTENDO_SWITCH] = {
		JOY_AXIS_LEFT_X: "switch_stick_l_horizontal",
		JOY_AXIS_LEFT_Y: "switch_stick_l_vertical",
		JOY_AXIS_RIGHT_X: "switch_stick_r_horizontal",
		JOY_AXIS_RIGHT_Y: "switch_stick_r_vertical",
		JOY_AXIS_TRIGGER_LEFT: "switch_zl",
		JOY_AXIS_TRIGGER_RIGHT: "switch_zr",
	}

	# Steam Deck format
	_axis_maps[ControllerFormat.STEAM_DECK] = {
		JOY_AXIS_LEFT_X: "steamdeck_stick_l_horizontal",
		JOY_AXIS_LEFT_Y: "steamdeck_stick_l_vertical",
		JOY_AXIS_RIGHT_X: "steamdeck_stick_r_horizontal",
		JOY_AXIS_RIGHT_Y: "steamdeck_stick_r_vertical",
		JOY_AXIS_TRIGGER_LEFT: "steamdeck_l2",
		JOY_AXIS_TRIGGER_RIGHT: "steamdeck_r2",
	}


func reset_input_mode() -> void:
	current_mode = InputMode.KEYBOARD_MOUSE
	current_controller_format = ControllerFormat.GENERIC
	_detect_controller_type()


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
