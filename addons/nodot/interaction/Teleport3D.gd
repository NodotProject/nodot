## Teleports RigidBodies and CharacterBodies to a destination position or node
class_name Teleport3D extends Area3D

## Enable the functionality of the teleporter
@export var enabled: bool = true
## Teleported bodies will be teleported to the target nodes global_position
@export var target_node: Node3D
## If no target_node is present, it will use target_position
@export var target_position: Vector3 = Vector3.ZERO
## Use global position instead of position
@export var global_positioning: bool = true
## Allow teleporting of character bodies
@export var teleport_character_bodies: bool = true
## Allow teleporting of rigid bodies
@export var teleport_rigid_bodies: bool = false
## Teleport on contact
@export var automatic: bool = true
## The time in seconds between contact or action and the actual teleportation
@export var delay: float = 0.0

## Triggered when a body is teleported
signal teleported(body: Node3D, position: Vector3)

func _enter_tree() -> void:
	if !enabled or !automatic:
		return
		
	connect("body_entered", teleport)


## Teleport all overlapping bodies to the target
func action():
	if !enabled: return
	
	var colliders = get_overlapping_bodies()
	for collider in colliders:
		teleport(collider)

## Teleport an overlapping body to the target
func teleport(body: Node3D) -> void:
	if !enabled: return
	
	if delay > 0:
		await get_tree().create_timer(delay, false).timeout
		
	var is_allowed = false
	if teleport_character_bodies and body is CharacterBody3D:
		is_allowed = true
	if teleport_rigid_bodies and body is RigidBody3D:
		is_allowed = true
	
	if !is_allowed: return
	
	if global_positioning:
		if target_node:
			body.global_position = target_node.global_position
		else:
			body.global_position = target_position
		emit_signal("teleported", body, body.global_position)
	else:
		if target_node:
			body.position = target_node.position
		else:
			body.position = target_position
		emit_signal("teleported", body, body.position)
			
