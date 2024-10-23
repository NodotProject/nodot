## A node to manage Mouse and joystick NodotCharacter3D
class_name CharacterLook3D extends CharacterExtensionBase3D

## Handled states
@export var handle_states: Array[String] = ["idle", "walk", "sprint", "jump", "land", "crouch", "prone", "climb", "fly", "swim", "swim_idle", "zerog"]
## The Head for the first person character
@export var head: Node3D

func ready():
	if !enabled: return
	
	register_handled_states(handle_states)
		
func physics(delta: float) -> void:
	if not is_authority(): return
	if !character.input_enabled: return
	
		# Handle look left and right
	character.rotate_object_local(Vector3(0, 1, 0), character.look_angle.x)
	
	# Handle look up and down
	head.rotate_object_local(Vector3(1, 0, 0), character.look_angle.y)
	
	head.rotation.x = clamp(head.rotation.x, -1.57, 1.57)
	head.rotation.z = 0
	head.rotation.y = 0
