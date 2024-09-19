## A camera for use with third person games
class_name ThirdPersonCamera extends Camera3D

## Camera default offset
@export var camera_offset: Vector3 = Vector3(0, 2, 5)
## Camera should move in front of objects that block vision of the character
@export var always_in_front: bool = true
## The target_position offset of the raycast (should be the middle of the character)
@export var raycast_offset: Vector3 = Vector3.ZERO
## Move the camera to the initial position after some inactivity (0.0 to disable)
@export var time_to_reset: float = 2.0
## Restrict vertical look angle
@export var vertical_clamp := Vector2(-1.36, 1.4)
## Enable camera movement only while camera_rotate_action input action is pressed
@export var lock_camera_rotation := false
## Rotate the ThirdPersonCharacter with the camera
@export var lock_character_rotation := false

var parent: Node3D
var raycast: RayCast3D
var time_since_last_move: float = 0.0

@onready var camera_container: Node3D = get_parent()
@onready var character: ThirdPersonCharacter = camera_container.get_parent()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings


func _enter_tree() -> void:
	if always_in_front:
		raycast = RayCast3D.new()
		raycast.hit_back_faces = false
		get_parent().add_child.call_deferred(raycast)


func _ready() -> void:
	parent = get_parent()
	position = camera_offset
	look_at(parent.global_position)

	raycast.position = parent.position + raycast_offset
	raycast.target_position = position - raycast_offset


func _physics_process(delta) -> void:
	if !current:
		return
	
	var look_angle = character.input_states["look_angle"]
	
	# Handle look left and right
	if lock_character_rotation:
		character.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
	else:
		camera_container.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
	
	# Handle look up and down
	rotate_object_local(Vector3(1, 0, 0), look_angle.x)

	rotation.x = clamp(rotation.x, vertical_clamp.x, vertical_clamp.y)
	
	if raycast:
		if raycast.is_colliding() and !raycast.hit_from_inside:
			var collider = raycast.get_collider()
			time_since_last_move = 0.0
			global_position = raycast.get_collision_point()
		else:
			position = lerp(position, camera_offset, 0.1)

	if time_to_reset > 0.0:
		if parent.rotation != Vector3.ZERO:
			time_since_last_move += delta
			if time_since_last_move > time_to_reset:
				parent.rotation = parent.rotation.slerp(Vector3.ZERO, 0.02)
		else:
			time_since_last_move = 0.0
