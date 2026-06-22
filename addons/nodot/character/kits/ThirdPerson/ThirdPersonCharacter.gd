## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled: bool = true
## Target horizontal movement speed in metres/second
@export var movement_speed := 5.0
## Horizontal deceleration (m/s²) when no input; negative disables (slides forever)
@export var friction: float = 50.0
## Minimum amount of fall damage before it is actually applied
@export var minimum_fall_damage: float = 5.0
## The amount of fall damage to inflict when hitting the ground at velocity (0 for disabled)
@export var fall_damage_multiplier: float = 0.5
## Can control the character while its in the air
@export var air_control: bool = true
## Horizontal acceleration in m/s² applied while airborne (requires air_control)
@export var air_acceleration: float = 30.0
## Strafing enabled. Otherwise the character will turn to face the movement direction
@export var strafing: bool = false
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1
## Enables stepping up stairs.
@export var stepping_enabled: bool = true
## Maximum height for a ledge to allow stepping up.
@export var step_height: float = 0.5

## Triggered when the character takes fall damage
signal fall_damage(amount: float)

var air_time: float = 0.0
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
var speed_modifiers: Dictionary[String, float] = {}

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
	
	health = Nodot.get_first_child_of_type(self, Health)
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
	var floor_node = _is_on_floor()
	var on_floor = floor_node != null
	if !health or fall_damage_multiplier <= 0.0:
		was_on_floor = on_floor
		floor_body = floor_node
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
	if current_camera:
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
			# limit_length (not normalized) preserves analog joypad
			# magnitudes below 1.0 while still clamping keyboard diagonals.
			direction3d = direction3d.limit_length(1.0)
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
	air_time += delta
	velocity.y = max(-terminal_velocity, velocity.y - gravity * delta)
	
	if air_control and direction3d != Vector3.ZERO:
		var target_speed: float = get_current_speed()
		velocity.x = move_toward(velocity.x, direction3d.x * target_speed, air_acceleration * delta)
		velocity.z = move_toward(velocity.z, direction3d.z * target_speed, air_acceleration * delta)
		move_camera()
	
	move_and_slide()

func move_ground(delta: float) -> void:
	air_time = 0.0
	
	if direction3d == Vector3.ZERO:
		if friction >= 0.0:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
			velocity.z = move_toward(velocity.z, 0.0, friction * delta)
	else:
		var target_speed: float = get_current_speed()
		velocity.x = direction3d.x * target_speed
		velocity.z = direction3d.z * target_speed
		
		move_camera()
			
	stair_step(delta)

func move_camera(final_turn_rate: float = turn_rate):
	if current_camera and !strafing:
		var cached_basis: Basis
		if current_camera is ThirdPersonCamera:
			cached_basis = third_person_camera_container.global_transform.basis
		else:
			cached_basis = current_camera.global_transform.basis

		face_target(position + direction3d, final_turn_rate)

		if current_camera is ThirdPersonCamera:
			third_person_camera_container.global_transform.basis = cached_basis
		else:
			current_camera.global_transform.basis = cached_basis

func stair_step(delta: float):
	var start_position: Vector3 = global_position
	var start_velocity: Vector3 = velocity

	# Move by the current velocity first.
	move_and_slide()

	# Only attempt a manual step when grounded and this move bumped a wall-like
	# obstacle. Low steps the capsule can already roll over report as floor, so
	# they skip this branch and are resolved by the slide above (no fighting).
	if !stepping_enabled or !was_on_floor or !is_on_wall():
		velocity.y = lerp(velocity.y, 0.0, delta * 2.0)
		return

	# Remember the plain-slide result to fall back to.
	var slide_position: Vector3 = global_position
	var slide_velocity: Vector3 = velocity

	# Retry the move: lift up, slide forward, then drop back down onto the step.
	global_position = start_position
	velocity = start_velocity

	var step_vector: Vector3 = Vector3(0, step_height, 0)
	move_and_collide(step_vector)
	move_and_slide()
	var landing: KinematicCollision3D = move_and_collide(-step_vector)

	# Commit the step only if we landed on walkable floor, ended higher and
	# actually advanced. Otherwise restore the plain slide so the body never bobs
	# in place against an obstacle it cannot climb.
	var climbed: bool = global_position.y - start_position.y > 0.001
	var advanced: bool = (
		Vector2(global_position.x - start_position.x, global_position.z - start_position.z).length()
		> 0.001
	)
	var landed_flat: bool = landing != null and landing.get_angle() <= floor_max_angle

	if not (climbed and advanced and landed_flat):
		global_position = slide_position
		velocity = slide_velocity

	velocity.y = lerp(velocity.y, 0.0, delta * 2.0)

func get_current_speed() -> float:
	var speed := movement_speed
	for m in speed_modifiers.values():
		speed *= m
	return speed

func set_speed_modifier(source: String, multiplier: float) -> void:
	speed_modifiers[source] = multiplier

func remove_speed_modifier(source: String) -> void:
	speed_modifiers.erase(source)

## Disable player input
func disable_input() -> void:
	input_enabled = false
	direction2d = Vector2.ZERO
	for child in get_children():
		if child is ThirdPersonKeyboardInput:
			child.disable()
		if child is ThirdPersonMouseInput:
			child.disable()

## Enable player input
func enable_input() -> void:
	input_enabled = true
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
