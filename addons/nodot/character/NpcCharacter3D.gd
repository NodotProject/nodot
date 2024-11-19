## The base class for Nodot NPC characters
class_name NpcCharacter3D extends CharacterBody3D

## (optional) The character state machine. If not assigned, is created automatically
@export var sm: StateMachine
@export var nav: NavigationAgent3D
@export var turn_rate: float = 0.1

var target_position: Vector3 = Vector3.ZERO: set = _set_target_position
var at_destination: bool = false

func _notification(what: int):
	if what == NOTIFICATION_READY:
		if nav:
			nav.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)

func _is_on_floor() -> Node:
	var collision_info: KinematicCollision3D = move_and_collide(Vector3(0, -0.1, 0), true)
	if !collision_info: return null
	if collision_info.get_collision_count() == 0: return null
	if collision_info.get_angle() > floor_max_angle: return null
	if global_position.y - collision_info.get_position().y < 0: return null
	return collision_info.get_collider(0)

func _set_target_position(new_position: Vector3):
	target_position = new_position
	if nav:
		nav.set_target_position(new_position)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	
## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float = turn_rate) -> void:
	if Vector2(target_position.x, target_position.z).is_equal_approx(Vector2(global_position.x, global_position.z)):
		return
	# First look directly at the target
	var initial_rotation = rotation
	look_at(target_position)
	rotation.x = initial_rotation.x
	rotation.z = initial_rotation.z
	# Then lerp the next rotation
	var target_rot = rotation
	rotation.y = lerp_angle(initial_rotation.y, target_rot.y, weight)
