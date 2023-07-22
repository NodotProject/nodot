## A node that manages the pause state of the tree
class_name Pause extends Nodot

@export var pause: bool = false: set = _set_pause

signal pause_changed(new_value: bool)

func _set_pause(new_pause: bool):
	if pause == new_pause:
		return
		
	pause = new_pause
	get_tree().paused = pause
	emit_signal("pause_changed", pause)

## Set the pause state of the tree
func set_pause(new_pause: bool):
	_set_pause(new_pause)

## Activate pause
func activate():
	set_pause(true)

## Unpause
func deactivate():
	set_pause(false)

## Toggle pause
func toggle():
	set_pause(!pause)
