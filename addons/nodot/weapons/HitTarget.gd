class_name HitTarget

@export var distance: int = 0
@export var collision_point: Vector3 = Vector3.ZERO
@export var collision_normal: Vector3 = Vector3.ZERO
var target_node: Variant


func _init(
	input_distance: int,
	input_collision_point: Vector3,
	input_collision_normal: Vector3,
	input_target_node: Variant
) -> void:
	distance = input_distance
	collision_point = input_collision_point
	collision_normal = input_collision_normal
	target_node = input_target_node
