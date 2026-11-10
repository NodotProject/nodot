## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends NodotCharacter3D

## Allow player input
@export var input_enabled := true
## Friction when stopping. The smaller the value, the more you slide (-1 to disable)
@export var friction: float = 1.0
## Enables stepping up stairs.
@export var stepping_enabled: bool = true
## Maximum height for a ledge to allow stepping up.
@export var step_height: float = 0.5
## How fast the character can move
@export var movement_speed := 5.0
## The camera field of view
@export var fov := 75.0
## Minimum amount of fall damage before it is actually applied
@export var minimum_fall_damage: float = 5.0
## The amount of fall damage to inflict when hitting the ground at velocity (0 for disabled)
@export var fall_damage_multiplier: float = 0.5
## The strength that the character will push rigidbodies
@export var push_strength: float = 0.5

## Head pitch limit (radians, = 89 deg) shared by every look path (mouse, pad, and any game
## code that turns the view, e.g. recoil — route those through [method rotate_look]). Short of 90 so the head's Euler pitch never reaches the pole,
## where reading `rotation` back off the basis flips it.
const PITCH_LIMIT := 1.5533430342749532

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

func _enter_tree() -> void:
	super._enter_tree()
	
	if !has_node(^"Head"):
		head = Node3D.new()
		head.name = &"Head"
		camera.name = &"Camera3D"
		head.add_child(camera)
		add_child(head)

	health = Nodot.get_first_child_of_type(self, Health)
	
	PlayerManager.players.add(self)
	if NetworkManager.enabled:
		set_multiplayer_authority(int(str(name)), true)

func _ready() -> void:

	if has_node(^"Head"):
		head = get_node(^"Head")
		camera = get_node(^"Head/Camera3D")
	
	if is_multiplayer_authority() and is_current_player:
		set_current_player()
		
	if camera:
		camera.fov = fov
	
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

## Rate-based look (gamepad stick) — FirstPersonJoypadInput writes [member look_angle] as
## this tick's rotation. Mouse look does NOT come through here: it is applied per event via
## [method rotate_look] so the view turns every rendered frame instead of every physics tick.
func _process_look_angle():
	if !input_enabled or look_angle == Vector2.ZERO: return
	rotate_look(look_angle.x, look_angle.y)

## Turn the view by [param yaw] (radians, + = left, applied to the body) and [param pitch]
## (radians, + = up, applied to the head), pitch clamped to ±[constant PITCH_LIMIT]. The one
## entry point for every view rotation (mouse, pad, recoil, sway): the head is written as a pure pitch
## (never rotate_object_local + read-back, which bounced the view off the pole when a flick
## crossed 90 deg), and yaw stays wrapped to ±PI.
func rotate_look(yaw: float, pitch: float) -> void:
	if yaw != 0.0:
		rotation.y = wrapf(rotation.y + yaw, -PI, PI)
	if pitch != 0.0 and head != null:
		head.rotation = Vector3(clampf(head.rotation.x + pitch, -PITCH_LIMIT, PITCH_LIMIT), 0.0, 0.0)

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
			
			c.get_collider().apply_central_impulse(-c.get_normal() * push_strength * c.get_collider().mass)

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
