@tool
@icon("../../icons/mouse.svg")
## Takes mouse input for a third person character
class_name ThirdPersonMouseInput extends Nodot

## Is input enabled
@export var enabled := true
## Sensitivity of mouse movement
@export var mouse_sensitivity := 0.1
## Custom mouse cursor
@export var custom_cursor := false

@export_category("Input Actions")
## Input action for enabling camera rotation
@export var camera_rotate_action: String = "camera_rotate"
## The input action name for selecting the next item
@export var item_next_action: String = "item_next"
## The input action name for selecting the previous item
@export var item_previous_action: String = "item_previous"
## The input action name for performing an action
@export var action_action: String = "action"

@onready var character: ThirdPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var camera: ThirdPersonCamera
var camera_container: Node3D
var cursor_show_state = Input.MOUSE_MODE_VISIBLE

## Buffer for input events
var input_buffer: Array = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings


func _ready() -> void:
	if enabled:
		enable()
	camera = character.camera
	camera_container = camera.get_parent()
	if custom_cursor:
		cursor_show_state = Input.MOUSE_MODE_HIDDEN

## Capture input and write to buffer
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if !enabled or !character.input_enabled: return

	if event is InputEventMouseMotion:
		# Add mouse movement to buffer
		input_buffer.append({"type": "mouse_motion", "event": event.relative})
		camera.time_since_last_move = 0.0

	if Input.is_action_pressed(item_next_action):
		input_buffer.append({"type": "mouse_action", "action": "next_item"})
	elif Input.is_action_pressed(item_previous_action):
		input_buffer.append({"type": "mouse_action", "action": "previous_item"})
	elif Input.is_action_pressed(action_action):
		input_buffer.append({"type": "mouse_action", "action": "action"})
	elif Input.is_action_just_released(action_action):
		input_buffer.append({"type": "mouse_action", "action": "release_action"})

## Process the buffered input during physics step (network tick)
func _physics_process(delta: float) -> void:
	action(delta)

func action(delta: float):
	if not is_multiplayer_authority(): return
	if !enabled or is_editor or !character.input_enabled: return
	
	if Input.is_action_pressed(camera_rotate_action): return
	
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
		"look_angle": Vector2(look_angle.x, look_angle.y),
		"mouse_action": mouse_action
	}

## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(cursor_show_state)
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	if !Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
