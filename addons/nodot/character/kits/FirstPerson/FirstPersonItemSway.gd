class_name FirstPersonItemSway extends Node

@export var first_person_item: FirstPersonItem

@export_category("Sway Settings")
@export var sway_amount = Vector3(0.2, 0.2, 0.2) # How much the weapon can sway
@export var sway_speed = 5.0 # How quickly the weapon sways back to center
@export var rotation_sensitivity = Vector2(0.2, 0.2) # Sensitivity of the sway based on head rotation

@export_category("Optional Overrides")
@export var ironsight: FirstPersonIronSight

var target_position = Vector3.ZERO # Target position for the sway effect
var target_rotation = Vector3.ZERO # Target rotation for the sway effect
var original_position: Vector3
var head: Node3D
var last_head_rotation: Vector3

func _ready():
	original_position = first_person_item.position

func _process(delta: float):
	if ironsight and ironsight.ironsight_target != Vector3.INF:
		return
		
	if head:
		_calculate_sway(head, delta)
		_apply_sway(delta)
		last_head_rotation = head.global_rotation_degrees
	else:
		head = first_person_item.get_parent().character.head

func _calculate_sway(head, delta):
	var head_rotation_delta = calculate_angle_delta(head.global_rotation_degrees, last_head_rotation)
	# Convert rotation delta to sway values, considering sensitivity
	var sway_delta = Vector3(-head_rotation_delta.y * rotation_sensitivity.x, head_rotation_delta.x * rotation_sensitivity.y, 0)
	target_position = original_position + sway_delta * sway_amount
	# Here, you can also calculate target_rotation if you want the item to tilt slightly during sway

func _apply_sway(delta):
	# Smoothly interpolate the item's position and rotation towards the target values
	first_person_item.position = first_person_item.position.lerp(target_position, sway_speed * delta)
	# If you implement target_rotation, you would also interpolate the rotation here

# Function to calculate the shortest distance between two angles, considering wraparound
func shortest_angle_distance(from_angle, to_angle):
	var difference = fmod(to_angle - from_angle, 360.0)
	return fmod(2.0 * difference, 360.0) - difference

# Function to calculate the shortest angle delta for each axis
func calculate_angle_delta(current_rotation, last_rotation):
	return Vector3(
		shortest_angle_distance(last_rotation.x, current_rotation.x),
		shortest_angle_distance(last_rotation.y, current_rotation.y),
		shortest_angle_distance(last_rotation.z, current_rotation.z)
	)
