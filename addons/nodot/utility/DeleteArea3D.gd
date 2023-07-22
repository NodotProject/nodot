## Deletes RigidBodies and StaticBodies within the area
class_name DeleteArea3D extends Area3D

## Enable the functionality of the delete node
@export var enabled: bool = true
## Allow deleting of static bodies
@export var delete_static_bodies: bool = false
## Allow deleting of rigid bodies
@export var delete_rigid_bodies: bool = true
## Delete on contact
@export var automatic: bool = true
## The time in seconds between contact or action and the actual deletion
@export var delay: float = 0.0

## Triggered when a body is deleted
signal deleted(global_position: Vector3)

func _enter_tree() -> void:
	if !enabled or !automatic:
		return
		
	connect("body_entered", delete)


## Delete all overlapping bodies
func action():
	if !enabled: return
	
	var colliders = get_overlapping_bodies()
	for collider in colliders:
		delete(collider)

## Delete an overlapping body
func delete(body: Node3D) -> void:
	if !enabled: return
	
	if delay > 0:
		await get_tree().create_timer(delay, false).timeout
		
	var is_allowed = false
	if delete_static_bodies and body is StaticBody3D:
		is_allowed = true
	if delete_rigid_bodies and body is RigidBody3D:
		is_allowed = true
	
	if !is_allowed: return
	
	var last_position = body.global_position
	body.queue_free()
	emit_signal("deleted", last_position)
			
