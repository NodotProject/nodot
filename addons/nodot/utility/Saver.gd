@icon("../icons/saver.svg")
## Connects with the SaveManager to save field data for the parent node
class_name Saver extends Node

## Which fields to save
@export var fields: Array[String] = []

signal saved
signal loaded

@onready var parent = get_parent()

func _enter_tree():
	SaveManager.register_saver(self)

func _exit_tree():
	SaveManager.unregister_saver(self)

func save() -> Dictionary:
	var saved_items: Dictionary = {}
	var serialized_fields: Array = []
	
	# Check if parent has _saver_serialize method and execute it
	if parent.has_method("_saver_serialize"):
		var serialized_data = parent._saver_serialize()
		if serialized_data is Dictionary:
			saved_items.set("_saved_serialized_data", serialized_data)
			serialized_fields = serialized_data.keys()
	
	# Process remaining fields, ignoring those already serialized
	for field in fields:
		if field not in serialized_fields and field in parent:
			saved_items[field] = parent[field]
	
	saved.emit()
	return saved_items

func load(saved_data: Dictionary):
	for key in saved_data:
		if key in parent:
			parent[key] = saved_data[key]
	if parent.has_method("_saver_deserialize"):
		if saved_data.get("_saved_serialized_data"):
			parent._saver_deserialize(saved_data.get("_saved_serialized_data"))
	loaded.emit()
