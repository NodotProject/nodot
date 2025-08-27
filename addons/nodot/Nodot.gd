@icon("icons/nodot.svg")
## Nodot base node
class_name Nodot extends Node


## Returns all children of a given type
static func get_children_of_type(parent: Node, type: Variant) -> Array[Node]:
	if !parent: return []
	var found_children: Array[Node] = []
	for child in parent.get_children():
		if is_instance_of(child, type):
			found_children.append(child)
	return found_children


## Returns the first child of the given type
static func get_first_child_of_type(parent: Node, type: Variant) -> Node:
	var children = get_children_of_type(parent, type)
	if children.size() > 0:
		return children[0]
	return null

## Find the first parent of a specific type
static func get_first_parent_of_type(node: Node, type: Variant) -> Node:
	var current_node = node
	while current_node != null:
		if is_instance_of(current_node, type):
			return current_node
		current_node = current_node.get_parent()
	return null

## Find all siblings of a specific type
static func get_siblings_of_type(node: Node, type: Variant) -> Array[Node]:
	var parent = node.get_parent()
	var siblings: Array[Node] = []
	for sibling in parent.get_children():
		if sibling != node and is_instance_of(sibling, type):
			siblings.append(sibling)
	return siblings

## Find the first sibling of a specific type
static func get_first_sibling_of_type(node: Node, type: Variant) -> Node:
	var parent = node.get_parent()
	for sibling in parent.get_children():
		if sibling != node and is_instance_of(sibling, type):
			return sibling
	return null

## Clears all children of a node
static func free_all_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()

## Toggle between visible and invisible
static func toggle(parent: Node) -> void:
	parent.visible = !parent.visible
