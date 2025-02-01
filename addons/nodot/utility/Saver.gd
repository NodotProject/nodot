@icon("../icons/saver.svg")
## Connects with the SaveManager to save field data for the parent node
class_name Saver extends Node

## Which fields to save
@export var fields: Array[String] = []

@onready var parent = get_parent()


func _enter_tree():
	SaveManager.register_saver(self)


func _exit_tree():
	SaveManager.unregister_saver(self)


func save() -> Dictionary:
	var saved_items: Dictionary = {}
	for field in fields:
		if field in parent:
			saved_items[field] = parent[field]
	return saved_items


func load(saved_data: Dictionary):
	for key in saved_data:
		if key in parent:
			parent[key] = saved_data[key]
