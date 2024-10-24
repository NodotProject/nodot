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
	
	handled_state = &"jump"

func can_enter() -> bool:
	return [&"idle", &"walk", &"sprint"].has(sm.old_state)

func enter() -> void:
	if not is_authority_owner(): return
	
	jump()

func input(_event):
	if not is_authority_owner(): return
	
	if !character.was_on_floor:
		return
		
	if Input.is_action_pressed(jump_action):
		sm.set_state(&"jump")
		
func jump() -> void:
	character.velocity.y = jump_velocity
