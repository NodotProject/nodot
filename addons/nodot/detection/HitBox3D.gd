@tool
class_name HitBox3D extends MeshInstance3D

## How much to multiply the damage for this hitbox
@export var damage_multiplier: float = 1.0
## The debug color
@export var color: Color = Color.RED: set = _set_color

var aabb: AABB
var is_editor: bool = Engine.is_editor_hint()
var material: StandardMaterial3D = StandardMaterial3D.new()

func _enter_tree() -> void:
	# Set a StandardMaterial3D with a transparent color of 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.albedo_color.a = 0.5
	material_override = material

func _set_color(new_color: Color) -> void:
	color = new_color
	material.albedo_color = color
	material.albedo_color.a = 0.5 # Preserve transparency

func _ready() -> void:
	if is_editor: return
	visible = false

func is_point_inside(point: Vector3) -> bool:
	return get_aabb().has_point(to_local(point))
