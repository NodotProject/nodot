## Spawns a bullethole
class_name BulletHole extends Node3D

## An array of StandardMaterial3Ds to use as the bullethole decal. The material index can be retrieved from the target nodes "physical_material" property. The first material is the fallback default.
@export var textures: Array[StandardMaterial3D]
## Randomly rotate the decal
@export var random_rotation: bool = true
## Maximum number of bullet holes
@export var instance_limit: int = 20
## The minimum size of the hole
@export var hole_minimum_size: float = 0.15
## The maximum size of the hole
@export var hole_maximum_size: float = 0.2

@export_flags_3d_render var decal_mask := 1
@export_flags_3d_render var decal_layer := 1

signal created(decal: Decal)

var pool := NodePool.new()

func _ready():
	pool.pool_limit = instance_limit
	pool.spawn_root = get_tree().root
	
	var decal_node: Decal = Decal.new()
	decal_node.cull_mask = decal_mask
	decal_node.layers = decal_layer
	decal_node.top_level = true
	
	pool.target_node = decal_node

## Creates a bullethole decale, applies the texture and rotation/position calculations and removes the bullethole after the lifespan
func action(hit_target: HitTarget) -> void:
	var material: StandardMaterial3D = textures[0]
	if "physical_material" in hit_target.target_node:
		var target_material_name: PhysicsMaterial = hit_target.target_node.physical_material
		if target_material_name and textures.has(target_material_name):
			material = textures[target_material_name]

	if !material:
		return

	var decal_node: Decal = pool.next()
	decal_node.texture_albedo = material.albedo_texture
	decal_node.texture_emission = material.emission_texture
	decal_node.texture_normal = material.normal_texture
	decal_node.size = Vector3(randf_range(hole_minimum_size, hole_maximum_size), 0.02, randf_range(hole_minimum_size, hole_maximum_size))
	_position_decal.call_deferred(decal_node, hit_target)
	
func _position_decal(decal_node: Decal, hit_target: HitTarget):
	decal_node.global_transform = Transform3D(hit_target.raycast_basis, hit_target.collision_point) * Transform3D(Basis().rotated(Vector3(1, 0, 0), deg_to_rad(90)), Vector3())
	decal_node.global_basis = Basis(Quaternion(decal_node.global_basis.y, hit_target.collision_normal)) * decal_node.global_basis
	
	# Apply random rotation around the normal
	if random_rotation:
		decal_node.rotate(hit_target.collision_normal, randf_range(0, 2 * PI))
	
	created.emit(decal_node)
