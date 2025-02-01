## A node that manages the pause state of the tree
class_name Pause extends Node

@export var pause: bool = false: set = _set_pause
@export var release_mouse_on_pause: bool = false

signal pause_changed(new_value: bool)

var saved_mouse_mode

func _set_pause(new_pause: bool):
	if pause == new_pause:
		return
	
	if release_mouse_on_pause:
		if pause:
			Input.mouse_mode = saved_mouse_mode
		else:
			saved_mouse_mode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	pause = new_pause
	get_tree().paused = pause
	pause_changed.emit(pause)

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
