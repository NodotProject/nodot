@tool
## Launches an object or objects at the specified rotation
class_name ProjectileEmitter3D extends Nodot3D

## Whether to enable the projectile emitter or not
@export var enabled: bool = true
## The accuracy of the emission (0.0 = emit with 100% accuracy, 50.0 = emit in any forward direction, 100.0 = emit in any direction)
@export var accuracy: float = 0.0

signal projectile_spawned(projectile: Projectile3D)
signal projectile_destroyed(position: Vector3, rotation: Vector3)

@onready var initial_rotation = rotation

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var projectiles: Array[Projectile3D] = []
var is_editor: bool = Engine.is_editor_hint()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !Nodot.get_first_child_of_type(self, Projectile3D):
		warnings.append("Should have a Projectile3D as a child")
	return warnings


func _enter_tree() -> void:
	if is_editor: return
	var projectile_nodes = Nodot.get_children_of_type(self, Projectile3D)
	for item in projectile_nodes:
		projectiles.append(item)
		remove_child(item)


## Apply the accuracy to the emitter
func aim_emitter() -> void:
	if enabled or accuracy <= 0.0: return
	var accuracy_radians: float = accuracy * PI / 100
	var new_x: float = rng.randf_range(-accuracy_radians, accuracy_radians)
	var new_y: float = rng.randf_range(-accuracy_radians, accuracy_radians)
	var new_z: float = rng.randf_range(-accuracy_radians, accuracy_radians)
	rotation = initial_rotation + Vector3(new_x, new_y, new_z)


## Execute the emitter
func action() -> void:
	if !enabled: return
	for projectile in projectiles:
		if accuracy > 0.0:
			aim_emitter()
		var new_projectile: Projectile3D = projectile.duplicate(15)
		get_tree().root.add_child(new_projectile)
		new_projectile.connect("destroyed", _on_projectile_destroyed)
		emit_signal("projectile_spawned", new_projectile)
		new_projectile.global_position = global_position
		new_projectile.global_rotation = global_rotation
		new_projectile.propel()
		
## Triggered when a projectile is destroyed
func _on_projectile_destroyed(position: Vector3, rotation: Vector3):
	emit_signal("projectile_destroyed", position, rotation)
