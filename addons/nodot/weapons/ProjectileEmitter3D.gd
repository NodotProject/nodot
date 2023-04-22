@tool
## Launches an object or objects at the specified rotation
class_name ProjectileEmitter3D extends Nodot3D

## Whether to enable the projectile emitter or not
@export var enabled: bool = true
## The accuracy of the emission (0.0 = emit with 100% accuracy, 50.0 = emit in any forward direction, 100.0 = emit in any direction)
@export var accuracy : float = 0.0

@onready var initial_rotation = rotation
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var projectiles: Array[Projectile3D] = []
var is_editor: bool = Engine.is_editor_hint()

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  var has_projectile_child = false
  for child in get_children():
    if child is Projectile3D:
      has_projectile_child = true
  if has_projectile_child == false:
    warnings.append("Should have a Projectile3D as a child")
  return warnings

func _enter_tree() -> void:
  if !is_editor:
    for child in get_children():
      if child is Projectile3D:
        projectiles.append(child)
        remove_child(child)

## Apply the accuracy to the emitter
func aim_emitter() -> void:
  if enabled and accuracy > 0.0:
    var accuracy_radians: float = accuracy * PI / 100
    var new_x: float = rng.randf_range(-accuracy_radians, accuracy_radians)
    var new_y: float = rng.randf_range(-accuracy_radians, accuracy_radians)
    var new_z: float = rng.randf_range(-accuracy_radians, accuracy_radians)
    rotation = initial_rotation + Vector3(new_x, new_y, new_z)

## Execute the emitter
func action() -> void:
  if enabled:
    for projectile in projectiles:
      if accuracy > 0.0:
        aim_emitter()
      var new_projectile: Projectile3D = projectile.duplicate(15)
      get_tree().root.add_child(new_projectile)
      new_projectile.global_position = global_position
      new_projectile.global_rotation = global_rotation
      new_projectile.propel()
