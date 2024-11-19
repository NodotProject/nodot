## A node to manage the idle state of a NodotCharacter3D
class_name CharacterIdle3D extends CharacterExtensionBase3D

var move_state_node: CharacterMove3D

func setup():
	if !state_machine.state:
		state_machine.state = name
	move_state_node = Nodot.get_first_sibling_of_type(self, CharacterMove3D)
	
func physics_process(delta: float) -> void:
	if character.direction2d != Vector2.ZERO:
		state_machine.transition(move_state_node.name)
