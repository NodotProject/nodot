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
	if new_state == state_ids["jump"]:
		jump()

func jump() -> void:
	character.velocity.y = jump_velocity
	
func input(event: InputEvent):
	if not is_authority_owner(): return
	
	if event.is_action_pressed(jump_action):
		character.input_states["jump"] = true

func physics(_delta) -> void:
	character.input_states["jump"] = get_input()
	action()

func can_jump():
	if character.was_on_floor:
		return true
	return false
	
func action():
	if !can_jump(): return
	
	if character.input_states.get("jump"):
		if character.floor_body and character.floor_body.has_meta("soft_floor"): return
		sm.set_state(state_ids["jump"])
	elif sm.state == state_ids["jump"]:
		sm.set_state(state_ids["land"])
	elif sm.state == state_ids["land"]:
		sm.set_state(state_ids["idle"])

func get_input():
	return Input.is_action_pressed(jump_action)
