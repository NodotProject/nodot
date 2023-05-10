@tool
extends EditorPlugin

@export var version = 0.1


func _init():
	var is_editor: bool = Engine.is_editor_hint()
	if is_editor:
		add_autoload_singleton("WindowManager", "res://addons/nodot/autoload/WindowManager.gd")
		add_autoload_singleton("SaveManager", "res://addons/nodot/autoload/SaveManager.gd")
		add_autoload_singleton("GlobalSignal", "res://addons/nodot/autoload/GlobalSignal.gd")
