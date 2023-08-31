@tool
## A Node to move other nodes from one place to another (any maybe even back again)
class_name Mover3D extends Nodot3D

## Destination position/rotation has been reached
signal destination_reached
## Original position/rotation has been reached
signal origin_reached
## Started moving towards the destination
signal moving_to_destination
## Started moving towards the origin
signal moving_to_origin
## Movement towards any target position/rotation has started
signal movement_started
## Movement towards any target position/rotation has completed
signal movement_ended

## The node to move
@export var target_node: Node
## Automatically start movement
@export var auto_start: bool = false
## The destination position
@export var destination_position: Vector3
## The destination rotation
@export var destination_rotation: Vector3
## Consider the destination position as relative from the current position
@export var relative_destination_position: bool = false
## Time until destination
@export var time_to_destination: float = 1.0
## Time until origin
@export var time_to_origin: float = 1.0
## Transition type (https://docs.godotengine.org/en/4.0/classes/class_tween.html)
@export_enum(
	"TRANS_LINEAR",
	"TRANS_SINE",
	"TRANS_QUINT",
	"TRANS_QUART",
	"TRANS_QUAD",
	"TRANS_EXPO",
	"TRANS_ELASTIC",
	"TRANS_CUBIC",
	"TRANS_CIRC",
	"TRANS_BOUNCE",
	"TRANS_BACK"
)
var transition_type: int = 0

var original_position: Vector3
var original_rotation: Vector3
var activated: bool = false


func _ready():
	if target_node:
		original_position = target_node.global_position
		original_rotation = target_node.rotation

	if auto_start:
		action()


## Perform the move toggling between destination and origin
func action():
	activated = !activated
	if activated:
		move_to_destination()
	else:
		move_to_origin()


## Perform the move but only towards the destination
func activate():
	move_to_destination()


## Perform the move but only towards the origin
func deactivate():
	move_to_origin()


func move_to_destination():
	var final_destination_position = destination_position
	original_position = target_node.global_position
	if relative_destination_position:
		final_destination_position = original_position + destination_position

	if final_destination_position == global_position:
		return

	activated = true
	var destination_tween = _create_tween(_on_destination_reached)
	var destination_rotation_radians = Vector3(
		deg_to_rad(destination_rotation.x),
		deg_to_rad(destination_rotation.y),
		deg_to_rad(destination_rotation.z)
	)
	if final_destination_position:
		(
			destination_tween
			. parallel()
			. tween_property(
				target_node, "global_position", final_destination_position, time_to_destination
			)
			. set_trans(transition_type)
		)
	(
		destination_tween
		. parallel()
		. tween_property(target_node, "rotation", destination_rotation_radians, time_to_destination)
		. set_trans(transition_type)
	)
	destination_tween.play()
	emit_signal("moving_to_destination")
	emit_signal("movement_started")


func move_to_origin():
	if global_position == original_position:
		return

	activated = false
	var origin_tween = _create_tween(_on_origin_reached)
	if original_position:
		(
			origin_tween
			. parallel()
			. tween_property(target_node, "global_position", original_position, time_to_origin)
			. set_trans(transition_type)
		)
	(
		origin_tween
		. parallel()
		. tween_property(target_node, "rotation", original_rotation, time_to_origin)
		. set_trans(transition_type)
	)
	origin_tween.play()
	emit_signal("moving_to_origin")
	emit_signal("movement_started")
	
func reset() -> void:
	target_node.global_position = original_position
	target_node.rotation = original_rotation


func _create_tween(callback: Callable) -> Tween:
	var tween = get_tree().create_tween()
	tween.connect("finished", callback)
	return tween


func _on_destination_reached():
	emit_signal("destination_reached")
	emit_signal("movement_ended")


func _on_origin_reached():
	emit_signal("origin_reached")
	emit_signal("movement_ended")
