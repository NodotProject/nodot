## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends NodotCharacter

## Allow player input
@export var input_enabled: bool = true
## Gravity strength
@export var gravity: float = 9.8
## Apply gravity even when the character is on the floor
@export var always_apply_gravity: bool = false

@export_category("Input Actions")
## The input action name for pausing the game
@export var escape_action: String = "escape"

var camera: ThirdPersonCamera


func _physics_process(delta: float) -> void:
	if always_apply_gravity or !is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _enter_tree() -> void:
	# Set up camera container
	for child in get_children():
		if child is ThirdPersonCamera:
			var node3d = Node3D.new()
			node3d.name = "ThirdPersonCameraContainer"
			add_child(node3d)
			remove_child(child)
			node3d.add_child(child)
			camera = child


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(escape_action):
		if input_enabled:
			disable_input()
			input_enabled = false
		else:
			enable_input()
			input_enabled = true


## Disable player input
func disable_input() -> void:
	for child in get_children():
		if child is ThirdPersonKeyboardInput:
			child.disable()
		if child is ThirdPersonMouseInput:
			child.disable()


## Enable player input
func enable_input() -> void:
	for child in get_children():
		if child is ThirdPersonKeyboardInput:
			child.enable()
		if child is ThirdPersonMouseInput:
			child.enable()
