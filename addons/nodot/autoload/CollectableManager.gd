extends Node

var collectables: Dictionary = {}

signal collectable_added(collectable: Collectable)

func add(collectable_node: Node):
	if collectable_node.display_name in collectables:
		return
	collectables[collectable_node.display_name] = Collectable.new(collectable_node)
	emit_signal("collectable_added", collectable_node)

func get_info(display_name: String) -> Collectable:
	if display_name != "" and display_name in collectables:
		return collectables[display_name]
	return null
	
func clear() -> void:
	collectables = {}
	


class Collectable:
	
	## The icon of the collectable.
	var icon: Texture2D
	## The collectables name.
	var display_name: String = "Item"
	## The collectables description.
	var description: String = "A collectable item."
	## Maximum stack count
	var stack_limit: int = 1
	## The weight of the collectable.
	var mass: float = 0.1
	## The item node to spawn the item into the world
	var node: Node

	func _init(collectable_node: Node):
		if collectable_node.actual_collectable_root_node:
			node = collectable_node.actual_collectable_root_node.duplicate(15)
		else:
			node = collectable_node.duplicate(15)
		node.position = Vector3.ZERO
		
		icon = collectable_node.icon
		display_name = collectable_node.display_name
		description = collectable_node.description
		stack_limit = collectable_node.stack_limit
		mass = collectable_node.mass
		
