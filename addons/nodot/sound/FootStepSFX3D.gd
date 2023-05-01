@tool
## A raycast to detect the floor material and play appropriate footstep sounds.
class_name FootStepSFX extends RayCast3D

## How many steps per 1m
@export var frequency: float = 2.0

@onready var parent: CharacterBody3D = get_parent()

var distance_traveled: float = 0.0
var last_position: Vector3 = Vector3.ZERO


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")

	if !Nodot.get_first_child_of_type(self, SFXPlayer3D):
		warnings.append("Should contain at least one SFXPlayer3D")
	return warnings


func _physics_process(delta: float) -> void:
	if parent:
		var total_velocity = parent.position.distance_to(last_position)
		last_position = parent.position
		distance_traveled += total_velocity
		if (
			distance_traveled > frequency
			and parent.is_on_floor()
			and parent.velocity != Vector3.ZERO
			and parent.get_slide_collision_count() > 0
		):
			var collider = parent.get_slide_collision(0).get_collider()
			var material = NodePath(get_child(0).name)
			if collider.has_meta("floor_material"):
				material = NodePath(collider.get_meta("floor_material"))
			if has_node(material):
				distance_traveled = 0.0
				get_node(material).action()
