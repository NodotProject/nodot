## A unique set of variables
class_name UniqueSet extends Node

@export var items: Array[Variant] = []
@export var current_index: int = 0

func add(item: Variant):
	if !items.has(item):
		items.append(item)
		
func get_next_item() -> Variant:
	if current_index == items.size() - 1:
		current_index = 0
		return items[0]
	current_index += 1
	return items[current_index]
