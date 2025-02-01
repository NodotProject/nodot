## A Node to move other nodes from one place to another (any maybe even back again)
class_name Mover3D extends Node3D

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
@export var target_node: Node3D
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
## Ease Type
@export var ease_type: Tween.EaseType = Tween.EASE_IN
## Transition type
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR

@export_category("Looping")
## Enable looping
@export var loop: bool = false
## Reverse at destination
@export var reverse_at_destination: bool = false

var original_position: Vector3 = Vector3.ZERO
var original_rotation: Vector3 = Vector3.ZERO
var activated: bool = false
var destination_tween: Tween
var origin_tween: Tween

func _ready():
	if target_node:
		original_position = target_node.position
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
	if relative_destination_position:
		final_destination_position = original_position + destination_position

	if final_destination_position and final_destination_position == target_node.position:
		return

	activated = true
	destination_tween = _create_tween(_on_destination_reached)
	if final_destination_position:
		(
			destination_tween
			.parallel()
			.tween_property(
				target_node, "position", final_destination_position, time_to_destination
			)
			.set_trans(transition_type)
			.set_ease(ease_type)
		)
	(
		destination_tween
		.parallel()
		.tween_property(target_node, "rotation", destination_rotation, time_to_destination)
		.set_trans(transition_type)
		.set_ease(ease_type)
	)
	destination_tween.play()
	moving_to_destination.emit()
	movement_started.emit()


func move_to_origin():
	if target_node.position == original_position:
		return

	activated = false
	origin_tween = _create_tween(_on_origin_reached)
	if original_position:
		(
			origin_tween
			.parallel()
			.tween_property(target_node, "position", original_position, time_to_origin)
			.set_trans(transition_type)
			.set_ease(ease_type)
		)
	(
		origin_tween
		.parallel()
		.tween_property(target_node, "rotation", original_rotation, time_to_origin)
		.set_trans(transition_type)
		.set_ease(ease_type)
	)
	origin_tween.play()
	moving_to_origin.emit()
	movement_started.emit()
	
func reset() -> void:
	if destination_tween:
		destination_tween.stop()
	if origin_tween:
		origin_tween.stop()
	target_node.position = original_position
	target_node.rotation = original_rotation

func pause() -> void:
	if destination_tween:
		destination_tween.pause()
	if origin_tween:
		origin_tween.pause()

func _create_tween(callback: Callable) -> Tween:
	var tween = get_tree().create_tween()
	tween.connect("finished", callback)
	return tween


func _on_destination_reached():
	destination_reached.emit()
	movement_ended.emit()
	if loop:
		if reverse_at_destination:
			move_to_origin()
		else:
			reset()
			move_to_destination()


func _on_origin_reached():
	origin_reached.emit()
	movement_ended.emit()
	if loop:
		move_to_destination()
