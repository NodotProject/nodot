## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled: bool = true
## How fast the character can move
@export var movement_speed := 1.0
## Friction when stopping. The smaller the value, the more you slide (-1 to disable)
@export var friction: float = 1.0
## Minimum amount of fall damage before it is actually applied
@export var minimum_fall_damage: float = 5.0
## The amount of fall damage to inflict when hitting the ground at velocity (0 for disabled)
@export var fall_damage_multiplier: float = 0.5
## Strafing enabled. Otherwise the character will turn to face the movement direction
@export var strafing: bool = false
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1
## Enables stepping up stairs.
@export var stepping_enabled: bool = true
## Maximum height for a ledge to allow stepping up.
@export var step_height: float = 0.5

## Constructs the step up movement vector.
@onready var step_vector: Vector3 = Vector3(0, step_height, 0)

## Triggered when the character takes fall damage
signal fall_damage(amount: float)

var submerge_handler: CharacterSwim3D
var override_movement: bool = false
var health: Health
var was_on_floor: bool = false
var floor_body: Node3D;
# Velocity of the previous frame
var previous_velocity: float = 0.0
# Peak velocity of the last 0.1 seconds
var peak_recent_velocity: Vector3 = Vector3.ZERO
var peak_recent_velocity_timer: float = 0.0
var character_colliders: UniqueSet = UniqueSet.new()
var direction2d := Vector2.ZERO
var look_angle := Vector2.ZERO
var input_states: Dictionary = {}
var direction3d: Vector3 = Vector3.ZERO
var third_person_camera_container: Node3D

func _enter_tree() -> void:
	super._enter_tree()
	
	# Set up camera container
	for child in get_children():
		if child is ThirdPersonCamera:
			var node3d = Node3D.new()
			node3d.name = "ThirdPersonCameraContainer"
			add_child(node3d)
			remove_child(child)
			node3d.add_child(child)
			camera = child
			third_person_camera_container = node3d
	
	if is_current_player:
		PlayerManager.node = self
		set_current_camera(camera)
		
	submerge_handler = Nodot.get_first_child_of_type(self, CharacterSwim3D)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	_calculate_peak_recent_velocity(delta)
	_process_fall_damage()
	
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
	
func move(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	var basis: Basis
	if camera:
		var camera_basis = current_camera.global_transform.basis

		# Flattened forward and right vectors (ignore Y component)
		var flat_forward = camera_basis.z
		flat_forward.y = 0
		flat_forward = flat_forward.normalized()

		var flat_right = camera_basis.x
		flat_right.y = 0
		flat_right = flat_right.normalized()

		# Construct movement direction on XZ plane
		direction3d = (flat_forward * direction2d.y + flat_right * direction2d.x)

		if direction3d != Vector3.ZERO:
			direction3d = direction3d.normalized()
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
	
	if direction3d == Vector3.ZERO:
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

## Disable player input
func disable_input() -> void:
	direction2d = Vector2.ZERO
	for child in get_children():
		if child is ThirdPersonKeyboardInput:
			child.disable()
		if child is ThirdPersonMouseInput:
			child.disable()

## Enable player input
func enable_input() -> void:
	for child in get_children():
		if child is ThirdPersonKeyboardInput:
			child.enable()
		if child is ThirdPersonMouseInput:
			child.enable()

func disable_mouse_input():
	for child in get_children():
		if child is ThirdPersonMouseInput:
			child.disable()
			
func enable_mouse_input() -> void:
	for child in get_children():
		if child is ThirdPersonMouseInput:
			child.enable()
