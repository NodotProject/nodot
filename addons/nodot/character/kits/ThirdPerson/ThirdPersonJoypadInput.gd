@tool
@icon("../../icons/mouse.svg")
## Takes joypad input for a third person character
class_name ThirdPersonJoypadInput extends Nodot

## Is input enabled
@export var enabled: bool = true
## How fast the character can move
@export var speed: float = 5.0
## How fast the player turns to face a direction
@export var turn_rate: float = 0.1
## How high the character can jump
@export var jump_velocity: float = 4.5
## Instead of turning the character, the character will strafe on left and right input action
@export var strafing: bool = false
## Sensitivity of look movement
@export var look_sensitivity := 1.0
## Enable camera movement only while camera_rotate_action input action is pressed
@export var lock_camera_rotation := false
## Rotate the ThirdPersonCharacter with the camera
@export var lock_character_rotation := false
## Restrict vertical look angle
@export var vertical_clamp := Vector2(-0.5, 0.5)

@export_category("Input Actions")
## The input action name for moving left
@export var left_action: String = "left"
## The input action name for moving right
@export var right_action: String = "right"
## The input action name for moving forward
@export var up_action: String = "up"
## The input action name for moving backwards
@export var down_action: String = "down"
## The input action name for jumping
@export var jump_action: String = "jump"
## The input action name for sprinting
@export var sprint_action: String = "sprint"
## Input action for enabling camera rotation
@export var camera_rotate_action: String = "camera_rotate"

@onready var parent: ThirdPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var look_rotation: Vector2 = Vector2.ZERO
var camera: ThirdPersonCamera
var camera_container: Node3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings


func _init():
	if enabled:
		var action_names = [
			left_action, right_action, up_action, down_action, jump_action, "escape"
		]
		var default_keys = [
			JOY_AXIS_LEFT_X,
			JOY_AXIS_LEFT_X,
			JOY_AXIS_LEFT_Y,
			JOY_AXIS_LEFT_Y,
			JOY_BUTTON_A,
			JOY_BUTTON_START
		]
		for i in action_names.size():
			var action_name = action_names[i]
			if not InputMap.has_action(action_name):
				InputMap.add_action(action_name)
				InputManager.add_action_event_joypad(action_name, default_keys[i])


func _ready() -> void:
	if enabled:
		enable()
	camera = parent.camera
	camera_container = camera.get_parent()


func _input(event: InputEvent) -> void:
	if enabled:
		look_rotation.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * look_sensitivity
		look_rotation.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * look_sensitivity


func _physics_process(delta: float) -> void:
	if enabled and !is_editor:
		if parent.is_on_floor():
			var jump_pressed: bool = Input.is_action_just_pressed(jump_action)
			var sprint_pressed: bool = Input.is_action_pressed(sprint_action)

			# Handle Jump.
			if jump_pressed:
				parent.velocity.y = jump_velocity

		var input_direction_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var input_direction_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		var direction = (
			camera_container.global_transform.basis
			* Vector3(input_direction_x, 0, input_direction_y)
		)
		if direction:
			parent.velocity.x = direction.x * delta * speed * 100
			parent.velocity.z = direction.z * delta * speed * 100
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, speed)
			parent.velocity.z = move_toward(parent.velocity.z, 0, speed)

		if direction:
			var camera_rotation = camera_container.global_rotation
			if strafing:
				# TODO: Need a better solution for strafing
				if Input.is_action_pressed(up_action):
					face_target(parent.position + direction, turn_rate)
				if Input.is_action_pressed(down_action):
					face_target(parent.position + direction, turn_rate)
			else:
				face_target(parent.position + direction, turn_rate)

			camera_container.global_rotation = camera_rotation
			camera.time_since_last_move = 0.0

		if !lock_camera_rotation or Input.is_action_pressed(camera_rotate_action):
			var look_angle: Vector2 = Vector2(-look_rotation.x * delta, -look_rotation.y * delta)

			if look_angle != Vector2.ZERO:
				camera.time_since_last_move = 0.0

			# Handle look left and right
			if lock_character_rotation:
				parent.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
			else:
				camera_container.rotate_object_local(Vector3(0, 1, 0), look_angle.y)

			# Handle look up and down
			camera.rotate_object_local(Vector3(1, 0, 0), look_angle.x)

			camera.rotation.x = clamp(camera.rotation.x, vertical_clamp.x, vertical_clamp.y)


## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float) -> void:
	# First look directly at the target
	var initial_rotation = parent.rotation
	parent.look_at(target_position)
	# Then lerp the next rotation
	var target_rot = parent.rotation
	parent.rotation.y = lerp_angle(initial_rotation.y, target_rot.y, weight)


## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	if !Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
