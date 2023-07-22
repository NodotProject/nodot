## A node that explodes causing damage
class_name Explosion3D extends Nodot3D

## How long to play the effect
@export var effect_time: float = 1.0
## Range to apply force
@export var force_range: float = 10.0
## Maximum force to apply
@export var max_force: float = 3.0
## Range to apply damage
@export var damage_range: float = 5.0
## Maximum damage to receive (closer to the center = higher damage)
@export var max_damage: float = 100.0
## Minimum damage to receive
@export var min_damage: float = 0.0
## Heals instead of damages
@export var healing: bool = false

var damage_area: Area3D
var force_area: Area3D


func _enter_tree() -> void:
	damage_area = Area3D.new()
	var damage_collider: CollisionShape3D = CollisionShape3D.new()
	damage_area.add_child(damage_collider)

	var damage_shape: SphereShape3D = SphereShape3D.new()
	damage_collider.shape = damage_shape
	damage_shape.radius = damage_range / 2
	add_child(damage_area)

	force_area = Area3D.new()
	var force_collider: CollisionShape3D = CollisionShape3D.new()
	force_area.add_child(force_collider)

	var force_shape: SphereShape3D = SphereShape3D.new()
	force_collider.shape = force_shape
	force_shape.radius = force_range / 2
	add_child(force_area)


func _ready() -> void:
	if effect_time <= 0: return
	await get_tree().create_timer(effect_time, false).timeout
	queue_free()


func action() -> void:
	# Required because action can be called too early
	await get_tree().physics_frame

	if force_range > 0.0:
		var force_colliders: Array[Node3D] = force_area.get_overlapping_bodies()
		for collider in force_colliders:
			var distance: float = global_position.distance_to(collider.global_position)
			var direction: Vector3 = global_position.direction_to(collider.global_position)
			var distance_percent: float = 100 / distance * force_range
			var final_force: float = (force_range / 100) * distance_percent
			if collider is RigidBody3D:
				collider.apply_impulse(
					direction * final_force, collider.global_position - global_position
				)
			if collider is StaticBreakable3D or collider is RigidBreakable3D:
				collider.save_impulse(
					direction * final_force, collider.global_position, global_position
				)

	if max_damage > 0.0:
		var damage_colliders: Array[Node3D] = damage_area.get_overlapping_bodies()
		for collider in damage_colliders:
			var collider_healths: Array[Node] = collider.find_children("*", "Health")
			if collider_healths.size() > 0:
				var distance: float = global_position.distance_to(collider.global_position)
				var damage_offset: float = max_damage - min_damage
				# TODO: The math is wrong here
				var distance_percent: float = 100 - (100 / damage_range * distance)
				var final_damage: float = min_damage + ((damage_offset / 100) * distance_percent)
				var collider_health: Health = collider_healths[0]
				if !healing:
					final_damage = -final_damage
				collider_health.add_health(final_damage)
