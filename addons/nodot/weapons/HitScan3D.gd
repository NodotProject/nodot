@tool
## Detects a hit between the start point end target
class_name HitScan3D extends Nodot3D

## Whether to enable the hitscan or not
@export var enabled: bool = false
## Which raycast to use
@export var raycast: RayCast3D
## The accuracy of the shot (0.0 = 100% accurate)
@export var accuracy: float = 0.0
## How much damage to deal to the target (0.0 to disable)
@export var damage: float = 0.0
## Damage reduction per meter of distance as a percentage (0.0 to disable)
@export var damage_distance_reduction: float = 0.0
## Total distance (meters) to search for hit targets
@export var distance: float = 500
## Amount of applied force to a RigidBody3D on impact
@export var applied_force: float = 1.0
## Reverses the damage to heal instead
@export var healing: bool = false

signal target_hit(hit_target: HitTarget);

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var charge_amount: float = 0.0;

## Execute the hitscan
## TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162
@rpc("any_peer", "call_local")
func action(dispatch_count: int = 1, _charge_amount: float = 0.0) -> void:
	if enabled:
		charge_amount = _charge_amount;
		for i in dispatch_count:
			if accuracy > 0.0:
				aim_raycast()
			get_hit_target()


## Point the raycast at the target with a random offset based on accuracy
func aim_raycast() -> void:
	if raycast.enabled:
		var new_x: float = rng.randf_range(-accuracy, accuracy)
		var new_y: float = rng.randf_range(-accuracy, accuracy)
		raycast.target_position = Vector3(new_x, new_y, -distance)
		raycast.force_raycast_update()


## Get the objects that the raycast is colliding with
## TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162
func get_hit_target():
	if !(raycast.enabled or raycast.is_colliding()): return
	var collider: Node3D = raycast.get_collider()
	if !collider: return
	var distance: float = get_distance(collider)
	var hit_target = HitTarget.new(
		distance, raycast.get_collision_point(), raycast.get_collision_normal(), collider, raycast.global_basis
	)
	
	if applied_force > 0 and not hit_target.target_node.has_meta("NonPunchable"):
		var direction = raycast.global_position.direction_to(hit_target.collision_point)
		var force = direction * applied_force
		if collider is RigidBody3D:
			collider.apply_impulse(
				force, hit_target.collision_point - collider.global_position
			)
		if collider is StaticBreakable3D or collider is RigidBreakable3D:
			collider.save_impulse(
				force, hit_target.collision_point, collider.global_position
			)
	
	if damage > 0.0:
		var collider_healths: Array[Node] = collider.find_children("*", "Health")
		var collider_hitboxes: Array[Node] = collider.find_children("*", "HitBox3D")
		var hitbox_present: bool = collider_hitboxes.size() > 0
		var hitbox_hit: bool = false
		var final_damage: float = damage
		
		for hitbox in collider_hitboxes:
			if hitbox.is_point_inside(hit_target.collision_point):
				final_damage *= hitbox.damage_multiplier
				hitbox_hit = true
				break
		
		if collider_healths.size() > 0:
			var collider_health: Health = collider_healths[0]
			var should_apply_damage = !(hitbox_present and collider_health.hitbox_only and !hitbox_hit)
			
			if should_apply_damage:
				# Calculate damage reduction
				if damage_distance_reduction > 0.0:
					var damage_reduction: float = (
						(final_damage / 100) * damage_distance_reduction
					)
					final_damage = final_damage - (distance * damage_reduction)
				# Apply damage to the hit target
				if !healing:
					final_damage = -final_damage
				collider_health.add_health(final_damage)
	
	target_hit.emit(hit_target)
	return hit_target


## Returns the distance from the raycast origin to the target
func get_distance(object: Variant) -> float:
	return object.position.distance_to(raycast.get_global_transform().origin)

## When the parent item is activated
func activate():
	if raycast and raycast.enabled:
		raycast.target_position = Vector3(0, 0, -distance)
