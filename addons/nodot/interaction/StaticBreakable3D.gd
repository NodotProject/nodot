@tool
## A StaticBody3D that will be replaced by it's selected children on death
class_name StaticBreakable3D extends StaticBody3D

## Triggered when the object is broken
signal broken

## (optional) A node to replace the breakable with that contains all the smaller parts
@export var replacement_node: Node3D

@onready var parent = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var health: Health
var saved_impulse_direction: Vector3
var saved_impulse_position: Vector3


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if !Nodot.get_first_child_of_type(self, Health):
		warnings.append("Should have a Health node as a child")

	return warnings


func _enter_tree() -> void:
	if !is_editor and replacement_node:
		remove_child(replacement_node)

	for child in get_children():
		if child is Health:
			health = child
			health.connect("health_depleted", action)


## Perform the break
func action() -> void:
	if replacement_node:
		parent.add_child(replacement_node)
		replacement_node.visible = true
		replacement_node.position = position
		var closest_child = find_closest_child()
		if closest_child:
			closest_child.apply_impulse(
				saved_impulse_direction, saved_impulse_position - closest_child.global_position
			)
	emit_signal("broken")
	queue_free()


## Find the closest child to the saved_impulse_position (hit position)
func find_closest_child():
	if saved_impulse_position:
		var closest_child: Node3D = replacement_node.get_child(0)
		for child in replacement_node.get_children():
			if (
				child.global_position.distance_to(saved_impulse_position)
				< closest_child.global_position.distance_to(saved_impulse_position)
			):
				closest_child = child
		return closest_child


## Used to save data from impact events
func save_impulse(
	impulse_direction: Vector3, impulse_position: Vector3, _origin_position: Vector3
) -> void:
	saved_impulse_direction = impulse_direction
	saved_impulse_position = impulse_position

## Used to apply damage to itself
func add_health(amount: float) -> void:
	health.add_health(amount)
