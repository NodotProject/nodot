@tool
@icon("icons/nodot.svg")
## Generates a lightweight, non-interactive visual representation of a StaticBody3D or RigidBody3D
class_name PreviewBody3D extends Node3D

## The source body to create a preview from
@export var source_body: Node3D:
	set(new_value):
		source_body = new_value
		if source_body:
			_generate_preview()

## Collision shape mode for the preview
@export_enum("None", "Bounding Box", "Exact Shapes") var collision_mode: int = 0:
	set(new_value):
		collision_mode = new_value
		if source_body:
			_generate_preview()

@export_subgroup("Preview Material")
## Global transparency amount (0.0 = invisible, 1.0 = opaque)
@export_range(0.0, 1.0) var transparency: float = 0.5:
	set(new_value):
		transparency = new_value
		_update_preview_materials()

## Color tint for the preview
@export var color_tint: Color = Color.CYAN:
	set(new_value):
		color_tint = new_value
		_update_preview_materials()

## Enable wireframe display
@export var wireframe_mode: bool = false:
	set(new_value):
		wireframe_mode = new_value
		_update_preview_materials()

var preview_meshes: Array[MeshInstance3D] = []
var preview_materials: Array[StandardMaterial3D] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not source_body:
		warnings.append("A source body (StaticBody3D or RigidBody3D) must be assigned")
	elif not (source_body is StaticBody3D or source_body is RigidBody3D):
		warnings.append("The source body should be a StaticBody3D or RigidBody3D")
	return warnings


func _ready():
	# Defer the preview generation to ensure all nodes are ready
	call_deferred("_generate_preview_if_source_set")


func _generate_preview_if_source_set():
	if source_body:
		_generate_preview()


## Generates the preview from the source body
func _generate_preview():
	if not source_body:
		return

	# Clear existing preview
	_clear_preview()

	# Find all mesh instances in the source body
	var mesh_instances = _find_mesh_instances(source_body)

	# Create preview meshes
	for mesh_instance in mesh_instances:
		_create_preview_mesh(mesh_instance)

	# Handle collision shapes if requested
	if collision_mode != 0:
		_create_collision_shapes()

	# Update materials
	_update_preview_materials()


## Clears all existing preview nodes
func _clear_preview():
	for child in get_children():
		child.queue_free()
	preview_meshes.clear()
	preview_materials.clear()


## Recursively finds all MeshInstance3D nodes in the source
func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []

	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		# Recursively search children
		meshes.append_array(_find_mesh_instances(child))

	return meshes


## Creates a preview mesh instance from a source mesh
func _create_preview_mesh(source_mesh: MeshInstance3D):
	if not source_mesh.mesh:
		return

	var preview_mesh = MeshInstance3D.new()
	preview_mesh.mesh = source_mesh.mesh
	preview_mesh.transform = source_mesh.transform
	preview_mesh.name = source_mesh.name + "_Preview"

	# Create and assign preview material
	var preview_material = StandardMaterial3D.new()
	preview_materials.append(preview_material)
	preview_mesh.material_override = preview_material

	# Disable physics-related properties
	preview_mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	preview_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	add_child(preview_mesh)
	preview_meshes.append(preview_mesh)


## Creates collision shapes based on the collision mode
func _create_collision_shapes():
	if collision_mode == 1:  # Bounding Box
		_create_bounding_box_collision()
	elif collision_mode == 2:  # Exact Shapes
		_copy_exact_collision_shapes()


## Creates a single bounding box collision shape
func _create_bounding_box_collision():
	if preview_meshes.is_empty():
		return

	var combined_aabb = AABB()
	var first = true

	# Calculate combined AABB of all meshes
	for mesh_instance in preview_meshes:
		if mesh_instance.mesh:
			var mesh_aabb = mesh_instance.mesh.get_aabb()
			mesh_aabb = mesh_instance.transform * mesh_aabb

			if first:
				combined_aabb = mesh_aabb
				first = false
			else:
				combined_aabb = combined_aabb.merge(mesh_aabb)

	if not first:  # We have a valid AABB
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = combined_aabb.size
		collision_shape.shape = box_shape
		collision_shape.position = combined_aabb.get_center()
		collision_shape.name = "BoundingBoxCollision"
		add_child(collision_shape)


## Copies exact collision shapes from the source body
func _copy_exact_collision_shapes():
	var collision_shapes = _find_collision_shapes(source_body)

	for collision_shape in collision_shapes:
		var preview_collision = collision_shape.duplicate()
		preview_collision.name = collision_shape.name + "_Preview"
		add_child(preview_collision)


## Recursively finds all CollisionShape3D nodes in the source
func _find_collision_shapes(node: Node) -> Array[CollisionShape3D]:
	var shapes: Array[CollisionShape3D] = []

	for child in node.get_children():
		if child is CollisionShape3D:
			shapes.append(child)
		# Recursively search children
		shapes.append_array(_find_collision_shapes(child))

	return shapes


## Updates all preview materials with current settings
func _update_preview_materials():
	for material in preview_materials:
		_configure_preview_material(material)


## Configures a single preview material
func _configure_preview_material(material: StandardMaterial3D):
	if not material:
		return

	# Set base properties
	material.albedo_color = Color(color_tint.r, color_tint.g, color_tint.b, transparency)

	# Set transparency
	if transparency < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

	# Set wireframe mode
	if wireframe_mode:
		material.flags_transparent = true
		material.flags_unshaded = true
		material.wireframe = true
	else:
		material.wireframe = false
		material.flags_unshaded = false

	# Disable depth testing for better preview visibility
	material.no_depth_test = true
	material.flags_do_not_use_vertex_colors = true


## Updates the preview when source body changes
func set_source_body(new_source: Node3D):
	source_body = new_source
	if source_body:
		_generate_preview()


## Returns whether the preview is currently visible
func is_preview_visible() -> bool:
	return visible and not preview_meshes.is_empty()


## Shows the preview
func show_preview():
	visible = true


## Hides the preview
func hide_preview():
	visible = false
