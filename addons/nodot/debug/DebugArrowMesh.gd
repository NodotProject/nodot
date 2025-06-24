@tool
class_name DebugArrowMesh extends MeshInstance3D

@export var size: float = 1:
	set(new_value):
		size = new_value
		draw_arrow()
@export var fat:  float = 1:
	set(new_value):
		fat = new_value
		draw_arrow()
@export var color: Color = Color.WHITE_SMOKE:
	set(new_value):
		color = new_value
		draw_arrow()

var is_editor: bool = Engine.is_editor_hint()

func _init():
	draw_arrow()
	
func draw_arrow():
	if !is_editor: return
	var immediate_mesh := ImmediateMesh.new()
	var material := getArrowMaterial()

	set_cast_shadows_setting(SHADOW_CASTING_SETTING_OFF)

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)

	# Define triangles
	addTriangle(immediate_mesh, vb(0,0,0), vb(0.05,-1.9,-0.025), vb(-0.05,-1.9,-0.025))
	addTriangle(immediate_mesh, vb(0,0,0), vb(-0.05,-1.9,-0.025), vb(-0.05,-1.9,0.025))
	addTriangle(immediate_mesh, vb(0,0,0), vb(-0.05,-1.9,0.025), vb(0.05,-1.9,0.025))
	addTriangle(immediate_mesh, vb(0,0,0), vb(0.05,-1.9,0.025), vb(0.05,-1.9,-0.025))

	addTriangle(immediate_mesh, vb(0.1,-1.9,0), vb(0.05,-1.9,-0.025), vb(0.05,-1.9,0.025))
	addTriangle(immediate_mesh, vb(-0.1,-1.9,0), vb(-0.05,-1.9,0.025), vb(-0.05,-1.9,-0.025))

	addTriangle(immediate_mesh, vb(0,-2,0), vb(-0.1,-1.9,0), vb(-0.05,-1.9,-0.025))
	addTriangle(immediate_mesh, vb(0,-2,0), vb(-0.05,-1.9,-0.025), vb(0.05,-1.9,-0.025))
	addTriangle(immediate_mesh, vb(0,-2,0), vb(0.05,-1.9,-0.025), vb(0.1,-1.9,0))

	addTriangle(immediate_mesh, vb(0,-2,0), vb(-0.05,-1.9,0.025), vb(-0.1,-1.9,0))
	addTriangle(immediate_mesh, vb(0,-2,0), vb(0.05,-1.9,0.025), vb(-0.05,-1.9,0.025))
	addTriangle(immediate_mesh, vb(0,-2,0), vb(0.1,-1.9,0), vb(0.05,-1.9,0.025))

	immediate_mesh.surface_end()

	scale = Vector3(fat, fat, size / 2)
	mesh = immediate_mesh

# Create a material based on the color ( you can put transparency )
func getArrowMaterial() -> Material:
	var material :=  StandardMaterial3D.new()
	material.set_specular(0.5)
	material.set_metallic(0.5)
	material.set_transparency( material.TRANSPARENCY_ALPHA )
	material.set_albedo(color)
	return material

# convert blender coordenates to godot cords
# observe that to get the correct face : get the triangle main point, and go ant-hour
func vb(x:float,y:float,z:float) -> Vector3:
	return Vector3(x,z,y)

# add a strip triangle with material to the mesh
func addStrip( m: ImmediateMesh, v1: Vector3, v2: Vector3, v3: Vector3 , mat: Material ):
	m.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, mat)
	m.surface_add_vertex(v1)
	m.surface_add_vertex(v2)
	m.surface_add_vertex(v3)
	m.surface_end()

func addTriangle(mesh: ImmediateMesh, v1: Vector3, v2: Vector3, v3: Vector3):
	mesh.surface_add_vertex(v1)
	mesh.surface_add_vertex(v2)
	mesh.surface_add_vertex(v3)
