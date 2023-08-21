## A node to manage Jump movement of a NodotCharacter3D
class_name CharacterJump3D extends CharacterExtensionBase3D

## How high the character can jump
@export var jump_velocity := 4.5

@export_subgroup("Input Actions")
## The input action name for jumping
@export var jump_action: String = "jump"

func ready():
	if !enabled:
		return
	
	InputManager.register_action(jump_action, KEY_SPACE)
	
	register_handled_states(["jump", "land", "idle", "walk", "sprint", "crouch", "prone"])
	
	sm.add_valid_transition("idle", ["jump"])
	sm.add_valid_transition("walk", ["jump"])
	sm.add_valid_transition("sprint", ["jump"])
	sm.add_valid_transition("jump", ["land"])
	sm.add_valid_transition("land", ["idle", "walk", "sprint"])
	sm.add_valid_transition("crouch", ["jump"])
	sm.add_valid_transition("prone", ["jump"])

func state_updated(old_state: int, new_state: int) -> void:
	if not is_authority_owner(): return
	
	if new_state == state_ids["jump"]:
		jump()

func jump() -> void:
	character.velocity.y = jump_velocity

func physics(delta: float) -> void:
	if not is_authority_owner(): return
	
	if !character._is_on_floor():
		return
		
	if Input.is_action_pressed(jump_action):
		sm.set_state(state_ids["jump"])
	elif sm.state == state_ids["jump"]:
		sm.set_state(state_ids["land"])
		
