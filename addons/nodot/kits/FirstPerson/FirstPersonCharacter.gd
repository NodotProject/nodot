## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled := true
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
## The maximum speed a character can fall
@export var terminal_velocity := 190.0
## The camera field of view
@export var fov := 75.0
## Minimum amount of fall damage before it is actually applied
@export var minimum_fall_damage: float = 5.0
## The amount of fall damage to inflict when hitting the ground at velocity (0 for disabled)
@export var fall_damage_multiplier: float = 0.5

@export_subgroup("Third Person Controls")
## Strafing enabled. Otherwise the character will turn to face the movement direction
@export var strafing: bool = true
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1

## Constructs the step up movement vector.
@onready var step_vector: Vector3 = Vector3(0, step_height, 0)

## Triggered when the character takes fall damage
signal fall_damage(amount: float)

var head: Node3D
var health: Health
var was_on_floor: bool = false
var floor_body: Node3D;
# Velocity of the previous frame
var previous_velocity: float = 0.0
# Peak velocity of the last 0.1 seconds
var peak_recent_velocity: Vector3 = Vector3.ZERO
var peak_recent_velocity_timer: float = 0.0
var override_movement: bool = false
var character_colliders: UniqueSet = UniqueSet.new()
var direction2d := Vector2.ZERO
var look_angle := Vector2.ZERO
var input_states: Dictionary = {}
var direction3d: Vector3 = Vector3.ZERO
var third_person_camera_container: Node3D

func _enter_tree() -> void:
	if !sm:
		sm = StateMachine.new()
		add_child(sm)
	
	if !has_node("Head"):
		head = Node3D.new()
		head.name = "Head"
		camera.name = "Camera3D"
		head.add_child(camera)
		add_child(head)

	health = Nodot.get_first_child_of_type(self, Health)
	
	PlayerManager.players.add(self)
	if NetworkManager.enabled:
		set_multiplayer_authority(int(str(name)), true)

func _ready() -> void:
	camera.fov = fov

	if has_node("Head"):
		head = get_node("Head")
		camera = get_node("Head/Camera3D")
	
	if is_multiplayer_authority() and is_current_player:
		set_current_player()
		
	if camera:
		third_person_camera_container = camera.get_parent()
	
	if has_method("_after_ready"):
		call("_after_ready")

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	_calculate_peak_recent_velocity(delta)
	_process_fall_damage()
	_process_look_angle()
	
	if override_movement: return
	move(delta)

func _calculate_peak_recent_velocity(delta: float):
	peak_recent_velocity_timer += delta
	if peak_recent_velocity_timer > 0.05:
		peak_recent_velocity_timer = 0.0
	else:
		var max_velocity = max(abs(velocity.x), abs(velocity.y), abs(velocity.z))
		var old_max_velocity = max(abs(peak_recent_velocity.x), abs(peak_recent_velocity.y), abs(peak_recent_velocity.z))
		if old_max_velocity < max_velocity:
			peak_recent_velocity = cap_velocity(velocity)
		else:
			peak_recent_velocity = lerp(peak_recent_velocity, Vector3.ZERO, delta)

func _process_look_angle():
	if !input_enabled: return
	
	# Handle look left and right
	rotate_object_local(Vector3(0, 1, 0), look_angle.x)
	
	# Handle look up and down
	head.rotate_object_local(Vector3(1, 0, 0), look_angle.y)
	
	head.rotation.x = clamp(head.rotation.x, -1.57, 1.57)
	head.rotation.z = 0
	head.rotation.y = 0

func _process_fall_damage():
	var on_floor = _is_on_floor() != null
	if !health or fall_damage_multiplier <= 0.0:
		was_on_floor = on_floor
		floor_body = _is_on_floor();
		return
	
	if !was_on_floor:
		floor_body = null;
		if on_floor:
			var falling_velocity = abs(previous_velocity)
			var damage = falling_velocity * fall_damage_multiplier
			if damage > minimum_fall_damage:
				health.add_health(-damage)
				fall_damage.emit(damage)
		else:
			previous_velocity = velocity.y
	was_on_floor = on_floor

func _is_current_player_changed(new_value: bool):
	is_current_player = new_value
	input_enabled = new_value

## Set the character as the current player
func set_current_player():
	if not is_multiplayer_authority(): return
	
	is_current_player = true
	PlayerManager.node = self
	set_current_camera(camera)

func cap_velocity(velocity: Vector3) -> Vector3:
	# Check if the velocity exceeds the terminal velocity
	if velocity.length() > terminal_velocity:
		# Cap the velocity to the terminal velocity, maintaining direction
		return velocity.normalized() * terminal_velocity
	else:
		# If it's below terminal velocity, return it unchanged
		return velocity

func move(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	var basis: Basis
	if camera:
		basis = current_camera.global_transform.basis
	else:
		basis = transform.basis
	direction3d = (basis * Vector3(direction2d.x, 0, direction2d.y))
		
	if !was_on_floor:
		move_air(delta)
	else:
		move_ground(delta)
	
	set_rigid_interaction()
	
func set_rigid_interaction():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var lin_vel: Vector3 = c.get_collider().linear_velocity
			var char_basis: Vector3 = transform.basis.z
			
			if sign(char_basis.x) == sign(lin_vel.x) and sign(char_basis.z) == sign(lin_vel.z):
				c.get_collider().linear_velocity.x *= -0.1
				c.get_collider().linear_velocity.z *= -0.1
			elif sign(char_basis.x) == sign(lin_vel.x):
				c.get_collider().linear_velocity.x *= -0.1
			elif sign(char_basis.z) == sign(lin_vel.z):
				c.get_collider().linear_velocity.z *= -0.1
			
			c.get_collider().apply_central_impulse(-c.get_normal() * 0.25 * c.get_collider().mass)

func move_air(delta: float) -> void:
	velocity.y = min(terminal_velocity, velocity.y - gravity * delta)
	
	var final_speed: float = movement_speed * delta * 100
	
	if direction3d != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction3d.x * final_speed, 0.025)
		velocity.z = lerp(velocity.z, direction3d.z * final_speed, 0.025)
	
	move_and_slide()

func move_ground(delta: float) -> void:
	var final_speed: float = movement_speed * delta * 100
	
	if direction3d == Vector3.ZERO:
		var final_friction = friction if friction >= 0 else final_speed
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)
	else:
		velocity.x = direction3d.x * final_speed
		velocity.z = direction3d.z * final_speed
		
		if camera and !strafing:
			var cached_rotation = third_person_camera_container.global_rotation
			face_target(position + direction3d, turn_rate)
			third_person_camera_container.global_rotation = cached_rotation
			
	stair_step(delta)
	
func stair_step(delta: float):
		# --- Stairs logic ---
	var starting_position: Vector3 = global_position
	var starting_velocity: Vector3 = velocity
	
	# Start by moving our character body by its normal velocity.
	move_and_slide()
	if !stepping_enabled or !was_on_floor:
		return
	
	# Next, we store the resulting position for later, and reset our character's
	#    position and velocity values.
	var slide_position: Vector3 = global_position
	global_position = starting_position
	velocity = starting_velocity
	
	# After that, we move_and_collide() them up by step_height, move_and_slide()
	#    and move_and_collide() back down
	move_and_collide(step_vector)
	move_and_slide()
	move_and_collide(-step_vector)
	
	# Finally, we test move down to see if they'll touch the floor once we move
	#    them back down to their starting Y-position, if not, they fall,
	#    otherwise, they step down by -step_height.
	if !test_move(global_transform, -step_vector):
		move_and_collide(-step_vector)
		
	# Now that we've done all that, we get the distance moved for both movements
	#    and go with whichever one moves us further, as overhangs could impede 
	#    movement if we were to only step.
	var slide_distance: float = starting_position.distance_to(slide_position)
	var step_distance: float = starting_position.distance_to(global_position)
	if slide_distance > step_distance or !was_on_floor:
		global_position = slide_position
	# --- Step up logic ---
	
	velocity.y = lerp(velocity.y, 0.0, delta * 2.0)
