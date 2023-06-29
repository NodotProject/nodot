@tool
class_name LensFlare extends Node

@export_range(0, 16) var flareStrength := 1.0:
	get:
		return flareStrength
	set(value):
		flareStrength = value
		material.set_shader_parameter("bloom_scale", value)

@export_range(0, 16) var flareBias := 1.05:
	get:
		return flareBias
	set(value):
		flareBias = value
		material.set_shader_parameter("bloom_bias", value)

@export_range(0, 10) var flareBlur := 2.0:
	get:
		return flareBlur
	set(value):
		flareBlur = value
		material.set_shader_parameter("lod", value)

@export_enum("Low", "Medium", "High") var distortionQuality := 0:
	get:
		return distortionQuality
	set(value):
		distortionQuality = value
		material.set_shader_parameter("distortion_quality", value)

@export_range(0, 50) var distortion := 2.0:
	get:
		return distortion
	set(value):
		distortion = value
		material.set_shader_parameter("distort", value)

@export_range(0, 20) var ghostCount := 7:
	get:
		return ghostCount
	set(value):
		ghostCount = value
		material.set_shader_parameter("ghosts", value)

@export_range(0, 1) var ghostSpacing := 0.3:
	get:
		return ghostSpacing
	set(value):
		ghostSpacing = value
		material.set_shader_parameter("ghost_dispersal", value)

@export_range(0, 1) var haloWidth := 0.25:
	get:
		return haloWidth
	set(value):
		haloWidth = value
		material.set_shader_parameter("halo_width", value)

@export var lensDirt: Texture2D = preload("lens_dirt_default.jpeg"):
	get:
		return lensDirt
	set(value):
		lensDirt = value
		material.set_shader_parameter("lens_dirt", value)

@export var streakStrength := 0.5:
	get:
		return streakStrength
	set(value):
		streakStrength = value
		material.set_shader_parameter("streak_strength", value)

@export var enabled := true:
	get:
		return screen.visible
	set(value):
		screen.visible = value

var screen: MeshInstance3D
var material: ShaderMaterial


func _init():
	var mesh = QuadMesh.new()
	mesh.orientation = QuadMesh.FACE_Z
	mesh.size = Vector2(2, 2)
	mesh.flip_faces = true

	screen = MeshInstance3D.new()
	screen.mesh = mesh
	# TODO This is to prevent the mesh from being culled, but is there a better way?
	screen.scale = Vector3(1, 1, 1) * pow(2.0, 30)
	add_child(screen)
	screen.material_override = preload("lens_flare_shader.tres").duplicate()
	material = screen.material_override


func _enter_tree() -> void:
	flareStrength = flareStrength
	flareBias = flareBias
	distortion = distortion
	distortionQuality = distortionQuality
	ghostCount = ghostCount
	ghostSpacing = ghostSpacing
	haloWidth = haloWidth
	streakStrength = streakStrength
	flareBlur = flareBlur
	lensDirt = lensDirt
