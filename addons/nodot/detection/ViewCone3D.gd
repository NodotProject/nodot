@tool
## A cone shaped ShapeCast3D
class_name ViewCone3D extends ShapeCast3D

## The radius of the viewcone
@export var radius: float = 10.0: set = _radius_set
## The distance of sight
@export var distance: float = 100.0: set = _distance_set
## Triggered by RigidBodies
@export var triggered_by_rigidbodies: bool = false
## Triggered by CharacterBodies
@export var triggered_by_character_bodies: bool = true

## A body has entered the viewcone
signal body_entered(body: Node3D)
## A body has exited the viewcone
signal body_exited(body: Node3D)

var colliding_bodies: Array[Node3D] = []

func _enter_tree() -> void:
	_rebuild_cone()

# TODO: Should use a raycast to detect the viewcone actually has line of sight
func _physics_process(_delta):
	if is_colliding():
		var collision_count = get_collision_count()
		var current_colliders := []
		for i in collision_count:
			var collider = get_collider(i)
			if (triggered_by_rigidbodies and collider is RigidBody3D) or (triggered_by_character_bodies and collider is CharacterBody3D):
			
				current_colliders.append(collider)

				if !colliding_bodies.has(collider):
					colliding_bodies.append(collider)
					emit_signal("body_entered", collider)

		var new_colliding_bodies = colliding_bodies
		for i in colliding_bodies.size():
			if i <= colliding_bodies.size() - 1:
				var collider = colliding_bodies[i]
				if !current_colliders.has(collider):
					emit_signal("body_exited", collider)
					new_colliding_bodies.remove_at(i)
		colliding_bodies = new_colliding_bodies

func _radius_set(new_value: float):
	radius = new_value
	_rebuild_cone()

func _distance_set(new_value: float):
	distance = new_value
	_rebuild_cone()

func _rebuild_cone():
	shape = ConvexPolygonShape3D.new()
	var vertices: Array[Vector3] = [Vector3.ZERO]

	# Generate the vertices of the cone.
	for i in range(0, 240):
		var angle = i * PI / 7.5
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		var z = distance
		vertices.append(Vector3(x, y, z))

	shape.points = vertices
