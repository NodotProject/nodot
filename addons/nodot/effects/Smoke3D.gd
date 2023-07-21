@tool
## Creates customizable smoke
class_name Smoke3D extends Node3D

## Enable or disable the smoke
@export var enabled: bool = true
## The shape the smoke will emit from
@export var emission_shape: Shape3D: set = _emission_shape_set
## The scale (size) of each particle
@export var effect_scale: float = 1.0: set = _effect_scale_set
## The color of the smoke
@export var smoke_color: Color = Color(Color.LIGHT_GRAY, 0.5): set = _smoke_color_set
## Lock global rotation
@export var lock_rotation: bool = true

@onready var initial_global_rotation: Vector3 = global_rotation

var smoke_texture: CompressedTexture2D = preload("res://addons/nodot/textures/fire_spritesheet.png")
var smoke_particle = GPUParticles3D.new()

var smoke_life_time = 1.5
var smoke_scale_min = 1.0
var smoke_scale_max = 2.0

func _enter_tree() -> void:
	if !enabled: return
	
	_setup_smoke_particle()
	if emission_shape:
		build_emission_shape(emission_shape)
		emission_shape.connect("changed", _emission_shape_set)
		
func _physics_process(_delta):
	if lock_rotation:
		global_rotation = initial_global_rotation

func _emission_shape_set(new_shape: Shape3D = emission_shape):
	build_emission_shape(new_shape)
	emission_shape = new_shape
	
func _effect_scale_set(new_effect_scale: float = effect_scale):
	effect_scale = new_effect_scale
	set_effect_scale()
	
func _smoke_color_set(new_value: Color):
	smoke_color = new_value
	set_colors()
	
func _setup_smoke_particle():
	smoke_particle.emitting = enabled
	smoke_particle.amount = 80
	smoke_particle.lifetime = _clamp_lifetime(smoke_life_time)
	smoke_particle.randomness = 1.0
	smoke_particle.draw_order = GPUParticles3D.DRAW_ORDER_INDEX
	
	var particle_material = ParticleProcessMaterial.new()
	smoke_particle.process_material = particle_material
	
	particle_material.direction = Vector3.UP
	particle_material.spread = 0
	particle_material.gravity = Vector3.ZERO
	particle_material.initial_velocity_min = 0.5
	particle_material.initial_velocity_max = 1.0
	particle_material.angular_velocity_max = 40.0
	particle_material.linear_accel_min = 1.0
	particle_material.linear_accel_max = 2.0
	particle_material.radial_accel_min = 0.2
	particle_material.radial_accel_max = 1.0
	particle_material.angle_min = 1.0
	particle_material.angle_max = 360.0
	particle_material.scale_min = smoke_scale_min * effect_scale
	particle_material.scale_max = smoke_scale_max * effect_scale
	particle_material.hue_variation_min = -0.05
	particle_material.hue_variation_max = 0.04
	particle_material.anim_speed_max = 1.0
	particle_material.anim_offset_min = 1.0
	particle_material.anim_offset_max = 1.0
	
	var curve_texture = CurveTexture.new()
	var curve = Curve.new()
	curve_texture.curve = curve
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	particle_material.scale_curve = curve_texture
	
	var gradient_texture = GradientTexture1D.new()
	var gradient = Gradient.new()
	var color_alpha = 0.5
	var next_hue = Color(smoke_color.darkened(0.6), color_alpha)
	gradient.offsets = [0, 0.15, 0.25, 0.35, 1]
	gradient.colors = [Color(Color.BLACK, color_alpha), next_hue, Color(smoke_color, color_alpha), next_hue, Color(Color.BLACK, color_alpha)]
	gradient_texture.gradient = gradient
	particle_material.color_ramp = gradient_texture
	
	var quadmesh = QuadMesh.new()
	var mesh_material = StandardMaterial3D.new()
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true
	mesh_material.albedo_texture = smoke_texture
	mesh_material.particles_anim_h_frames = 6
	mesh_material.particles_anim_v_frames = 5
	mesh_material.particles_anim_loop = true
	mesh_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mesh_material.billboard_keep_scale = true
	quadmesh.material = mesh_material
	
	smoke_particle.draw_pass_1 = quadmesh
	
	add_child(smoke_particle)
		
func _clamp_lifetime(new_lifetime: float):
	return max(0.001, new_lifetime)
	
## Converts the emission shape into particle material values
func build_emission_shape(shape: Shape3D = emission_shape) -> void:
	if  !smoke_particle.process_material: return
	
	if !shape:
		smoke_particle.process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	
	if shape is SphereShape3D:
		smoke_particle.process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		smoke_particle.process_material.emission_sphere_radius = shape.radius
	elif shape is BoxShape3D:
		smoke_particle.process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		smoke_particle.process_material.emission_box_extents = shape.size

func set_effect_scale():
	if  !smoke_particle.process_material: return
	
	smoke_particle.process_material.scale_min = smoke_scale_min * effect_scale
	smoke_particle.process_material.scale_max = smoke_scale_max * effect_scale
	
func set_colors():
	if  !smoke_particle.process_material: return
	
	var smoke_gradient_texture = GradientTexture1D.new()
	var smoke_gradient = Gradient.new()
	var smoke_color_alpha = smoke_color.a
	var smoke_next_hue = smoke_color.darkened(0.6)
	smoke_gradient.offsets = [0, 0.15, 0.25, 0.35, 1]
	smoke_gradient.colors = [Color(Color.BLACK, smoke_color_alpha), smoke_next_hue, smoke_color, smoke_next_hue, Color(Color.BLACK, smoke_color_alpha)]
	smoke_gradient_texture.gradient = smoke_gradient
	smoke_particle.process_material.color_ramp = smoke_gradient_texture

