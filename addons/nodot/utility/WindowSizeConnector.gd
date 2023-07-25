## Allows you to update node size to the window size
class_name WindowSizeConnector extends Nodot

## The nodes to apply the new size to
@export var target_nodes: Array[Node] = []
## The percentage of the window size to fill (1.0 for full size)
@export var size_multiplier: float = 1.0

signal window_size_updated(new_size: Vector2)

var is_editor: bool = Engine.is_editor_hint()

func _ready() -> void:
	if is_editor or !is_instance_valid(VideoManager): return
	VideoManager.connect("window_resized", _on_window_resized)
	VideoManager.bump()
	
func _on_window_resized(new_size: Vector2) -> void:
	for node in target_nodes:
		if "size" in node:
			node.size = new_size * size_multiplier
	emit_signal("window_size_updated", new_size)
