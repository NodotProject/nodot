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

var was_on_floor: bool = true

func ready():
	if !enabled:
		return

	InputManager.register_action(climb_action, KEY_W)
	InputManager.register_action(descend_action, KEY_S)

	register_handled_states(["idle", "walk", "sprint", "jump", "climb"])

	sm.add_valid_transition("idle", "climb")
	sm.add_valid_transition("walk", "climb")
	sm.add_valid_transition("sprint", "climb")
	sm.add_valid_transition("jump", "climb")
	sm.add_valid_transition("climb", "idle")
	
func state_updated(old_state: int, new_state: int):
	if new_state == state_ids["climb"]:
		was_on_floor = true
		

func physics(delta: float):
	if !enabled:
		return

	if sm.state == state_ids["climb"]:
		if Input.is_action_pressed(climb_action):
			character.velocity.y = climb_velocity
		elif Input.is_action_pressed(descend_action):
			character.velocity.y = -climb_velocity
		elif Input.is_action_pressed(jump_action):
			sm.set_state(state_ids["idle"])
			sm.set_state(state_ids["jump"])
		else:
			character.velocity.y = 0.0
	
		var is_on_floor = character._is_on_floor()
		if is_on_floor and was_on_floor == false:
			sm.set_state(state_ids["idle"])
		
		was_on_floor = is_on_floor
			
	character.move_and_slide()
