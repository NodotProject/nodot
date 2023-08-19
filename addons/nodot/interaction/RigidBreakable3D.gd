@tool
## A RigidBody3D that will be replaced by it's selected children on death
class_name RigidBreakable3D extends NodotRigidBody3D

## Triggered when the object is broken
signal broken

## (optional) A node to replace the breakable with that contains all the smaller parts
@export var replacement_node: Node3D
## A value to propel pieces away from the center when the object is broken
@export var explosion_force: float = 1.0
## Environmental damage (i.e fall damage) (lower is more fragile) (0.0 for no environmental damage)
@export var environmental_damage: float = 0.0
## How much damage to deal based on the velocity (higher is more)
@export var environmental_damage_multiplier: float = 1.0

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

	if environmental_damage > 0.0:
		contact_monitor = true
		if max_contacts_reported == 0:
			max_contacts_reported = 1


func _physics_process(delta: float) -> void:
	if environmental_damage > 0 and contact_monitor and get_contact_count() > 0:
		var total_velocity: float = (
			abs(linear_velocity.x) + abs(linear_velocity.y) + abs(linear_velocity.z)
		)
		if total_velocity > environmental_damage:
			var multiplier = total_velocity / environmental_damage
			var damage = environmental_damage_multiplier * (environmental_damage * multiplier)
			health.add_health(-damage)


## Perform the break
func action() -> void:
	if replacement_node:
		parent.add_child(replacement_node)
		replacement_node.visible = true
		replacement_node.position = position
		replacement_node.rotation = rotation
		propel_outwards()
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


## Apply outward force to children from the centre
func propel_outwards() -> void:
	if explosion_force > 0.0:
		for child in replacement_node.get_children():
			if child is RigidBody3D or child is StaticBody3D:
				child.apply_central_impulse(
					Vector3.ZERO.direction_to(child.position) * explosion_force
				)


## Used to save data from impact events
func save_impulse(
	impulse_direction: Vector3, impulse_position: Vector3, origin_position: Vector3
) -> void:
	saved_impulse_direction = impulse_direction
	saved_impulse_position = impulse_position
	apply_impulse(impulse_direction, impulse_position - origin_position)

## Used to apply damage to itself
func add_health(amount: float) -> void:
	health.add_health(amount)
