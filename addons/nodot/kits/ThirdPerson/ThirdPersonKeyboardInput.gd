@tool
@icon("../../icons/keyboard.svg")
## A preconfigured set of inputs for third person keyboard control
class_name ThirdPersonKeyboardInput extends Nodot

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

@onready var parent: ThirdPersonCharacter = get_parent()

var is_jumping: bool = false
var is_editor: bool = Engine.is_editor_hint()
var camera: ThirdPersonCamera
var camera_container: Node3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings


func _ready() -> void:
	camera = parent.camera
	camera_container = camera.get_parent()


func _physics_process(delta: float) -> void:
	if enabled and !is_editor:
		if parent.is_on_floor():
			var jump_pressed: bool = Input.is_action_just_pressed(jump_action)
			var sprint_pressed: bool = Input.is_action_pressed(sprint_action)

			# Handle Jump.
			if jump_pressed:
				parent.velocity.y = jump_velocity

		var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
		var direction = (
			(camera_container.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
			. normalized()
		)
		if direction:
			parent.velocity.x = direction.x * speed
			parent.velocity.z = direction.z * speed
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


## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float) -> void:
	# First look directly at the target
	var initial_rotation = parent.rotation
	parent.look_at(target_position)
	# Then lerp the next rotation
	var target_rot = parent.rotation
	parent.rotation.y = lerp_angle(initial_rotation.y, target_rot.y, weight)


## Disable input
func disable() -> void:
	enabled = false


## Enable input
func enable() -> void:
	enabled = true
