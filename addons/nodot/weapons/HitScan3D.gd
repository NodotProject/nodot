@tool
class_name HitScan3D extends Nodot3D

## Detects a hit between the start point end target

## Whether to enable the hitscan or not
@export var enabled = false
## Which raycast to use
@export var raycast: RayCast3D
## The accuracy of the shot (0.0 = 100% accurate)
@export var accuracy := 0.0
## How much damage to deal to the target (0.0 to disable)
@export var damage = 0.0
## Damage reduction per meter of distance as a percentage (0.0 to disable)
@export var damage_distance_reduction = 0.0

signal target_hit(hit_target: HitTarget)

var rng = RandomNumberGenerator.new()

## Execute the hitscan
func action():
  if enabled:
    if accuracy > 0.0:
      aim_raycast()
    return get_hit_target()

## Point the raycast at the target with a random offset based on accuracy
func aim_raycast():
  if raycast.enabled:
    var new_x = rng.randf_range(-accuracy, accuracy)
    var new_y = rng.randf_range(-accuracy, accuracy)
    raycast.target_position = Vector3(new_x, new_y, -500)
    raycast.force_raycast_update()

## Get the objects that the raycast is colliding with
func get_hit_target():
  if raycast.enabled and raycast.is_colliding():
    var collider = raycast.get_collider()
    if collider:
      var hit_target = HitTarget.new(get_distance(collider), raycast.get_collision_point(), raycast.get_collision_normal(), collider)
      emit_signal("target_hit", hit_target)
      if damage > 0.0:
        if hit_target.has_method("damage"):
          var final_damage = damage
          # TODO: reduce damage by distance if damage_distance_reduction > 0.0
          hit_target.damage(final_damage)
      return hit_target
  
## Returns the distance from the raycast origin to the target
func get_distance(object: Variant):
  return object.position.distance_to(raycast.get_global_transform().origin)
