## A node to manage Prone movement of a NodotCharacter3D
class_name CharacterProne3D extends CharacterExtensionBase3D

## The collision shape to shrink when proned
@export var collision_shape: CollisionShape3D
## The new height of the collision shape
@export var prone_height: float = 0.1
## The associated character mover
@export var character_mover: CharacterMover3D
## The new movement speed
@export var movement_speed: float = 0.5

@export_subgroup("Input Actions")
## The input action name for proning
@export var prone_action: String = "prone"

var head: Node3D
var initial_movement_speed: float = 5.0
var initial_head_position: Vector3
var target_head_position: Vector3
var collider_height: float = 0.0

func ready():
	if !enabled:
		return
	
	InputManager.register_action(prone_action, KEY_X)
	
	handled_states = [&"prone", &"stand", &"walk"]
	
	if collision_shape and collision_shape.shape and collision_shape.shape is CapsuleShape3D:
		collider_height = collision_shape.shape.height
		
	if character_mover:
		initial_movement_speed = character_mover.movement_speed
	
	head = character.get_node("Head")
	initial_head_position = head.position

func can_enter() -> bool:
	return [&"idle", &"walk", &"sprint", &"prone"].has(sm.old_state)
	
func enter() -> void:
	if sm.state == &"prone":
		collision_shape.rotation.x = PI / 2
		target_head_position = Vector3(head.position.x, 0.0, -(collider_height / 2))
		character.velocity = Vector3.ZERO
		if character_mover:
			character_mover.movement_speed = movement_speed
	elif sm.state == &"stand":
		collision_shape.rotation.x = 0.0
		if character_mover:
			character_mover.movement_speed = initial_movement_speed
		head.position = initial_head_position
		sm.set_state(&"idle")
		
func exit() -> void:
	collision_shape.rotation.x = 0.0
	if character_mover:
		character_mover.movement_speed = initial_movement_speed
	head.position = initial_head_position

func input(event: InputEvent) -> void:
	if Input.is_action_pressed(prone_action):
		sm.set_state(&"prone")
	elif Input.is_action_just_released(prone_action):
		sm.set_state(&"stand")

func physics(_delta):
	if sm.state == &"prone":
		head.position = lerp(head.position, target_head_position, 0.1)
		character.move_and_slide()
