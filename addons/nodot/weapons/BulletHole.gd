@tool
## Spawns a bullethole
class_name BulletHole extends Nodot3D

## An array of StandardMaterial3Ds to use as the bullethole decal. The material index can be retrieved from the target nodes "physical_material" property. The first material is the fallback default.
@export var textures: Array[StandardMaterial3D]
## Randomly rotate the decal
@export var random_rotation: bool = true
## Seconds before the bullet hole is removed. (0.0 to keep forever)
@export var lifespan: float = 20.0
## For playing a sound when created
@export var sfx_player: SFXPlayer3D


## Creates a bullethole decale, applies the texture and rotation/position calculations and removes the bullethole after the lifespan
func action(hit_target: HitTarget) -> void:
	var material: StandardMaterial3D = textures[0]
	if "physical_material" in hit_target.target_node:
		var target_material_name: PhysicsMaterial = hit_target.target_node.physical_material
		if target_material_name and textures.has(target_material_name):
			material = textures[target_material_name]

	if !material:
		return

	var decal_node: Decal = Decal.new()
	decal_node.texture_albedo = material.albedo_texture
	decal_node.texture_emission = material.emission_texture
	decal_node.texture_normal = material.normal_texture
	decal_node.size = Vector3(0.2, 0.2, 0.2)

	hit_target.target_node.add_child(decal_node)

	decal_node.global_transform.origin = hit_target.collision_point
	if hit_target.collision_normal != Vector3.UP:
		decal_node.look_at(hit_target.collision_point + hit_target.collision_normal, Vector3.UP)
		decal_node.transform = decal_node.transform.rotated_local(Vector3.RIGHT, PI / 2.0)

	if random_rotation:
		decal_node.rotate(hit_target.collision_normal, randf_range(0, 2 * PI))

	if lifespan > 0.0:
		await get_tree().create_timer(lifespan, false).timeout
		if is_instance_valid(decal_node):
			decal_node.queue_free()
