## Stack accordions vertically
class_name AccordionStack extends Control

var accordions: Array[Node] = []
var last_child_height = global_position.y

func _ready():
	connect("child_entered_tree", _child_entered_tree)
	last_child_height = global_position.y
	accordions = Nodot.get_children_of_type(self, Accordion)
	for child in accordions:
		add_accordion(child)
		
func _process(delta):
	var last_child_height = global_position.y
	for child in accordions:
		child.global_position = Vector2(child.global_position.x, last_child_height)
		var child_height = child.get_global_rect().size.y
		last_child_height += child_height

func _child_entered_tree(child: Node):
	if child is Accordion:
		add_accordion(child)
		
func add_accordion(child: Accordion):
	if accordions.has(child): return
	
	child.connect("expand_started", action)
	child.global_position = Vector2(child.global_position.x, last_child_height)
	var child_height = child.show_button.get_rect().size.y
	last_child_height += child_height
	accordions.append(child)	
		
## Close all accordions except for the one passed as an argument
func action(node: Accordion):
	for accordion in accordions:
		if accordion != node:
			accordion.collapse()
