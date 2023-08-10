@tool
## Creates customizable rain effect
class_name Rain3D extends Nodot3D

## The texture for each raindrop
@export var texture: Texture2D = load("res://addons/nodot/textures/raindrop.png"): set = _set_texture
## The color of the raindrops
@export var color: Color = Color(Color.WHITE, 0.3): set = _set_color
## The amount of raindrops
@export var amount: int = 200: set = _set_amount
## Whether the raindrops are shaded
@export var shaded: bool = false: set = _set_shaded
## The size of the raindrops
@export var size: Vector2 = Vector2(10, 10): set = _set_size

var particles_node := GPUParticles3D.new()
var material := StandardMaterial3D.new()
var particle_material := ParticleProcessMaterial.new()

func _init():
	material.albedo_texture = texture
	material.albedo_color = color
	material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(0.04, 0.2)
	mesh.orientation = PlaneMesh.FACE_Z
	mesh.material = material
	
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.emission_box_extents = Vector3(size.x, 0.0, size.y)
	particle_material.gravity = Vector3(0.0, -30.0, 0.0)
	particle_material.collision_mode = ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT
	
	particles_node.process_material = particle_material
	particles_node.draw_pass_1 = mesh
	particles_node.emitting = true
	particles_node.amount = amount
	
	add_child(particles_node)

func _set_texture(new_value: Texture2D):
	texture = new_value
	material.albedo_texture = texture
	
func _set_color(new_value: Color):
	color = new_value
	material.albedo_color = color
	
func _set_amount(new_value: int):
	amount = new_value
	particles_node.amount = amount

func _set_shaded(new_value: bool):
	shaded = new_value
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
func _set_size(new_value: Vector2):
	size = new_value
	particle_material.emission_box_extents = Vector3(size.x, 0.0, size.y)
