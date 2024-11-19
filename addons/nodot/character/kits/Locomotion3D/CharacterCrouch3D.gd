## A node to manage Crouch movement of a NodotCharacter3D
class_name CharacterCrouch3D extends CharacterExtensionBase3D

## The collision shape to shrink when crouched
@export var collision_shape: CollisionShape3D
## The new height of the collision shape
@export var crouch_height: float = 1.0
## The new movement speed
@export var movement_speed: float = 1.0

@export_subgroup("Input Actions")
## The input action name for crouching
@export var crouch_action: String = "crouch"

var idle_state_handler: CharacterIdle3D
var shape_initial_height: float
var initial_movement_speed: float = 5.0

func _input(_event):
	if Input.is_action_pressed(crouch_action):
		state_machine.transition(name)
	elif Input.is_action_just_released(crouch_action):
		state_machine.transition(idle_state_handler.name)
		
func setup():
	InputManager.register_action(crouch_action, KEY_CTRL)
	shape_initial_height = get_collision_shape_height()
	initial_movement_speed = character.movement_speed
	idle_state_handler = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)

func enter(_old_state) -> void:
	apply_collision_shape_height(crouch_height)
	character.movement_speed = movement_speed
	
func exit(_new_state) -> void:
	apply_collision_shape_height(shape_initial_height)
	character.movement_speed = initial_movement_speed

func apply_collision_shape_height(crouch_height: float):
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = crouch_height
		elif collision_shape.shape is BoxShape3D:
			collision_shape.shape.size.y = crouch_height

func get_collision_shape_height() -> float:
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is CapsuleShape3D:
			return collision_shape.shape.height
		elif collision_shape.shape is BoxShape3D:
			return collision_shape.shape.size.y
	return 0.0
