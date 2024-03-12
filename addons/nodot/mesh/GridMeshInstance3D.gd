@tool
class_name GridMeshInstance3D extends MultiMeshInstance3D

@export var target_mesh: MeshInstance3D: set = _set_target_mesh
@export var source_mesh: MeshInstance3D: set = _set_source_mesh
@export var rows: int = 10: set = _set_rows
@export var columns: int = 10: set = _set_columns
@export var spacing: float = 0.1: set = _set_spacing
@export var mesh_scale: float = 1.0: set = _set_mesh_scale

func _init():
	multimesh = MultiMesh.new()
	
	# Assuming each mesh is a 3D Vector (x, y, z)
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	
	recalculate_transforms()

func _set_target_mesh(new_value: MeshInstance3D):
	target_mesh = new_value
	recalculate_transforms()

func _set_source_mesh(new_value: MeshInstance3D):
	source_mesh = new_value
	multimesh.mesh = source_mesh.mesh

func _set_rows(new_value: int):
	rows = new_value
	multimesh.instance_count = rows * columns
	recalculate_transforms()
	
func _set_columns(new_value: int):
	columns = new_value
	multimesh.instance_count = rows * columns
	recalculate_transforms()
	
func _set_spacing(new_value: float):
	spacing = new_value
	recalculate_transforms()
	
func _set_mesh_scale(new_value: float):
	mesh_scale = new_value
	recalculate_transforms()
	
func recalculate_transforms():
	# Create a PackedFloat32Array for positions
	var transforms := PackedFloat32Array()
	
	var arrays = []
	var vertices: PackedVector3Array = []
	
	if target_mesh and target_mesh.mesh:
		arrays = target_mesh.mesh.surface_get_arrays(0)
		vertices = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	
	var offset_x = -(columns - 1) * spacing / 2
	var offset_z = -(rows - 1) * spacing / 2
	
	# Calculate positions and add them to the array
	for row in range(rows):
		for column in range(columns):
			var x: float = column * spacing + offset_x
			var z: float = row * spacing + offset_z
			var y: float = 0.0
			if target_mesh and target_mesh.mesh:
				y = get_height_at_position(x, z, vertices)
			
			# Create a Transform with scaling and translation
			var transform: Transform3D = Transform3D(Basis().scaled(Vector3(mesh_scale, mesh_scale, mesh_scale)), Vector3(x, 0, z))

			# Manually construct the array for the transform
			var transform_array: Array[float] = [
				mesh_scale, 0.0, 0.0, x,  # First column with scaling and x translation
				0.0, mesh_scale, 0.0, y,  # Second column with scaling and y translation (0 since we're not moving up)
				0.0, 0.0, mesh_scale, z  # Third column with scaling and z translation
			]

			transforms.append_array(transform_array)

	# Assign the transforms to the multimesh
	multimesh.buffer = transforms

func get_height_at_position(x, z, vertices) -> float:
	# Simplest approach: find the closest vertex and use its Y
	# More complex methods could involve interpolating between vertices
	var closest_distance = INF
	var height = 0.0
	for vertex in vertices:
		var distance = Vector2(x - vertex.x, z - vertex.z).length()
		if distance < closest_distance:
			closest_distance = distance
			height = vertex.y
	return height
