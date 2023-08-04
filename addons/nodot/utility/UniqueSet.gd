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
	emit_signal("items_updated")


func add(item: Variant):
	if !items.has(item):
		items.append(item)
		emit_signal("item_added", item)
		emit_signal("items_updated")


func remove(item: Variant):
	if items.has(item):
		items.erase(item)
		emit_signal("item_removed", item)
		emit_signal("items_updated")


func get_next_item() -> Variant:
	if current_index == items.size() - 1:
		current_index = 0
		return items[0]
	current_index += 1
	return items[current_index]
