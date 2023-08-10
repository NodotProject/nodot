@tool
## Creates customizable snow effect
class_name Snow3D extends Nodot3D

## Texture used for snowflakes
@export var texture: Texture2D = load("res://addons/nodot/textures/snowflake.png"): set = _set_texture
## Color of snowflakes
@export var color: Color = Color(Color.WHITE, 0.3): set = _set_color
## Amount of snowflakes
@export var amount: int = 200: set = _set_amount
## If true, snowflakes will be shaded
@export var shaded: bool = false: set = _set_shaded
## Size of snowflakes
@export var size: Vector2 = Vector2(10, 10): set = _set_size

var particles_node := GPUParticles3D.new()
var material := StandardMaterial3D.new()
var particle_material := ParticleProcessMaterial.new()

func _init():
	material.albedo_texture = texture
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(0.2, 0.2)
	mesh.orientation = PlaneMesh.FACE_Z
	mesh.material = material
	
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.emission_box_extents = Vector3(size.x, 0.0, size.y)
	particle_material.particle_flag_align_y = true
	particle_material.gravity = Vector3(0.0, -5.0, 0.0)
	particle_material.collision_mode = ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT
	particle_material.angle_min = -270.0
	particle_material.angle_max = 270.0
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.8
	particle_material.turbulence_enabled = true
	particle_material.turbulence_noise_scale = 1.12
	particle_material.turbulence_noise_speed = Vector3(0.0, 2.5, 0.0)
	
	particles_node.process_material = particle_material
	particles_node.draw_pass_1 = mesh
	particles_node.emitting = true
	particles_node.amount = amount
	particles_node.lifetime = 5.0
	
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
