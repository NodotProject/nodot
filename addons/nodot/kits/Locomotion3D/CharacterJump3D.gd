## A node to manage Jump movement of a NodotCharacter3D
class_name CharacterJump3D extends CharacterExtensionBase3D

## How high the character can jump
@export var jump_velocity := 4.5

@export_subgroup("Input Actions")
## The input action name for jumping
@export var jump_action: String = "jump"

var idle_state_node: CharacterIdle3D
var left_the_ground: bool = false

func _input(_event):
	if character.was_on_floor and Input.is_action_pressed(jump_action):
		state_machine.transition(name)

func setup():
	InputManager.register_action(jump_action, KEY_SPACE)
	idle_state_node = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)

func can_enter(old_state) -> bool:
	return character._is_on_floor() != null

func enter(_old_state) -> void:
	character.velocity.y = jump_velocity

func physics_process(_delta):
	if left_the_ground:
		if character._is_on_floor():
			state_machine.transition(idle_state_node.name)
			left_the_ground = false
	else:
		if !character._is_on_floor():
			left_the_ground = true
