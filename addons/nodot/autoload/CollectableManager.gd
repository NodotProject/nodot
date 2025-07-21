extends Node

var inventories: Dictionary[String, CollectableInventory] = {}
var collectables: Dictionary[String, Collectable] = {}

func get_info(display_name: String) -> Collectable:
	if display_name != "" and display_name in collectables:
		return collectables.get(display_name)
	return null
	
func add(collectable: Collectable):
	collectables.set(collectable.display_name, collectable)

func total_item_count(display_name: String) -> int:
	var sum: int = 0
	for key in inventories.keys():
		var inventory: CollectableInventory = inventories[key]
		sum += inventory.get_collectable_count(display_name)
	return sum
