extends Node

var inventories: Dictionary[String, CollectableInventory] = {}
var collectables: Dictionary[String, Collectable] = {}

func get_info(display_name: String) -> Collectable:
	if display_name != "" and display_name in collectables:
		return collectables.get(display_name)
	return null
	
