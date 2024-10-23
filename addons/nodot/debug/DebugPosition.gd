@tool
class_name DebugPosition extends Marker3D

## Whether to show this point
@export var enabled: bool = true
## Whether to show global or local coordinates
@export var global: bool = true

var mesh := MeshInstance3D.new()
var label := Label3D.new()
var last_position: Vector3

func _enter_tree() -> void:
	var sphere := SphereMesh.new()
	sphere.height = 0.2
	sphere.radius = 0.1
	mesh.mesh = sphere
	add_child(mesh)
	
	label.fixed_size = true
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.001
	label.position.y = 0.25
	add_child(label)
	
	last_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position != last_position:
		last_position = global_position
		label.text = "%s x %s x %s" % [global_position.x, global_position.y, global_position.z]
