extends Node

signal window_resized

func _ready():
  get_tree().root.connect("size_changed", _on_window_resized)
  _on_window_resized()

func _on_window_resized():
  var new_size = get_viewport().size
  emit_signal("window_resized", new_size)

func bump():
  _on_window_resized()
