@tool
class_name GridMultiMeshInstance3D extends MultiMeshInstance3D

@export var source_mesh: MeshInstance3D: set = _set_source_mesh
@export var rows: int = 10: set = _set_rows
@export var columns: int = 10: set = _set_columns
@export var depth: int = 1: set = _set_depth
@export var spacing: float = 0.1: set = _set_spacing
@export var mesh_scale: float = 1.0: set = _set_mesh_scale

func _init():
	multimesh = MultiMesh.new()
	
	# Assuming each mesh is a 3D Vector (x, y, z)
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	 
	recalculate_transforms()

func _set_source_mesh(new_value: MeshInstance3D):
	source_mesh = new_value
	multimesh.mesh = source_mesh.mesh

func _set_rows(new_value: int):
	rows = new_value
	calculate_instances()
	recalculate_transforms()
	
func _set_columns(new_value: int):
	columns = new_value
	calculate_instances()
	recalculate_transforms()

func _set_depth(new_value: int):
	depth = new_value
	calculate_instances()
	recalculate_transforms()

func _set_spacing(new_value: float):
	spacing = new_value
	recalculate_transforms()
	
func _set_mesh_scale(new_value: float):
	mesh_scale = new_value
	recalculate_transforms()

func calculate_instances():
	multimesh.instance_count = rows * columns * depth

func recalculate_transforms():
	# Create a PackedFloat32Array for positions
	var transforms := PackedFloat32Array()

	var offset_x = -(columns - 1) * spacing / 2
	var offset_y = -(depth - 1) * spacing / 2  # Offset for depth
	var offset_z = -(rows - 1) * spacing / 2

	# Calculate positions and add them to the array
	for depth_level in range(depth):
		for row in range(rows):
			for column in range(columns):
				var x: float = column * spacing + offset_x
				var y: float = depth_level * spacing + offset_y  # Position along the y-axis
				var z: float = row * spacing + offset_z

				# Manually construct the array for the transform
				var transform_array: Array[float] = [
					mesh_scale, 0.0, 0.0, x,  # First column with scaling and x translation
					0.0, mesh_scale, 0.0, y,  # Second column with scaling and y translation
					0.0, 0.0, mesh_scale, z   # Third column with scaling and z translation
				]

				transforms.append_array(transform_array)

	# Assign the transforms to the multimesh
	multimesh.buffer = transforms

