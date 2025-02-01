## A 3D muzzle flash effect that can be attached to a weapon.
class_name MuzzleFlash3D extends Node3D

@export var enabled: bool = true
## The magazine to trigger the effect
@export var magazine: Magazine
## Texture for the muzzle flash effect
@export var flash_texture: Texture2D
## Set the render priority
@export var render_priority: int = 0: set = _set_render_priority
## Minimum scale of the effect
@export var effect_scale_max: float = 0.3: set = _set_effect_scale_max
## Maximum scale of the fire particles
@export var effect_scale_min: float = 0.1: set = _set_effect_scale_min
## Color of the effect
@export var color: Color = Color(1.0, 1.0, 1.0)
## Energy of the light
@export var light_energy: float = 1.0

var flash_particle = GPUParticles3D.new()
var light = OmniLight3D.new()

func _ready():
	magazine.discharged.connect(action)

func _enter_tree():
	setup_particle_emitter()

	## Create an omnilight and add it to the scene
	light.light_color = color
	light.light_energy = light_energy
	light.shadow_enabled = true
	light.visible = false
	add_child(light)

func _set_effect_scale_max(new_value: float):
	effect_scale_max = new_value
	if flash_particle.process_material:
		flash_particle.process_material.scale_max = effect_scale_max

func _set_effect_scale_min(new_value: float):
	effect_scale_min = new_value
	if flash_particle.process_material:
		flash_particle.process_material.scale_min = effect_scale_min

func setup_particle_emitter() -> void:
	flash_particle.emitting = false
	flash_particle.amount = 1
	flash_particle.lifetime = 0.01
	flash_particle.randomness = 1.0
	flash_particle.draw_order = GPUParticles3D.DRAW_ORDER_INDEX
	flash_particle.sorting_offset = 1.0
	flash_particle.one_shot = true
	flash_particle.local_coords = true
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.render_priority = render_priority
	flash_particle.process_material = particle_material
	
	particle_material.spread = 0
	particle_material.gravity = Vector3.ZERO
	particle_material.direction = Vector3.ZERO
	particle_material.angle_min = 1.0
	particle_material.angle_max = 360.0
	particle_material.scale_min = effect_scale_min
	particle_material.scale_max = effect_scale_max
	particle_material.hue_variation_min = -0.05
	particle_material.hue_variation_max = 0.04
	
	var gradient_texture = GradientTexture1D.new()
	var gradient = Gradient.new()
	var next_hue = color.darkened(0.6)
	gradient.offsets = [0, 0.15, 0.25, 0.35, 1]
	gradient.colors = [Color.BLACK, next_hue, color, next_hue, Color.BLACK]
	gradient_texture.gradient = gradient
	particle_material.color_ramp = gradient_texture
	
	var quadmesh = QuadMesh.new()
	var mesh_material = StandardMaterial3D.new()
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true
	mesh_material.albedo_texture = flash_texture
	mesh_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mesh_material.billboard_keep_scale = true
	mesh_material.render_priority = render_priority
	quadmesh.material = mesh_material
	
	flash_particle.draw_pass_1 = quadmesh
	
	add_child(flash_particle)

func _set_render_priority(new_priority: int):
	render_priority = new_priority
	if flash_particle.draw_pass_1:
		flash_particle.draw_pass_1.surface_get_material(0).render_priority = new_priority

func action():
	light.visible = true
	flash_particle.emitting = true
	await get_tree().create_timer(0.1).timeout
	light.visible = false
