@tool
extends EditorPlugin

@export var version = 0.1

func _init():
	var is_editor: bool = Engine.is_editor_hint()
	if is_editor:
		add_autoload_singleton("VideoManager", "res://addons/nodot/autoload/VideoManager.gd")
		add_autoload_singleton("AudioManager", "res://addons/nodot/autoload/AudioManager.gd")
		add_autoload_singleton("SaveManager", "res://addons/nodot/autoload/SaveManager.gd")
		add_autoload_singleton("GlobalSignal", "res://addons/nodot/autoload/GlobalSignal.gd")
		add_autoload_singleton("GlobalStorage", "res://addons/nodot/autoload/GlobalStorage.gd")
		add_autoload_singleton("PlayerManager", "res://addons/nodot/autoload/PlayerManager.gd")
		add_autoload_singleton("CollectableManager", "res://addons/nodot/autoload/CollectableManager.gd")
		add_autoload_singleton("InputManager", "res://addons/nodot/autoload/InputManager.gd")
		add_autoload_singleton("NetworkManager", "res://addons/nodot/autoload/NetworkManager.gd")
		add_autoload_singleton("DebugManager", "res://addons/nodot/autoload/DebugManager.gd")
