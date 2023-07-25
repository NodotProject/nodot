@icon("../icons/menu_manager.svg")
## Contains MenuContainer nodes and can be used to show, hide or transition between them as needed
class_name MenuManager extends Nodot2D

## The active menu node name (empty string if none active)
@export var active_menu: String = ""

## Triggered when the active menu index changes
signal menu_changed

var active_menu_index: int = -1  ## The active menu node index (-1 if none active)
var previous_menu: String = active_menu

func _ready():
	if active_menu == "":
		hide_all()
	else:
		change_to(active_menu)

## Hide all menus
func hide_all() -> void:
	for child in get_children():
		child._hide()
	active_menu = ""
	active_menu_index = -1


## Change the active menu using the name of the node
func change_to(menu_name: String) -> void:
	previous_menu = active_menu
	hide_all()
	var menu_node: MenuContainer = get_node(menu_name)
	if !is_instance_valid(menu_node):
		return
		
	menu_node._show()
	active_menu = menu_name
	active_menu_index = menu_node.get_index()
	emit_signal("menu_changed", active_menu_index)


## Change the active menu using the index
func change_to_index(menu_index: int) -> void:
	hide_all()
	var menu_node: MenuContainer = get_child(menu_index)
	menu_node._show()
	active_menu_index = menu_index
	previous_menu = active_menu
	active_menu = menu_node.name
	emit_signal("menu_changed", active_menu_index)

## Go back to the previous menu
func go_back():
	change_to(previous_menu)
