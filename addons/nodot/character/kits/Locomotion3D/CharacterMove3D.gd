## A node to manage WASD of a NodotCharacter3D
class_name CharacterMove3D extends CharacterExtensionBase3D

## How fast the character can move while sprinting (higher = faster)
@export var sprint_speed_multiplier := 1.5

@export_subgroup("Input Actions")
## The input action name for sprinting
@export var sprint_action: String = "sprint"

var idle_state_node: CharacterIdle3D
var original_speed: float = 0.0
var sprint_enabled: bool = false

func setup():
	original_speed = character.movement_speed
	InputManager.register_action(sprint_action, KEY_SHIFT)
	idle_state_node = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)

func physics_process(_delta):
	var final_speed: float = original_speed
	if character.input_enabled and character.direction3d != Vector3.ZERO:
		if Input.is_action_pressed(sprint_action):
			final_speed = original_speed * sprint_speed_multiplier
			sprint_enabled = true
		else:
			sprint_enabled = false

	character.movement_speed = final_speed

	if character.direction3d.is_equal_approx(Vector3.ZERO):
		state_machine.transition(idle_state_node.name)
