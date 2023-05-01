@tool
## A cone shaped ShapeCast3D
class_name ViewCone3D extends ShapeCast3D

## The radius of the viewcone
@export var radius: float = 10.0
## The distance of sight
@export var distance: float = 100.0

## A body has entered the viewcone
signal body_entered(body: Node3D)
## A body has exited the viewcone
signal body_exited(body: Node3D)

var colliding_bodies: Array[Node3D] = []


func _enter_tree():
	target_position = Vector3.ZERO
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


func _physics_process(_delta):
	if is_colliding():
		var collision_count = get_collision_count()
		var current_colliders := []
		for i in collision_count:
			var collider = get_collider(i)
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
