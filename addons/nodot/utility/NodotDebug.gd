class_name NodotDebug extends Nodot

@export var enabled: bool = true
@export var target_node: Node
@export var custom_watch_fields: Array[String] = []

func _ready():
	if !enabled: return
	DebugManager.register(self)

func _exit_tree():
	DebugManager.unregister(self)
