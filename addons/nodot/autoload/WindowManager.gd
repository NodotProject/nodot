## Easily manage window events
extends Node

## Triggered when the window is resized
signal window_resized


func _ready() -> void:
	get_tree().root.connect("size_changed", _on_window_resized)
	_on_window_resized()


func _on_window_resized() -> void:
	var new_size: Vector2 = get_viewport().size
	emit_signal("window_resized", new_size)


## Forces WindowManager to redeclare the window size
func bump() -> void:
	_on_window_resized()
