@icon("../icons/menu_manager.svg")
class_name MenuManager extends Nodot2D

## Contains MenuContainer nodes and can be used to show, hide or transition between them as needed

signal menu_changed ## Triggered when the active menu index changes

var active_menu := "" ## The active menu node name (empty string if none active)
var active_menu_index := -1 ## The active menu node index (-1 if none active)

## Hide all menus
func hide_all():
  for child in get_children(): child.hide()
  active_menu = ""
  active_menu_index = -1

## Change the active menu using the name of the node
func change_to(menu_name: String):
  hide_all()
  var menu_node = get_node(menu_name)
  menu_node.show()
  active_menu = menu_name
  active_menu_index = menu_node.get_index()
  emit_signal("menu_changed", active_menu_index)
  
## Change the active menu using the index
func change_to_index(menu_index: int):
  hide_all()
  var menu_node = get_child(menu_index)
  menu_node.show()
  active_menu_index = menu_index
  active_menu = menu_node.name
  emit_signal("menu_changed", active_menu_index)
