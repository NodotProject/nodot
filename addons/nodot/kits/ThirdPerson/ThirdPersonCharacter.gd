## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled: bool = true

var submerge_handler: CharacterSwim3D

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
	
	if is_current_player:
		PlayerManager.node = self
		set_current_camera(camera)
			
	if !sm:
		sm = StateMachine.new()
		add_child(sm)
		
	submerge_handler = Nodot.get_first_child_of_type(self, CharacterSwim3D)


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
