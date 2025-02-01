## A set that only allows unique items to be added
class_name UniqueSet extends Node

@export var items: Array[Variant] = []:
	set = _set_items
@export var current_index: int = 0

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal items_updated

## Sets the items array and emits items_updated signal
func _set_items(value: Array[Variant]):
	items = value
	items_updated.emit()

## Adds an item to the set if it doesn't already exist
func add(item: Variant):
	if !items.has(item):
		items.append(item)
		item_added.emit(item)
		items_updated.emit()

## Removes an item from the set if it exists
func remove(item: Variant):
	if items.has(item):
		items.erase(item)
		item_removed.emit(item)
		items_updated.emit()

## Checks if an item exists in the set
func has(item: Variant):
	return items.has(item)

## Gets the next item in the set, wrapping around to start when reaching end
func get_next_item() -> Variant:
	var item = items[current_index]
	if current_index == items.size() - 1:
		current_index = 0
	else:
		current_index += 1
	return item

## Gets the number of items in the set
func get_size() -> int:
	return items.size()
