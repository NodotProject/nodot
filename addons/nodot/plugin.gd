@tool
extends EditorPlugin

@export var version = 0.3

func _enter_tree():
	add_autoload_singleton("VideoManager", "res://addons/nodot/autoload/VideoManager.gd")
	add_autoload_singleton("AudioManager", "res://addons/nodot/autoload/AudioManager.gd")
	add_autoload_singleton("SaveManager", "res://addons/nodot/autoload/SaveManager.gd")
	add_autoload_singleton("GlobalSignal", "res://addons/nodot/autoload/GlobalSignal.gd")
	add_autoload_singleton("GlobalStorage", "res://addons/nodot/autoload/GlobalStorage.gd")
	add_autoload_singleton("PlayerManager", "res://addons/nodot/autoload/PlayerManager.gd")
	add_autoload_singleton("CollectableManager", "res://addons/nodot/autoload/CollectableManager.gd")
	add_autoload_singleton("InputManager", "res://addons/nodot/autoload/InputManager.gd")
	add_autoload_singleton("NetworkManager", "res://addons/nodot/autoload/NetworkManager.gd")
		
func _exit_tree():
	remove_autoload_singleton("VideoManager")
	remove_autoload_singleton("AudioManager")
	remove_autoload_singleton("SaveManager")
	remove_autoload_singleton("GlobalSignal")
	remove_autoload_singleton("GlobalStorage")
	remove_autoload_singleton("PlayerManager")
	remove_autoload_singleton("CollectableManager")
	remove_autoload_singleton("InputManager")
	remove_autoload_singleton("NetworkManager")
