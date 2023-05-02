@tool
## A raycast powered tool to detect when the player is trying to move up some steps and will elevate the player
class_name StepUp3D extends Nodot3D

## Maximum height limit of the steps before the character will no longer walk up them
@export var max_step_height: float = 0.5

@onready var parent = get_parent()

var feet_raycast: RayCast3D
var knee_raycast: RayCast3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	var child_raycast = Nodot.get_first_child_of_type(self, RayCast3D)
	if !child_raycast:
		(
			warnings
			. append(
				"Should have a RayCast3D node as a child (on the soles of the feet of the character but above the floor)"
			)
		)

	if not get_parent() is CharacterBody3D:
		warnings.append("The parent should be a CharacterBody3D")

	return warnings


func _enter_tree():
	feet_raycast = Nodot.get_first_child_of_type(self, RayCast3D)

	var raycast3d = RayCast3D.new()
	raycast3d.target_position = feet_raycast.target_position
	raycast3d.position = feet_raycast.position
	raycast3d.position.y += max_step_height

	knee_raycast = raycast3d
	add_child(raycast3d)


func _physics_process(_delta):
	if feet_raycast and knee_raycast:
		var feet_colliding = is_colliding_with_static_body(feet_raycast)
		var knee_colliding = is_colliding_with_static_body(knee_raycast)
		if (
			feet_colliding
			and !knee_colliding
			and parent.is_on_floor()
			and parent.velocity != Vector3.ZERO
		):
			parent.velocity.y = max_step_height * 5


## Check if a raycast is colliding with a static body
func is_colliding_with_static_body(rc: RayCast3D):
	var collider = rc.get_collider()
	if collider is StaticBody3D:
		return true
	return false


## Rounds a number to 3 decimal places
func round_to_dec(num):
	return round(num * pow(10.0, 2)) / pow(10.0, 2)
