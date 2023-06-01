## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled: bool = true
## Is the character used by the player
@export var is_current_player := false

@export_category("Input Actions")
## The input action name for pausing the game
@export var escape_action: String = "escape"

var camera: ThirdPersonCamera
var submerge_handler: CharacterSwim3D

func _enter_tree() -> void:
	if is_current_player:
		PlayerManager.node = self
		
	# Set up camera container
	for child in get_children():
		if child is ThirdPersonCamera:
			var node3d = Node3D.new()
			node3d.name = "ThirdPersonCameraContainer"
			add_child(node3d)
			remove_child(child)
			node3d.add_child(child)
			camera = child
			
	if !sm:
		sm = StateMachine.new()
		add_child(sm)
		
	submerge_handler = Nodot.get_first_child_of_type(self, CharacterSwim3D)


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
