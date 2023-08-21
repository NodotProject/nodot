# A base node to add extension logic to NodotCharacter3D
class_name CharacterExtensionBase3D extends StateHandler

## The NodotCharacter3D to apply this node to. Uses parent if unset.
@export var character: NodotCharacter3D

var third_person_camera: ThirdPersonCamera
var active_camera: Camera3D

func _enter_tree():
	if not character:
		var parent = get_parent()
		if parent is NodotCharacter3D:
			character = parent
		else:
			enabled = false
			return
			
	if character.camera is ThirdPersonCamera:
		third_person_camera = character.camera
	
	sm = character.sm

## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float) -> void:
	# First look directly at the target
	var initial_rotation = character.rotation
	character.look_at(target_position)
	character.rotation.x = initial_rotation.x
	character.rotation.z = initial_rotation.z
	# Then lerp the next rotation
	var target_rot = character.rotation
	character.rotation.y = lerp_angle(initial_rotation.y, target_rot.y, weight)

## If in multiplayer mode this checks if the client has authority. If singleplayer it will always return true
func is_authority():
	if !NetworkManager.enabled or character.is_multiplayer_authority():
		return true
	else:
		return false
		
## If in multiplayer mode this checks if the client owns this node. If singleplayer it will always return true
func is_authority_owner():
	if !NetworkManager.enabled or character.get_multiplayer_authority() == multiplayer.get_unique_id():
		return true
	else:
		return false
		
## If in multiplayer mode, this checks of the client is the host. If singleplayer it will always return true
func is_host():
	if !NetworkManager.enabled or multiplayer.is_server():
		return true
	else:
		return false
