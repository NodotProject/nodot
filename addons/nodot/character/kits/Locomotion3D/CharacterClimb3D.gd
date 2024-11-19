## A node to manage Climb movement of a NodotCharacter3D
class_name CharacterClimb3D extends CharacterExtensionBase3D

## How high the character can climb
@export var climb_velocity := 4.0

@export_subgroup("Input Actions")
## The input action name for climbing
@export var climb_action: String = "up"
## The input action name for descending
@export var descend_action: String = "down"
## The input action name for jumping off the ladder
@export var jump_action: String = "jump"

var idle_state_handler: StateHandler
var was_on_floor: bool = true

func setup():
	InputManager.register_action(climb_action, KEY_W)
	InputManager.register_action(descend_action, KEY_S)
	idle_state_handler = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)
	
func enter(_old_state: StateHandler):
	character.override_movement = true
	was_on_floor = true
	
func exit(_old_state: StateHandler):
	character.override_movement = false
		
func physics_process(delta: float):
	if Input.is_action_pressed("jump"):
		# TODO: add a little velocity in the faced direction
		state_machine.transition(idle_state_handler.name)
		
	var ascend_velocity = climb_velocity
	var descend_velocity = -climb_velocity
	
	if character:
		var view_angle = character.head.rotation.x
		if view_angle < 0.0:
			ascend_velocity = -climb_velocity
			descend_velocity = climb_velocity
	
	if Input.is_action_pressed(climb_action):
		character.velocity.y = ascend_velocity
	elif Input.is_action_pressed(descend_action):
		character.velocity.y = descend_velocity
	else:
		character.velocity.y = 0.0
			
	character.velocity.x = lerp(character.velocity.x, 0.0, delta * 10.0)
	character.velocity.z = lerp(character.velocity.z, 0.0, delta * 10.0)

	var is_on_floor = character._is_on_floor()
	if is_on_floor and was_on_floor == false:
		state_machine.set_state(idle_state_handler.name)
	
	was_on_floor = is_on_floor != null
		
	character.move_and_slide()
