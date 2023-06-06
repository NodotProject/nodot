## The base class for Nodot characters
class_name NodotCharacter3D extends CharacterBody3D

## (optional) The character state machine. If not assigned, is created automatically
@export var sm: StateMachine
## Is the character used by the player
@export var is_current_player: bool = false

signal current_camera_changed(old_camera: Camera3D, new_camera: Camera3D)

var current_camera: Camera3D

func _is_on_floor() -> bool:
	var collision_info: KinematicCollision3D = move_and_collide(Vector3(0,-0.1,0),true)
	if !collision_info: return false
	if collision_info.get_collision_count() == 0: return false
	if collision_info.get_angle() > floor_max_angle: return false
	if global_position.y - collision_info.get_position().y < 0: return false
	return true

## Change the active camera
func set_current_camera(camera3d: Camera3D):
	if !is_current_player:
		return
		
	emit_signal("current_camera_changed", current_camera, camera3d)
	
	if current_camera:
		current_camera.current = false
		camera3d.current = true
		
	current_camera = camera3d
