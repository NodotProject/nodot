extends Node

signal window_resized

func _ready():
  var screen_size = DisplayServer.screen_get_size() / 2
  var viewport_size = get_viewport().size / 2
  DisplayServer.window_set_position(Vector2i(screen_size.x - viewport_size.x, screen_size.y - viewport_size.y))
  
  get_tree().root.connect("size_changed", _on_window_resized)
  _on_window_resized()

func _on_window_resized():
  var new_size = get_viewport().size
  emit_signal("window_resized", new_size)

func bump():
  _on_window_resized()
