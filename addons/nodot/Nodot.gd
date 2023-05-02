@icon("icons/nodot.svg")
## Nodot base node
class_name Nodot extends Node


## Returns all children of a given type
static func get_children_of_type(parent: Node, type: Variant):
	var found_children = []
	for child in parent.get_children():
		if is_instance_of(child, type):
			found_children.append(child)
	return found_children


## Returns the first child of the given type
static func get_first_child_of_type(parent: Node, type: Variant):
	var children = get_children_of_type(parent, type)
	if children.size() > 0:
		return children[0]
