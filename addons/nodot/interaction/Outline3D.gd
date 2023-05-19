## Adds an outline to the parent mesh
class_name Outline3D extends Nodot

## Outline color
@export var outline_color: Color = Color.WHITE
## Outline width
@export var outline_width: float = 1.0
## Mesh to outline
@export var mesh: MeshInstance3D

@onready var parent = get_parent()

var shader: Shader = load("res://addons/nodot/shaders/outline3d.gdshader")
var shader_material: ShaderMaterial = ShaderMaterial.new()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is RigidBody3D and not get_parent() is StaticBody3D:
		warnings.append("The parent should be a RigidBody3D or StaticBody3D")
	return warnings


func _ready():
	shader_material.shader = shader
	shader_material.set_shader_parameter("outline_color", outline_color)
	shader_material.set_shader_parameter("outline_width", outline_width)


## Adds the outline to the mesh material overlay
func focussed():
	if is_instance_valid(mesh):
		mesh.material_overlay = shader_material


## Remove the outline from the mesh material overlay
func unfocussed():
	if is_instance_valid(mesh):
		mesh.material_overlay = null
