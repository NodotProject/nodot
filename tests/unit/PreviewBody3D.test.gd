extends VestTest

var preview_body: PreviewBody3D
var source_static_body: StaticBody3D
var source_rigid_body: RigidBody3D
var test_mesh: MeshInstance3D
var test_collision: CollisionShape3D

func before_case(_case):
	# Create test objects
	preview_body = PreviewBody3D.new()
	source_static_body = StaticBody3D.new()
	source_rigid_body = RigidBody3D.new()
	
	# Create a test mesh with a box mesh
	test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_mesh.name = "TestMesh"
	
	# Create a test collision shape
	test_collision = CollisionShape3D.new()
	test_collision.shape = BoxShape3D.new()
	test_collision.name = "TestCollision"
	
	# Add mesh and collision to source bodies
	source_static_body.add_child(test_mesh)
	source_static_body.add_child(test_collision)
	
	var mesh_copy = test_mesh.duplicate()
	var collision_copy = test_collision.duplicate()
	source_rigid_body.add_child(mesh_copy)
	source_rigid_body.add_child(collision_copy)

func after_case(_case):
	if preview_body:
		preview_body.queue_free()
	if source_static_body:
		source_static_body.queue_free()
	if source_rigid_body:
		source_rigid_body.queue_free()

func test_configuration_warnings():
	# Test warning when no source body is set
	var warnings = preview_body._get_configuration_warnings()
	expect_true(warnings.size() > 0, "Should have warnings when no source body is set")
	expect_true(warnings[0].contains("source body"), "Warning should mention source body")
	
	# Test no warnings when valid source is set
	preview_body.source_body = source_static_body
	warnings = preview_body._get_configuration_warnings()
	expect_equal(warnings.size(), 0, "Should have no warnings with valid source body")

func test_set_source_body_static():
	preview_body.source_body = source_static_body
	
	expect_equal(preview_body.source_body, source_static_body, "Should set source body correctly")
	expect_true(preview_body.get_child_count() > 0, "Should generate preview children")

func test_set_source_body_rigid():
	preview_body.source_body = source_rigid_body
	
	expect_equal(preview_body.source_body, source_rigid_body, "Should set source body correctly")
	expect_true(preview_body.get_child_count() > 0, "Should generate preview children")

func test_mesh_generation():
	preview_body.source_body = source_static_body
	
	# Should create preview meshes
	var preview_meshes = []
	for child in preview_body.get_children():
		if child is MeshInstance3D:
			preview_meshes.append(child)
	
	expect_true(preview_meshes.size() > 0, "Should create at least one preview mesh")
	expect_not_null(preview_meshes[0].mesh, "Preview mesh should have mesh data")
	expect_not_null(preview_meshes[0].material_override, "Preview mesh should have material override")

func test_collision_mode_none():
	preview_body.collision_mode = 0  # None
	preview_body.source_body = source_static_body
	
	var collision_shapes = []
	for child in preview_body.get_children():
		if child is CollisionShape3D:
			collision_shapes.append(child)
	
	expect_equal(collision_shapes.size(), 0, "Should not create collision shapes in None mode")

func test_collision_mode_bounding_box():
	preview_body.collision_mode = 1  # Bounding Box
	preview_body.source_body = source_static_body
	
	var collision_shapes = []
	for child in preview_body.get_children():
		if child is CollisionShape3D:
			collision_shapes.append(child)
	
	expect_true(collision_shapes.size() > 0, "Should create bounding box collision shape")
	expect_true(collision_shapes[0].shape is BoxShape3D, "Should create box shape for bounding box")

func test_collision_mode_exact():
	preview_body.collision_mode = 2  # Exact Shapes
	preview_body.source_body = source_static_body
	
	var collision_shapes = []
	for child in preview_body.get_children():
		if child is CollisionShape3D:
			collision_shapes.append(child)
	
	expect_true(collision_shapes.size() > 0, "Should create exact collision shapes")

func test_transparency_setting():
	preview_body.source_body = source_static_body
	preview_body.transparency = 0.3
	
	var preview_mesh = null
	for child in preview_body.get_children():
		if child is MeshInstance3D:
			preview_mesh = child
			break
	
	expect_not_null(preview_mesh, "Should have a preview mesh")
	expect_not_null(preview_mesh.material_override, "Should have material override")
	expect_equal(preview_mesh.material_override.albedo_color.a, 0.3, "Should set transparency correctly")

func test_color_tint_setting():
	preview_body.source_body = source_static_body
	preview_body.color_tint = Color.RED
	
	var preview_mesh = null
	for child in preview_body.get_children():
		if child is MeshInstance3D:
			preview_mesh = child
			break
	
	expect_not_null(preview_mesh, "Should have a preview mesh")
	expect_not_null(preview_mesh.material_override, "Should have material override")
	var material_color = preview_mesh.material_override.albedo_color
	expect_approximately_equal(material_color.r, Color.RED.r, 0.01, "Should set red component correctly")
	expect_approximately_equal(material_color.g, Color.RED.g, 0.01, "Should set green component correctly")
	expect_approximately_equal(material_color.b, Color.RED.b, 0.01, "Should set blue component correctly")

func test_wireframe_mode():
	preview_body.source_body = source_static_body
	preview_body.wireframe_mode = true
	
	var preview_mesh = null
	for child in preview_body.get_children():
		if child is MeshInstance3D:
			preview_mesh = child
			break
	
	expect_not_null(preview_mesh, "Should have a preview mesh")
	expect_not_null(preview_mesh.material_override, "Should have material override")
	expect_true(preview_mesh.material_override.wireframe, "Should enable wireframe mode")

func test_clear_preview():
	preview_body.source_body = source_static_body
	expect_true(preview_body.get_child_count() > 0, "Should have children after setting source")
	
	preview_body._clear_preview()
	expect_equal(preview_body.get_child_count(), 0, "Should clear all children")

func test_visibility_methods():
	preview_body.source_body = source_static_body
	
	preview_body.show_preview()
	expect_true(preview_body.visible, "Should be visible after show_preview")
	expect_true(preview_body.is_preview_visible(), "is_preview_visible should return true")
	
	preview_body.hide_preview()
	expect_false(preview_body.visible, "Should be hidden after hide_preview")
	expect_false(preview_body.is_preview_visible(), "is_preview_visible should return false")

func test_find_mesh_instances():
	# Create nested structure
	var parent = Node3D.new()
	var child_mesh = MeshInstance3D.new()
	child_mesh.mesh = SphereMesh.new()
	parent.add_child(child_mesh)
	source_static_body.add_child(parent)
	
	var found_meshes = preview_body._find_mesh_instances(source_static_body)
	expect_true(found_meshes.size() >= 2, "Should find meshes including nested ones")
	
	parent.queue_free()

func test_find_collision_shapes():
	# Create nested structure
	var parent = Node3D.new()
	var child_collision = CollisionShape3D.new()
	child_collision.shape = SphereShape3D.new()
	parent.add_child(child_collision)
	source_static_body.add_child(parent)
	
	var found_shapes = preview_body._find_collision_shapes(source_static_body)
	expect_true(found_shapes.size() >= 2, "Should find collision shapes including nested ones")
	
	parent.queue_free()