## A node that can propel itself
class_name Projectile3D extends RigidBody3D

## The speed of the projectile
@export var speed: float = 50.0
## Applies the speed consistently
@export var self_propelling: bool = true
## Destroys the projectile after this timespan (0.0 for never)
@export var lifespan: float = 0.0
## Destroys the projectile on impact
@export var destroy_on_impact: bool = false

signal collision(position: Vector3, rotation: Vector3, colliders: Array[Node3D])
signal destroyed(position: Vector3, rotation: Vector3)

var is_editor: bool = Engine.is_editor_hint()
var explosion: Explosion3D


func _enter_tree() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	if is_editor: return
	explosion = Nodot.get_first_child_of_type(self, Explosion3D)
	if explosion:
		remove_child(explosion)


func _ready() -> void:
	if lifespan <= 0.0: return
	await get_tree().create_timer(lifespan, false).timeout
	destroy()


func _physics_process(delta: float) -> void:
	var force = get_propulsion_force()

	if self_propelling:
		apply_central_force(force)

	if destroy_on_impact and get_contact_count() > 0:
		emit_signal("collision", position, rotation, get_colliding_bodies())
		destroy()


func propel() -> void:
	if self_propelling: return
	apply_central_force(get_propulsion_force())


func get_propulsion_force() -> Vector3:
	# Get the angle between the rocket's current direction and the desired direction.
	var angle: float = global_rotation.dot(global_transform.basis[2])

	# Calculate the vector3 of the desired thrust.
	var force: Vector3 = speed * global_transform.basis[2] * cos(angle)

	return -force


func destroy() -> void:
	if !is_instance_valid(self): return
	emit_signal("destroyed", position, rotation)
	if explosion:
		get_tree().root.add_child(explosion)
		explosion.global_position = global_position
		explosion.action()
	queue_free()
