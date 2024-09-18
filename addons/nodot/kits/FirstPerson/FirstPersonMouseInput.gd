@icon("../../icons/mouse.svg")
## Adds mouse support to the first person character
class_name FirstPersonMouseInput extends Nodot

## Is input enabled
@export var enabled := true
## Custom mouse cursor
@export var custom_cursor := false
## The FirstPersonItemsContainer for the first person character
@export var fps_item_container: FirstPersonItemsContainer

@export_category("Input Actions")
## The input action name for selecting the next item
@export var item_next_action: String = "item_next"
## The input action name for selecting the previous item
@export var item_previous_action: String = "item_previous"
## The input action name for performing an action
@export var action_action: String = "action"
## The input action name for zooming in
@export var zoom_action: String = "zoom"

@onready var character: FirstPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var mouse_rotation: Vector2 = Vector2.ZERO
var cursor_show_state = Input.MOUSE_MODE_VISIBLE

## Buffer for input events
var input_buffer: Array = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings

func _init():	
	var action_names = [item_next_action, item_previous_action, action_action, zoom_action]
	var default_keys = [
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT
	]
	for i in action_names.size():
		var action_name = action_names[i]
		InputManager.register_action(action_name, default_keys[i], 1)

func _ready() -> void:
	if not character.is_authority(): return
	
	if enabled:
		enable()

	if custom_cursor:
		cursor_show_state = Input.MOUSE_MODE_HIDDEN

## Capture input and write to buffer
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if !enabled or !character.input_enabled: return

	if event is InputEventMouseMotion:
		# Add mouse movement to buffer
		input_buffer.append({"type": "mouse_motion", "event": event.relative})

	if Input.is_action_pressed(item_next_action):
		input_buffer.append({"type": "mouse_action", "action": "next_item"})
	elif Input.is_action_pressed(item_previous_action):
		input_buffer.append({"type": "mouse_action", "action": "previous_item"})
	elif Input.is_action_pressed(action_action):
		input_buffer.append({"type": "mouse_action", "action": "action"})
	elif Input.is_action_just_released(action_action):
		input_buffer.append({"type": "mouse_action", "action": "release_action"})
	elif Input.is_action_pressed(zoom_action):
		input_buffer.append({"type": "mouse_action", "action": "zoom"})
	elif Input.is_action_just_released(zoom_action):
		input_buffer.append({"type": "mouse_action", "action": "zoomout"})

## Process the buffered input during physics step (network tick)
func _physics_process(delta: float) -> void:
	action(delta)

func action(delta: float):
	if not is_multiplayer_authority(): return
	if !enabled or is_editor or !character.input_enabled: return
	
	var input: Dictionary = get_input(delta)

	character.input_states["mouse_action"] = input.mouse_action
	character.input_states["look_angle"] = input.look_angle

## Process the buffered input and get the look_angle
func get_input(delta: float) -> Dictionary:
	var look_angle: Vector2 = Vector2.ZERO
	var mouse_action: String = ""
	
	for entry in input_buffer:
		if entry["type"] == "mouse_motion":
			var mouse_movement: Vector2 = entry["event"]
			look_angle.y -= mouse_movement.x * InputManager.mouse_sensitivity * delta
			look_angle.x -= mouse_movement.y * InputManager.mouse_sensitivity * delta
		elif entry["type"] == "mouse_action":
			mouse_action = entry["action"]

	# Clear the buffer after processing
	input_buffer.clear()

	# Return final processed input
	return {
		"look_angle": Vector2(look_angle.y, look_angle.x),
		"mouse_action": mouse_action
	}

## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(cursor_show_state)
	enabled = false

## Enable input and capture mouse
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
