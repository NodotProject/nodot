@tool
@icon("../icons/laser.svg")
## A raycast that also produces a laser beam
class_name Laser3D extends RayCast3D

## The color of the laser
@export var laser_color: Color = Color.RED: set = set_laser_color
## The intensity of the laser emission
@export var laser_intensity: float = 1.5: set = set_laser_intensity
## The thickness of the laser (and raycast)
@export_range(1, 5, 1) var thickness: int = 2: set = set_laser_thickness

signal body_entered(body: Node3D)
signal all_bodies_exited

var laser_mesh_instance = MeshInstance3D.new()
var previous_target_position = target_position
var active_collider: Node3D

func _enter_tree() -> void:
	var laser_mesh = CylinderMesh.new()
	laser_mesh_instance.cast_shadow = false
	laser_mesh_instance.transparency = 0.2
	laser_mesh_instance.mesh = laser_mesh
	var laser_material = StandardMaterial3D.new()
	laser_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	laser_material.albedo_color = laser_color
	laser_material.emission_enabled = true
	laser_material.emission = laser_color
	laser_material.emission_energy_multiplier = laser_intensity
	laser_material.rim_enabled = true
	laser_material.rim = 0.3
	laser_material.disable_receive_shadows = true
	laser_mesh_instance.mesh.surface_set_material(0, laser_material)
	add_child(laser_mesh_instance)
	_realign_laser_mesh()

func _physics_process(delta) -> void:
	# Realign if the target_position changes
	if previous_target_position != target_position:
		previous_target_position = target_position
		_realign_laser_mesh()
		
	if is_colliding():
		var collision_point = get_collision_point()
		var collision_point_distance: float = global_position.distance_to(collision_point)
		var target_position_distance: float = Vector3.ZERO.distance_to(target_position)
		laser_mesh_instance.position = target_position * (collision_point_distance / target_position_distance) * 0.5
		laser_mesh_instance.mesh.height = collision_point_distance
		var collider = get_collider()
		if collider != active_collider:
			active_collider = collider
			emit_signal("body_entered", active_collider)
	else:
		laser_mesh_instance.position = target_position * 0.5
		laser_mesh_instance.mesh.height = Vector3.ZERO.distance_to(target_position)
		if active_collider:
			active_collider = null
			emit_signal("all_bodies_exited")

func _realign_laser_mesh() -> void:
	laser_mesh_instance.mesh.top_radius = (1.0 / 100.0) * float(thickness)
	laser_mesh_instance.mesh.bottom_radius = (1.0 / 100.0) * float(thickness)
	laser_mesh_instance.mesh.height = Vector3.ZERO.distance_to(target_position)
	var newtransform: Transform3D = laser_mesh_instance.transform.looking_at(target_position, Vector3.UP).rotated_local(Vector3.LEFT, deg_to_rad(90))
	laser_mesh_instance.transform = newtransform
	laser_mesh_instance.position = target_position * 0.5;

## Sets the laser thickness value
func set_laser_thickness(new_thickness: int) -> void:
	thickness = new_thickness
	if !laser_mesh_instance.mesh:
		return
		
	laser_mesh_instance.mesh.top_radius = (1.0 / 100.0) * float(thickness)
	laser_mesh_instance.mesh.bottom_radius = (1.0 / 100.0) * float(thickness)
	debug_shape_thickness = thickness

## Sets the laser color
func set_laser_color(new_color: Color) -> void:
	laser_color = new_color
	if !laser_mesh_instance.mesh:
		return
		
	var laser_material = laser_mesh_instance.get_active_material(0)
	laser_material.albedo_color = laser_color
	laser_material.emission = laser_color

## Sets the laser emission intensity
func set_laser_intensity(new_intensity: float) -> void:
	laser_intensity = new_intensity
	if !laser_mesh_instance.mesh:
		return
		
	var laser_material = laser_mesh_instance.get_active_material(0)
	laser_material.emission_energy_multiplier = laser_intensity
	
