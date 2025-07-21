## A camera for use with third person games
class_name ThirdPersonCamera extends Camera3D

## Distance from the camera to the character
@export var distance: float = 5.0:
	set(new_value):
		distance = clamp(new_value, distance_clamp.x, distance_clamp.y)
## The distance clamp for zooming
@export var distance_clamp := Vector2(5.0, 5.0)
## Move the camera to the initial position after some inactivity (0.0 to disable)
@export var time_to_reset: float = 2.0
## The speed at which the camera moves into position when the character is moving
@export var chase_speed: float = 2.0
## Collision excluded objects
@export var collision_ignored: Array[PhysicsBody3D] = []

var container: Node3D
var springarm: SpringArm3D
var target_node: Node3D
var time_since_last_move: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings

func _enter_tree() -> void:
	springarm = SpringArm3D.new()
	for node in collision_ignored:
		springarm.add_excluded_object(node.get_rid())
	springarm.transform = transform
	springarm.spring_length = distance
	target_node = Node3D.new()
	springarm.add_child(target_node)
	get_parent().add_child.call_deferred(springarm)
	
func _ready():
	container = get_parent()

func _process(delta: float) -> void:
	if !current: return
		
	if target_node:
		global_position = lerp(global_position, target_node.global_position, chase_speed * delta)
		quaternion = quaternion.slerp(target_node.quaternion, chase_speed * delta)
	
	if springarm:
		springarm.spring_length = lerp(springarm.spring_length, distance, chase_speed * delta)
	
	if time_to_reset > 0.0:
		if container.rotation != Vector3.ZERO:
			time_since_last_move += delta
			if time_since_last_move > time_to_reset:
				container.rotation = container.rotation.slerp(Vector3.ZERO, chase_speed * delta)
		else:
			time_since_last_move = 0.0
