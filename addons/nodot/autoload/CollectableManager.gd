class_name CollectableManager

var collectables: Dictionary = {}

add(collectable_node: Node):
	if collectable_node.display_name in collectables:
		return
	collectables[collectable_node.display_name] = Collectable.new(collectable_node)

get(display_name: String) -> Collectable:
	if display_name in collectables:
		return collectables[display_name]
	return null
	


class Collectable
	
	## The icon of the collectable.
	var icon: Texture2D
	## The collectables name.
	var display_name: String = "Item"
	## The collectables description.
	var description: String = "A collectable item."
	## Maximum stack count
	var stack_limit: int = 1
	## The weight of the collectable.
	var weight: float = 0.1

	func _init(collectable_node: Node):
		icon = collectable_node.icon
		display_name = collectable_node.display_name
		description = collectable_node.description
		stack_limit = collectable_node.stack_limit
		weight = collectable_node.weight