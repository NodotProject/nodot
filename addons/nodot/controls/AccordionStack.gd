class_name AccordionStack extends Control

var accordions: Array[Node] = []

func _ready():
	accordions = Nodot.get_children_of_type(self, Accordion)
	var last_child_height = global_position.y
	for child in accordions:
		child.connect("expand_started", action)
		child.global_position = Vector2(child.global_position.x, last_child_height)
		var child_height = child.show_button.get_rect().size.y
		last_child_height += child_height
		
func _process(delta):
	var last_child_height = global_position.y
	for child in accordions:
		child.global_position = Vector2(child.global_position.x, last_child_height)
		var child_height = child.get_rect().size.y
		last_child_height += child_height

func action(node: Accordion):
	for accordion in accordions:
		if accordion != node:
			accordion.collapse()
