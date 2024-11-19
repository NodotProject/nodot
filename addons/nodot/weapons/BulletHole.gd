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
## For Size of the bullet hole
@export var hole_size: Vector3 = Vector3(0.2, 0.2, 0.2);
## For random size of the bullet hole
@export var random_size: bool = false;
## For detectable bullet holes
@export var raycast_detectable: bool = false;
## For decal name given to raycast
@export var decal_name: String = "";

@export_flags_3d_render var decal_mask := 1;

@export_flags_3d_render var decal_layer := 1;

signal decal_added(decal: Decal)

var enabled: bool = true;

## Creates a bullethole decale, applies the texture and rotation/position calculations and removes the bullethole after the lifespan
func action(hit_target: HitTarget) -> void:
	if enabled:
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
		
		
		decal_node.cull_mask = decal_mask
		decal_node.layers = decal_layer
		
		if random_size:
			decal_node.size = Vector3(randf_range(0.1, 0.8), randf_range(0.1, 0.8), randf_range(0.1, 0.8));
		else:
			decal_node.size = hole_size
		
		if raycast_detectable:
			var detection_area: Area3D = Area3D.new();
			var collision_shape: CollisionShape3D = CollisionShape3D.new();
			var box_shape = BoxShape3D.new();
			box_shape.size = hole_size * 1.3;
			collision_shape.shape = box_shape;
			detection_area.add_child(collision_shape);
			decal_node.add_child(detection_area);

		if decal_name != "":
			decal_node.name = decal_name;

		hit_target.target_node.add_child(decal_node, decal_name != "", INTERNAL_MODE_FRONT)
		decal_added.emit(decal_node)

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
