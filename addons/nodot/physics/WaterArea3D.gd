@tool
@icon("../icons/water.svg")
## An area with a water surface where the player can swim and objects can float
class_name WaterArea3D extends Area3D

## The shader to apply to the quad plane on top of the waterarea
@export var water_shader: ShaderMaterial = load("res://addons/nodot/shaders/clean_water.tres")
## The upward force to apply to submerged objects
@export var float_force: float = 1.0
## A direction to push floating objects in
@export var tidal_direction: Vector3 = Vector3.ZERO
## How hard to push the objects
@export var tidal_force: float = 0.0
# TODO: Fix probes logic
# @export var force_probes: int = 9

@onready var default_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_editor: bool = Engine.is_editor_hint()
var rng = RandomNumberGenerator.new()
var water_mesh_instance: MeshInstance3D = MeshInstance3D.new()

# Used to track bodies
var body_tracker: Array[RigidBody3D] = []

# An array of vector3 arrays
# var probe_tracker = []

# Used to simulate the waves in gdscript
var water_drag: float = 0.05
var water_angular_drag: float = 0.05
var material: ShaderMaterial
var noise: Image
var noise_scale: float
var wave_speed: float
var height_scale: float
var time: float


func _enter_tree() -> void:	
	var collider_shape  # TODO: Missing type
	for child in get_children():
		if child is CollisionShape3D:
			collider_shape = child.shape

	var waterMesh = QuadMesh.new()
	waterMesh.orientation = QuadMesh.FACE_Y

	if collider_shape is BoxShape3D:
		waterMesh.size = Vector2(collider_shape.size.x, collider_shape.size.z)
	if collider_shape is CylinderShape3D:
		waterMesh.size = Vector2(collider_shape.radius * 2, collider_shape.radius * 2)

	waterMesh.subdivide_width = 200
	waterMesh.subdivide_depth = 200
	waterMesh.material = water_shader
	water_mesh_instance.mesh = waterMesh
	water_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	if collider_shape is BoxShape3D:
		water_mesh_instance.position.y = collider_shape.size.y / 2
	if collider_shape is CylinderShape3D:
		water_mesh_instance.position.y = collider_shape.height / 2

	add_child(water_mesh_instance)

	material = waterMesh.surface_get_material(0)
	noise = material.get_shader_parameter("wave").noise.get_seamless_image(512, 512)
	noise_scale = material.get_shader_parameter("noise_scale")
	wave_speed = material.get_shader_parameter("wave_speed")
	height_scale = material.get_shader_parameter("height_scale")
	
	if is_editor: return
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and !body_tracker.has(body):
		# TODO: Create better probe logic
		# create_probes(body)
		body_tracker.append(body)
		if body.has_method("set_submerged"):
			body.set_submerged(true, self)
	if (
		body is CharacterBody3D
		and "submerge_handler" in body
		and body.submerge_handler.has_method("set_submerged")
	):
		body.submerge_handler.set_submerged(true, self)


func _on_body_exited(body: Node3D) -> void:
	if body is RigidBody3D and body_tracker.has(body):
		var idx = body_tracker.find(body)
		body_tracker.remove_at(idx)
		if body.has_method("set_submerged"):
			body.set_submerged(false, self)
	# probe_tracker.remove_at(idx)
	if (
		body is CharacterBody3D
		and "submerge_handler" in body
		and body.submerge_handler.has_method("set_submerged")
	):
		body.submerge_handler.set_submerged(false, self)


func _physics_process(delta: float) -> void:
	time += delta
	if !is_editor:
		material.set_shader_parameter("wave_time", time)

	for idx in body_tracker.size():
		if idx <= body_tracker.size() - 1:
			var body = body_tracker[idx]

			# TODO: Create better probe logic
			# var probes = probe_tracker[idx]
			# for p in probes:
			#   var depth = get_wave_height(body.global_position + p) - body.global_position.y
			#  if depth > 0:
			#    body.linear_velocity *= 1 - water_drag
			#    body.angular_velocity *= 1 - water_angular_drag
			#    body.apply_force(Vector3.UP * float_force * gravity * depth, p)

			var depth = get_wave_height(body.global_position) - body.global_position.y
			if depth > 0:
				body.linear_velocity *= 1 - water_drag
				body.angular_velocity *= 1 - water_angular_drag
				# This await allows other physics to apply first
				await get_tree().physics_frame
				if is_instance_valid(body):
					var final_float_force = Vector3.UP * float_force * default_gravity * depth
					final_float_force.y = min(final_float_force.y, 90)
					body.apply_force(final_float_force + (tidal_direction * tidal_force))


## Create probe points (global position coordinates) at varying positions at the bottom of the body collider
# func create_probes(body: RigidBody3D):
#  var probes: Array[Vector3] = []
#  for p in force_probes:
#    var body_mesh_instance
#    for child in body.get_children():
#      if child is MeshInstance3D:
#        body_mesh_instance = child
#    if body_mesh_instance:
#      var body_mesh_size: Vector3 = body_mesh_instance.mesh.get_aabb().size
#      # TODO: This math needs to be fixed as the objects just seem to spin
#      var probe = Vector3(rng.randf() * body_mesh_size.x, rng.randf() * body_mesh_size.y, rng.randf() * body_mesh_size.z)
#      probes.append(probe)
#  probe_tracker.append(probes)


## Used to get the wave height at a certain position
func get_wave_height(world_position: Vector3) -> float:
	var uv_x = wrapf(world_position.x / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf(world_position.z / noise_scale + time * wave_speed, 0, 1)

	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return water_mesh_instance.global_position.y + noise.get_pixelv(pixel_pos).r * height_scale
