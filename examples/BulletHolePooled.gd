## Improved BulletHole implementation demonstrating the new PooledNode system
## This version supports both traditional pooling and automatic pooling with NOTIFY_PREDELETE
class_name BulletHolePooled extends Node3D

## An array of StandardMaterial3Ds to use as the bullethole decal
@export var textures: Array[StandardMaterial3D]
## Randomly rotate the decal
@export var random_rotation: bool = true
## Maximum number of bullet holes
@export var instance_limit: int = 20
## The minimum size of the hole
@export var hole_minimum_size: float = 0.15
## The maximum size of the hole
@export var hole_maximum_size: float = 0.2
## How long bullet holes last before being recycled (in seconds)
@export var hole_lifespan: float = 30.0
## Use the new automatic pooling system (recommended)
@export var use_automatic_pooling: bool = true

@export_flags_3d_render var decal_mask := 1
@export_flags_3d_render var decal_layer := 1

signal created(decal: Node)

var pool := NodePool.new()

func _ready():
	pool.pool_limit = instance_limit
	pool.spawn_root = get_tree().root
	
	if use_automatic_pooling:
		# Use the new PooledDecal system - nodes automatically return to pool
		var pooled_decal = PooledDecal.new()
		pooled_decal.lifespan = hole_lifespan
		pool.target_node = pooled_decal
	else:
		# Traditional system - manual pool management
		var decal_node: Decal = Decal.new()
		decal_node.cull_mask = decal_mask
		decal_node.layers = decal_layer
		decal_node.top_level = true
		pool.target_node = decal_node

## Creates a bullethole decal with automatic or manual pooling
func action(hit_target: HitTarget) -> void:
	var material: StandardMaterial3D = textures[0]
	if "physical_material" in hit_target.target_node:
		var target_material_name: PhysicsMaterial = hit_target.target_node.physical_material
		if target_material_name and textures.has(target_material_name):
			material = textures[target_material_name]

	if !material:
		return

	if use_automatic_pooling:
		_create_pooled_decal(material, hit_target)
	else:
		_create_traditional_decal(material, hit_target)

func _create_pooled_decal(material: StandardMaterial3D, hit_target: HitTarget):
	var pooled_decal: PooledDecal = pool.next()
	var texture = material.albedo_texture
	var position = hit_target.collision_point
	var normal = hit_target.collision_normal
	var size = Vector3(
		randf_range(hole_minimum_size, hole_maximum_size), 
		0.02, 
		randf_range(hole_minimum_size, hole_maximum_size)
	)
	
	pooled_decal.setup_decal(texture, position, normal, size)
	
	# Apply additional textures if available
	if material.emission_texture:
		pooled_decal.decal.texture_emission = material.emission_texture
	if material.normal_texture:
		pooled_decal.decal.texture_normal = material.normal_texture
	
	# Apply random rotation
	if random_rotation:
		pooled_decal.rotate(normal, randf_range(0, 2 * PI))
	
	created.emit(pooled_decal)
	
	# The decal will automatically return to the pool when its lifespan expires!
	# No manual cleanup needed - developers can even call queue_free() manually and it will still be recycled

func _create_traditional_decal(material: StandardMaterial3D, hit_target: HitTarget):
	# Traditional implementation for comparison
	var decal_node: Decal = pool.next()
	decal_node.texture_albedo = material.albedo_texture
	decal_node.texture_emission = material.emission_texture
	decal_node.texture_normal = material.normal_texture
	decal_node.size = Vector3(
		randf_range(hole_minimum_size, hole_maximum_size), 
		0.02, 
		randf_range(hole_minimum_size, hole_maximum_size)
	)
	_position_decal.call_deferred(decal_node, hit_target)

func _position_decal(decal_node: Decal, hit_target: HitTarget):
	decal_node.global_transform = Transform3D(hit_target.raycast_basis, hit_target.collision_point) * Transform3D(Basis().rotated(Vector3(1, 0, 0), deg_to_rad(90)), Vector3())
	decal_node.global_basis = Basis(Quaternion(decal_node.global_basis.y, hit_target.collision_normal)) * decal_node.global_basis
	
	# Apply random rotation around the normal
	if random_rotation:
		decal_node.rotate(hit_target.collision_normal, randf_range(0, 2 * PI))
	
	created.emit(decal_node)
	
	# In traditional system, we need manual cleanup
	await get_tree().create_timer(hole_lifespan).timeout
	if is_instance_valid(decal_node) and decal_node.get_parent():
		decal_node.get_parent().remove_child(decal_node)