## The base class for Nodot characters
class_name NodotCharacter3D extends CharacterBody3D

## (optional) The character state machine. If not assigned, is created automatically
@export var sm: StateMachine

func _is_on_floor() -> bool:
	var collision_info: KinematicCollision3D = move_and_collide(Vector3(0,-0.1,0),true)
	if !collision_info: return false
	if collision_info.get_collision_count() == 0: return false
	if collision_info.get_angle() > floor_max_angle: return false
	if global_position.y - collision_info.get_position().y < 0: return false
	return true
