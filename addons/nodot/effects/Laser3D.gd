@tool
## A raycast that also produces a laser beam
class_name Laser3D extends RayCast3D

@export var laser_color: Color = Color.RED
@export var thickness: float = 0.02
@export var mesh_rotation: Vector3 = Vector3.ZERO: set = _mesh_rotation_set

var laser_mesh_instance = MeshInstance3D.new()
var previous_target_position = target_position

func _enter_tree() -> void:
	var laser_mesh = CylinderMesh.new()
	laser_mesh_instance.mesh = laser_mesh
	add_child(laser_mesh_instance)
	realign_laser_mesh()

func _physics_process(delta):
	if previous_target_position != target_position:
		previous_target_position = target_position
		realign_laser_mesh()
	

func _mesh_rotation_set(new_rotation: Vector3) -> void:
	mesh_rotation = new_rotation
	realign_laser_mesh()

func realign_laser_mesh():
	laser_mesh_instance.mesh.top_radius = thickness
	laser_mesh_instance.mesh.bottom_radius = thickness
	laser_mesh_instance.mesh.height = Vector3.ZERO.distance_to(target_position)
	## TODO: Figure out the correct math for this
	laser_mesh_instance.rotation = (Vector3.ZERO.direction_to(target_position) * PI / 2)
	laser_mesh_instance.position = target_position * 0.5;
	
