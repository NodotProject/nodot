## A unique set of variables
class_name UniqueSet extends Node

@export var items: Array[Variant] = []:
	set = _set_items
@export var current_index: int = 0

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal items_updated


func _set_items(value: Array[Variant]):
	items = value
	items_updated.emit()


func add(item: Variant):
	if !items.has(item):
		items.append(item)
		item_added.emit(item)
		items_updated.emit()


func remove(item: Variant):
	if items.has(item):
		items.erase(item)
		item_removed.emit(item)
		items_updated.emit()

func has(item: Variant):
	return items.has(item)

func get_next_item() -> Variant:
	if current_index == items.size() - 1:
		current_index = 0
		return items[0]
	current_index += 1
	return items[current_index]

func get_size() -> int:
	return items.size()
