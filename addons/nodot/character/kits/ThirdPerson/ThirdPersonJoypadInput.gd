@tool
@icon("../../icons/mouse.svg")
## Takes joypad input for a third person character
class_name ThirdPersonJoypadInput extends Node

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
## Deadzone move
@export var deadzone_move := 0.05
## Deadzone look
@export var deadzone_look := 0.05

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
## Enable zoom camera mode
@export var zoom_camera_mode_action: String = "zoom_camera_mode"

@onready var character: ThirdPersonCharacter = get_parent()

var zoom_camera_mode: bool = false
var zoom_velocity: float = 0.0
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
			left_action, right_action, up_action, down_action, jump_action, zoom_camera_mode_action, "escape"
		]
		var default_keys = [
			JOY_AXIS_LEFT_X,
			JOY_AXIS_LEFT_X,
			JOY_AXIS_LEFT_Y,
			JOY_AXIS_LEFT_Y,
			JOY_BUTTON_A,
			JOY_BUTTON_LEFT_STICK,
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
	camera = character.camera
	camera_container = camera.get_parent()


func _input(event: InputEvent) -> void:
	if !enabled: return
	
	if event.is_action_pressed(zoom_camera_mode_action):
		zoom_camera_mode = true
	if event.is_action_released(zoom_camera_mode_action):
		zoom_camera_mode = false
			
	if zoom_camera_mode:
		var zoom_offset = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * look_sensitivity
		if abs(zoom_offset) > deadzone_look:
			zoom_velocity = clamp(zoom_offset, -1.0, 1.0)
	else:
		zoom_velocity = 0.0
		look_rotation.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * look_sensitivity
		look_rotation.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * look_sensitivity


func _physics_process(delta: float) -> void:
	if enabled and !is_editor and character.input_enabled:
		if character.is_on_floor():
			var jump_pressed: bool = Input.is_action_just_pressed(jump_action)
			var sprint_pressed: bool = Input.is_action_pressed(sprint_action)

			# Handle Jump.
			if jump_pressed:
				character.velocity.y = jump_velocity

		var input_direction_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var input_direction_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		var direction = Vector2(input_direction_x, input_direction_y)
		
		if direction.length() < deadzone_move:
			character.direction2d = Vector2.ZERO
		else:
			character.direction2d = direction
			camera.time_since_last_move = 0.0
			
		character.camera.distance += zoom_velocity * delta * look_sensitivity
			
		if !lock_camera_rotation or Input.is_action_pressed(camera_rotate_action) and look_rotation.length() > deadzone_look:
			var look_angle: Vector2 = Vector2(-look_rotation.x * delta, -look_rotation.y * delta)

			camera.time_since_last_move = 0.0

			# Handle look left and right				
			if lock_character_rotation:
				# Lerp character's Y rotation towards the target using character.turn_rate
				var current_yaw = character.rotation.y
				var target_yaw = current_yaw + look_angle.y
				var new_yaw = lerp_angle(current_yaw, target_yaw, clamp(character.turn_rate, 0, 1))
				var new_rot = character.rotation
				new_rot.y = new_yaw
				character.rotation = new_rot
			else:
				camera_container.rotate_object_local(Vector3(0, 1, 0), look_angle.y)

			camera_container.rotate_object_local(Vector3(1, 0, 0), look_angle.x)
			camera_container.rotation.x = clamp(camera_container.rotation.x, vertical_clamp.x, vertical_clamp.y)
			camera_container.rotation.z = 0

## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	if !Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
