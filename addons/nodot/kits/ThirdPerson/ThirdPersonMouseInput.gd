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

@onready var character: ThirdPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var mouse_rotation: Vector2 = Vector2.ZERO
var camera: ThirdPersonCamera
var camera_container: Node3D
var cursor_show_state = Input.MOUSE_MODE_VISIBLE


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


func _input(event: InputEvent) -> void:
	if enabled:
		if event is InputEventMouseMotion:
			mouse_rotation.y = event.relative.x * mouse_sensitivity
			mouse_rotation.x = event.relative.y * mouse_sensitivity
			camera.time_since_last_move = 0.0


func _physics_process(delta: float) -> void:
	if is_editor or character and character.is_authority_owner() == false: return
	if !enabled or !character.input_enabled: return
	
	if Input.is_action_pressed(camera_rotate_action): return
	
	var look_angle: Vector2 = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)
	character.look_angle = Vector2(look_angle.x, look_angle.y)
	mouse_rotation = Vector2.ZERO


## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(cursor_show_state)
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	if !Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
