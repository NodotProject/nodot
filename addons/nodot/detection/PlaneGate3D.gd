@tool
class_name PlaneGate3D extends Area3D

signal gate_entered(body: Node)
signal gate_exited(body: Node)

@export var size: Vector2 = Vector2(100, 50): set = set_size
@export var tolerence: float = 1.0: set = set_tolerance
@export_category("Debugging")
@export var show_debug_shape: bool = true: set = _set_show_debug_shape

var is_editor: bool = Engine.is_editor_hint()
var collider: CollisionShape3D = CollisionShape3D.new()
var debug_mesh := MeshInstance3D.new()
var debug_arrow := DebugArrowMesh.new()
var debug_material := StandardMaterial3D.new()

func _init():
	create_nodes()
	
func _ready():
	set_size(size)
	connect("body_exited", _on_body_exited)
	
	if is_editor:
		add_child(debug_mesh)
		add_child(debug_arrow)
		debug_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		debug_material.albedo_color = Color(Color.RED, 0.5)
		debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		debug_draw()
	
func _on_body_exited(body: Node):
	var direction = (body.global_transform.origin - global_transform.origin).normalized()
	var forward_vector = -global_transform.basis.z.normalized()
	var dot = direction.dot(forward_vector)
	if dot > 0:
		gate_entered.emit(body)
	else:
		gate_exited.emit(body)

func _set_show_debug_shape(new_value: bool):
	show_debug_shape = new_value
	debug_draw()
	
func debug_draw():
	debug_mesh.mesh = null
	if !show_debug_shape: return
	var immediate_mesh = ImmediateMesh.new()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, debug_material)
	
	var x = size.x / 2
	var y = size.y / 2
	# Define the vertices of the plane
	var v1 = Vector3(-x, -y, 0.0) # Bottom left
	var v2 = Vector3(x, -y, 0.0) # Bottom right
	var v3 = Vector3(x, y, 0.0) # Top right
	var v4 = Vector3(-x, y, 0.0) # Top left

	# Normal pointing up
	var normal = Vector3(0.0, 1.0, 0.0)

	# Draw the first triangle (v1, v2, v3)
	immediate_mesh.surface_add_vertex(v1)
	immediate_mesh.surface_set_normal(normal)
	immediate_mesh.surface_add_vertex(v2)
	immediate_mesh.surface_set_normal(normal)
	immediate_mesh.surface_add_vertex(v3)
	immediate_mesh.surface_set_normal(normal)

	# Draw the second triangle (v1, v3, v4)
	immediate_mesh.surface_add_vertex(v1)
	immediate_mesh.surface_set_normal(normal)
	immediate_mesh.surface_add_vertex(v3)
	immediate_mesh.surface_set_normal(normal)
	immediate_mesh.surface_add_vertex(v4)
	immediate_mesh.surface_set_normal(normal)

	# End drawing
	immediate_mesh.surface_end()
	debug_mesh.mesh = immediate_mesh

func set_tolerance(new_tolerance: float):
	tolerence = new_tolerance
	set_size(size)

func set_size(new_size: Vector2):
	size = new_size
	if collider:
		collider.shape.size = Vector3(size.x, size.y, tolerence)
		if is_editor:
			debug_draw()
	else:
		create_nodes()

func create_nodes():
	collider.shape = BoxShape3D.new()
	add_child(collider)
	set_size(size)
