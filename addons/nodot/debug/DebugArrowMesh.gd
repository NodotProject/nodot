@tool
class_name DebugArrowMesh extends MeshInstance3D

@export var size: float = 1
@export var fat:  float = 1
@export var color: Color = Color.WHITE_SMOKE

var arrowmesh: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	arrowmesh = fancyArrow( size , color )
	add_child( arrowmesh )

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

# draw the fancy arrow
func fancyArrow( size: float, color = Color.RED) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := getArrowMaterial()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.set_cast_shadows_setting( mesh_instance.SHADOW_CASTING_SETTING_OFF )
	
	addStrip(immediate_mesh,vb(0,0,0),vb(0.05,-1.9,-0.025),vb(-0.05,-1.9,-0.025),material)
	addStrip(immediate_mesh,vb(0,0,0),vb(-0.05,-1.9,-0.025),vb(-0.05,-1.9,0.025),material)
	addStrip(immediate_mesh,vb(0,0,0),vb(-0.05,-1.9,0.025),vb(0.05,-1.9,0.025),material)
	addStrip(immediate_mesh,vb(0,0,0),vb(0.05,-1.9,0.025),vb(0.05,-1.9,-0.025),material)
	
	addStrip(immediate_mesh,vb(0.1,-1.9,0),vb(0.05,-1.9,-0.025),vb(0.05,-1.9,0.025),material)
	addStrip(immediate_mesh,vb(-0.1,-1.9,0),vb(-0.05,-1.9,0.025),vb(-0.05,-1.9,-0.025),material)

	addStrip(immediate_mesh,vb(0,-2,0),vb(-0.1,-1.9,0),vb(-0.05,-1.9,-0.025),material)
	addStrip(immediate_mesh,vb(0,-2,0),vb(-0.05,-1.9,-0.025),vb(0.05,-1.9,-0.025),material)
	addStrip(immediate_mesh,vb(0,-2,0),vb(0.05,-1.9,-0.025),vb(0.1,-1.9,0),material)

	addStrip(immediate_mesh,vb(0,-2,0),vb(-0.05,-1.9,0.025),vb(-0.1,-1.9,0),material)
	addStrip(immediate_mesh,vb(0,-2,0),vb(0.05,-1.9,0.025),vb(-0.05,-1.9,0.025),material)
	addStrip(immediate_mesh,vb(0,-2,0),vb(0.1,-1.9,0),vb(0.05,-1.9,0.025),material)
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	mesh_instance.transform.origin = Vector3(0,0,0) 
	set_scale( Vector3(fat,fat,size/2) )
	
	return mesh_instance
