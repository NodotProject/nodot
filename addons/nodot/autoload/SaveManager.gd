## Manages saving game data to the file system
extends Node

## Triggered on a successful file save
signal saved
## Triggered on a successful file load
signal loaded

var savers: Array[Saver] = []
var custom_values: Dictionary = {}

## Used for global options and game settings
var config: Storage = Storage.new()

func _init():
	load_config()

## Register a saver node
func register_saver(saver_node: Saver):
	if !savers.has(saver_node):
		savers.append(saver_node)


## Unregister a saver node
func unregister_saver(saver_node: Saver):
	var index = savers.find(saver_node)
	savers.remove_at(index)


## Saves the data in the current scene
func save(slot: int = 0) -> void:
	var file_path = "user://save%s.sav" % slot
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var save_data: Dictionary = {"_custom_values": custom_values}

	for saver in savers:
		var saver_data = saver.save()
		save_data[get_special_id(saver)] = saver_data

	file.store_var(save_data)
	file.close()
	emit_signal("saved")


## Loads a save file and applies it to the nodes in the current scene
func load(slot: int = 0, reload_scene: bool = false) -> void:
	if reload_scene:
		get_tree().reload_current_scene()
		await get_tree().process_frame

	var file_path = "user://save%s.sav" % slot
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ)
		var save_data = file.get_var(true)
		custom_values = save_data._custom_values

		for saver_id in save_data:
			for saver in savers:
				if get_special_id(saver) == saver_id:
					saver.load(save_data[saver_id])
		file.close()
		emit_signal("loaded")


## Generate a unique ID for the save component
func get_special_id(input_node: Node):
	var id_raw = "%s_%s" % [input_node.get_path(), input_node.name]
	return id_raw.sha256_text()


## Set a custom value to be stored in the save file
func set_value(key: String, value: Variant):
	custom_values[key] = value
	
## Resets the save data to default
func reset():
	savers = []
	custom_values = {}
	load_config()

## Save the configuration file
func save_config():
	var file_path = "user://config.bin"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_var(config.data, true)
	file.close()
	
## Load the configuration file
func load_config() -> void:
	var file_path = "user://config.bin"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var new_config = file.get_var(true)
		if new_config:
			config.data = new_config
		file.close()
