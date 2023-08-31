## The base class for Nodot characters
class_name NodotCharacter3D extends CharacterBody3D

## (optional) The character state machine. If not assigned, is created automatically
@export var sm: StateMachine
## Is the character used by the player
@export var is_current_player: bool = false
@export var camera: Camera3D = Camera3D.new()

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
	
	if current_camera != camera3d:
	
		emit_signal("current_camera_changed", current_camera, camera3d)
		
		if current_camera:
			current_camera.current = false
			
		current_camera = camera3d
		current_camera.current = true
		
		toggle_viewport_camera(camera3d == camera)

## Reset the active camera to the character
func reset_current_camera():
	set_current_camera(camera)
			
## Toggle any viewport cameras
func toggle_viewport_camera(set_current: bool):
	var viewport = Nodot.get_first_child_of_type(self, FirstPersonViewport)
	if viewport:
		if set_current:
			viewport.show()
		else:
			viewport.hide()

## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float) -> void:
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

## If in multiplayer mode this checks if the client has authority. If singleplayer it will always return true
func is_authority():
	if !NetworkManager.enabled or is_multiplayer_authority():
		return true
	else:
		return false
		
## If in multiplayer mode this checks if the client owns this node. If singleplayer it will always return true
func is_authority_owner():
	if !NetworkManager.enabled or get_multiplayer_authority() == multiplayer.get_unique_id():
		return true
	else:
		return false
		
## If in multiplayer mode, this checks of the client is the host. If singleplayer it will always return true
func is_host():
	if !NetworkManager.enabled or multiplayer.is_server():
		return true
	else:
		return false
		
