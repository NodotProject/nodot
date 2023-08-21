@tool
@icon("../../icons/mouse.svg")
## A preconfigured set of inputs for first person joypad control
class_name FirstPersonJoypadInput extends Nodot

## Is input enabled
@export var enabled := true
## Only allow WASD movement
@export var direction_movement_only := false
## How fast the character can move
@export var speed := 5.0
## How fast the character can move while sprinting (higher = faster)
@export var sprint_speed_multiplier := 3.0
## How high the character can jump
@export var jump_velocity := 4.5
## Sensitivity of joystick movement
@export var look_sensitivity := 0.1

@export_category("Input Actions")
## The input action name for selecting the next item
@export var item_next_action: String = "item_next"
## The input action name for selecting the previous item
@export var item_previous_action: String = "item_previous"
## The input action name for performing an action
@export var action_action: String = "action"
## The input action name for zooming in
@export var zoom_action: String = "zoom"
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for walking forward
@export var up_action: String = "up"
## The input action name for walking backwards
@export var down_action: String = "down"
## The input action name for reloading the current active weapon
@export var reload_action: String = "reload"
## The input action name for jumping
@export var jump_action: String = "jump"
## The input action name for sprinting
@export var sprint_action: String = "sprint"

@onready var parent: FirstPersonCharacter = get_parent()
@onready var fps_viewport: FirstPersonViewport

var head: Node3D
var is_editor: bool = Engine.is_editor_hint()
var look_rotation: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var accelerated_jump: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings


func _init():
	if !enabled: return
	var action_names = [
		left_action,
		right_action,
		up_action,
		down_action,
		reload_action,
		jump_action,
		sprint_action,
		item_next_action,
		item_previous_action,
		action_action,
		zoom_action
	]
	var default_keys = [
		JOY_AXIS_LEFT_X,
		JOY_AXIS_LEFT_X,
		JOY_AXIS_LEFT_Y,
		JOY_AXIS_LEFT_Y,
		JOY_BUTTON_B,
		JOY_BUTTON_A,
		JOY_BUTTON_LEFT_STICK,
		JOY_BUTTON_DPAD_UP,
		JOY_BUTTON_DPAD_DOWN,
		JOY_AXIS_TRIGGER_RIGHT,
		JOY_AXIS_TRIGGER_LEFT
	]
	for i in action_names.size():
		var action_name = action_names[i]
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			InputManager.add_action_event_joypad(action_name, default_keys[i])


func _ready() -> void:
	if enabled:
		enable()

	# If there is a viewport, set it
	for child in parent.get_children():
		if child is FirstPersonViewport:
			fps_viewport = child

	if parent.has_node("Head"):
		head = parent.get_node("Head")


func _input(event: InputEvent) -> void:
	if !enabled: return
	look_rotation.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * look_sensitivity
	look_rotation.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * look_sensitivity

	if fps_viewport:
		if event.is_action_pressed(item_next_action):
			fps_viewport.next_item()
		elif event.is_action_pressed(item_previous_action):
			fps_viewport.previous_item()


func _physics_process(delta: float) -> void:
	if !enabled or is_editor: return
	var final_speed: float = speed
	
	if !direction_movement_only and parent.is_on_floor():
		var jump_pressed: bool = Input.is_action_just_pressed(jump_action)
		var sprint_pressed: bool = Input.is_action_pressed(sprint_action)
		
		# Handle Jump.
		if jump_pressed:
			parent.velocity.y = jump_velocity
		
		# Handle Sprint.
		if sprint_pressed:
			final_speed *= sprint_speed_multiplier
		
		# Handle a sprint jump
		if sprint_pressed and jump_pressed:
			accelerated_jump = true
		
		if !sprint_pressed:
			accelerated_jump = false
		
	elif accelerated_jump:
		final_speed *= sprint_speed_multiplier
	
	
	var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
	var direction = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		parent.velocity.x = direction.x * final_speed
		parent.velocity.z = direction.z * final_speed
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, final_speed)
		parent.velocity.z = move_toward(parent.velocity.z, 0, final_speed)
	
	# Handle Look
	
	var look_angle: Vector2 = Vector2(look_rotation.x * delta, look_rotation.y * delta)
	
	# Handle look left and right
	parent.rotate_object_local(Vector3(0, 1, 0), -look_angle.x)
	
	# Handle look up and down
	head.rotate_object_local(Vector3(1, 0, 0), -look_angle.y)
	
	head.rotation.x = clamp(head.rotation.x, -1.36, 1.4)
	head.rotation.z = 0
	head.rotation.y = 0
	
	if fps_viewport:
		if Input.is_action_pressed(action_action):
			fps_viewport.action()
		elif Input.is_action_just_pressed(zoom_action):
			fps_viewport.zoom()
		elif Input.is_action_just_released(zoom_action):
			fps_viewport.zoomout()


## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	if !Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
