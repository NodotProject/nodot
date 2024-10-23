class_name MeshShatter extends Nodot3D

@export var autoslice: bool = true
@export var auto_add_to_tree: bool = false
@export var mesh: MeshInstance3D
@export var body: RigidBody3D
@export var cross_section_material: StandardMaterial3D
@export var slice_count: int = 3
@export var add_colliders: bool = true

var slicer := MeshSlicer.new()
var marker := Marker3D.new()
var pieces: Array[MeshInstance3D] = []
var mesh_backup: MeshInstance3D
var body_backup: RigidBody3D
var active_bodies: Array[RigidBody3D] = []

func _ready():
	if autoslice:
		action()

func add_to_tree():
	for i in pieces.size():
		var new_body = body_backup.duplicate(15)
		var piece = pieces[i]
		var collider = create_collider(piece)
		new_body.position = piece.position
		piece.position = Vector3.ZERO
		new_body.add_child(piece)
		new_body.add_child(collider)
		add_child(new_body)
		active_bodies.append(new_body)
	
	if is_instance_valid(mesh):
		mesh.visible = false
	
func create_collider(piece: MeshInstance3D) -> CollisionShape3D:
	if !add_colliders: return
	var collision_shape = CollisionShape3D.new()
	var convex_shape = piece.mesh.create_convex_shape()
	collision_shape.shape = convex_shape
	collision_shape.scale *= 0.8;
	return collision_shape

func action():
	mesh_backup = mesh.duplicate(15)
	if body:
		body_backup = body.duplicate(15)
		
	pieces = [mesh_backup]
	for i in slice_count:
		var new_pieces: Array[MeshInstance3D] = []
		for piece in pieces:
			var new_slices: Array = slice(piece)
			for new_slice in new_slices:
				if new_slice.get_surface_count() == 0 or new_slice.surface_get_array_len(0) <= -1: continue
				var new_piece = array_mesh_to_instance(new_slice)
				new_pieces.append(new_piece)
		pieces = new_pieces
	recenter_meshes()
	if auto_add_to_tree:
		add_to_tree()
	return pieces

func array_mesh_to_instance(slice_data: ArrayMesh):
	var new_mesh = mesh_backup.duplicate(15)
	new_mesh.mesh = slice_data
	return new_mesh
	
func recenter_meshes():
	for piece in pieces:
		var center = piece.mesh.get_aabb().get_center()
		piece.position += center
		var final_array_mesh = ArrayMesh.new()
		for i in piece.mesh.get_surface_count():
			var array_mesh = ArrayMesh.new()
			array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, piece.mesh.surface_get_arrays(i))
			var mdt = MeshDataTool.new()
			mdt.create_from_surface(array_mesh, 0)
			for j in range(mdt.get_vertex_count()):
				var vertex = mdt.get_vertex(j)
				vertex -= center
				mdt.set_vertex(j, vertex)
			array_mesh.clear_surfaces()
			mdt.commit_to_surface(array_mesh)
			final_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array_mesh.surface_get_arrays(0))
		piece.mesh = final_array_mesh


func slice(target_mesh: MeshInstance3D) -> Array:
	marker.position = get_random_position_within_mesh(target_mesh)
	marker.rotation = get_random_euler_rotation()
	var transform = marker.transform
	transform.basis.x = transform.basis.x + target_mesh.position
	transform.basis.y = transform.basis.y + target_mesh.position
	transform.basis.z = transform.basis.z + target_mesh.position
	return slicer.slice_mesh(transform, target_mesh.mesh, cross_section_material)

# Function to get a random position within a mesh
func get_random_position_within_mesh(mesh_instance):
	# For simplicity, using the first surface
	var arrays = mesh_instance.mesh.surface_get_arrays(0)
	if !arrays:
		return Vector3.ZERO
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var indices = arrays[Mesh.ARRAY_INDEX]
	if !indices:
		return Vector3.ZERO

	# Choose a random triangle from the mesh
	var triangle_count = indices.size() / 3
	var random_triangle_index = randi() % triangle_count
	var index_offset = random_triangle_index * 3

	# Get the vertices of the random triangle
	var vertex_a = vertices[indices[index_offset]]
	var vertex_b = vertices[indices[index_offset + 1]]
	var vertex_c = vertices[indices[index_offset + 2]]

	# Get a random point within the triangle
	return get_random_point_in_triangle(vertex_a, vertex_b, vertex_c)

# Function to get a random point within a triangle
func get_random_point_in_triangle(a, b, c):
	# Barycentric coordinates method
	var r1 = randf()
	var r2 = randf()

	if r1 + r2 > 1:
		r1 = 1 - r1
		r2 = 1 - r2

	var p = a + r1 * (b - a) + r2 * (c - a)
	return p
	
func get_random_euler_rotation():
	var x_rot = randf_range(-PI, PI)  # Random rotation around X-axis
	var y_rot = randf_range(-PI, PI)  # Random rotation around Y-axis
	var z_rot = randf_range(-PI, PI)  # Random rotation around Z-axis

	return Vector3(x_rot, y_rot, z_rot)

func reset():
	mesh.visible = true
	for active_body in active_bodies:
		active_body.queue_free()
	active_bodies = []
	pieces = []
	if autoslice:
		action()
	
