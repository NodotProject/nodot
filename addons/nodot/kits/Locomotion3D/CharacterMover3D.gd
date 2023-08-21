## A node to manage WASD and Jump movement of a NodotCharacter3D
class_name CharacterMover3D extends CharacterExtensionBase3D

## Gravity for the character
@export var gravity: float = 9.8
## Friction when stopping. The smaller the value, the more you slide (-1 to disable)
@export var friction: float = 1.0
## Enables stepping up stairs.
@export var stepping_enabled: bool = true
## Maximum height for a ledge to allow stepping up.
@export var step_height: float = 0.5
## How fast the character can move
@export var movement_speed := 5.0
## How fast the character can move while sprinting (higher = faster)
@export var sprint_speed_multiplier := 2.0
## The maximum speed a character can fall
@export var terminal_velocity := 190.0

@export_subgroup("Third Person Controls")
## Strafing enabled. Otherwise the character will turn to face the movement direction
@export var strafing: bool = true
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1

@export_subgroup("Input Actions")
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for moving forward
@export var up_action: String = "up"
## The input action name for moving backwards
@export var down_action: String = "down"
## The input action name for sprinting
@export var sprint_action: String = "sprint"

## Constructs the step up movement vector.
@onready var step_vector: Vector3 = Vector3(0, step_height, 0)

var direction: Vector3 = Vector3.ZERO
var sprint_speed = false
var third_person_camera_container: Node3D

func ready():
	if !enabled:
		return
	
	InputManager.register_action(left_action, KEY_A)
	InputManager.register_action(right_action, KEY_D)
	InputManager.register_action(up_action, KEY_W)
	InputManager.register_action(down_action, KEY_S)
	InputManager.register_action(sprint_action, KEY_SHIFT)
	
	register_handled_states(["idle", "walk", "sprint", "jump", "land", "crouch", "prone"])
		
	sm.add_valid_transition("idle", ["walk", "sprint"])
	sm.add_valid_transition("walk", ["idle", "walk", "sprint"])
	sm.add_valid_transition("sprint", ["idle", "walk"])
	
	if third_person_camera:
		third_person_camera_container = third_person_camera.get_parent()
	
func state_updated(old_state: int, new_state: int) -> void:
	if not is_authority(): return
		
	var sprint_id = state_ids["sprint"]
	
	if new_state == state_ids["jump"]:
		if old_state == sprint_id:
			sprint_speed = true
	elif new_state == state_ids["land"] or old_state == sprint_id:
		sprint_speed = false
	elif new_state == sprint_id:
		sprint_speed = true
		
func get_movement_speed(delta: float) -> float:
	var final_speed = movement_speed
	if sprint_speed:
		final_speed = movement_speed * sprint_speed_multiplier
	return final_speed * delta * 100

func physics(delta: float) -> void:
	if not is_authority(): return
	
	if character.input_enabled:
		var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
		var basis: Basis
		if third_person_camera:
			basis = character.current_camera.global_transform.basis
		else:
			basis = character.transform.basis
		direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction == Vector3.ZERO:
			sm.set_state(state_ids["idle"])
		else:
			if Input.is_action_pressed(sprint_action):
				sm.set_state(state_ids["sprint"])
			else:
				sm.set_state(state_ids["walk"])
		
	if !character._is_on_floor():
		move_air(delta)
	else:
		move_ground(delta)

func move_air(delta: float) -> void:
	character.velocity.y = min(terminal_velocity, character.velocity.y - gravity * delta)
	
	if direction != Vector3.ZERO:
		var final_speed = get_movement_speed(delta)
		character.velocity.x = lerp(character.velocity.x, direction.x * final_speed, 0.025)
		character.velocity.z = lerp(character.velocity.z, direction.z * final_speed, 0.025)
	
	character.move_and_slide()

func move_ground(delta: float) -> void:
	var final_speed = get_movement_speed(delta)
	
	if direction == Vector3.ZERO:
		var final_friction = friction if friction >= 0 else final_speed
		character.velocity.x = move_toward(character.velocity.x, 0, friction)
		character.velocity.z = move_toward(character.velocity.z, 0, friction)
	else:
		character.velocity.x = direction.x * final_speed
		character.velocity.z = direction.z * final_speed
		
		if third_person_camera and !strafing:
			var cached_rotation = third_person_camera_container.global_rotation
			face_target(character.position + direction, turn_rate)
			third_person_camera_container.global_rotation = cached_rotation
	
	# --- Stairs logic ---
	var starting_position: Vector3 = character.global_position
	var starting_velocity: Vector3 = character.velocity
	
	# Start by moving our character body by its normal velocity.
	character.move_and_slide()
	if sm.state == state_ids["jump"] or !stepping_enabled or !character._is_on_floor(): return
	
	# Next, we store the resulting position for later, and reset our character's
	#    position and velocity values.
	var slide_position: Vector3 = character.global_position
	character.global_position = starting_position
	character.velocity = starting_velocity
	
	# After that, we move_and_collide() them up by step_height, move_and_slide()
	#    and move_and_collide() back down
	character.move_and_collide(step_vector)
	character.move_and_slide()
	character.move_and_collide(-step_vector)
	
	# Finally, we test move down to see if they'll touch the floor once we move
	#    them back down to their starting Y-position, if not, they fall,
	#    otherwise, they step down by -step_height.
	if !character.test_move(character.global_transform, -step_vector):
		character.move_and_collide(-step_vector)
		
	# Now that we've done all that, we get the distance moved for both movements
	#    and go with whichever one moves us further, as overhangs could impede 
	#    movement if we were to only step.
	var slide_distance: float = starting_position.distance_to(slide_position)
	var step_distance: float = starting_position.distance_to(character.global_position)
	if slide_distance > step_distance or !character._is_on_floor():
		character.global_position = slide_position
	# --- Step up logic ---
