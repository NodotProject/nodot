@icon("../icons/menu_container.svg")
## A container for menus
class_name MenuContainer extends Nodot2D

## Change visibility using a custom transition
@export var custom_transition: bool = false ## Used to override the simple visibility transition with a custom one
## Selectable Menu Items
@export var selectable_items: Array[Node]

## Fired when the menu is going to show
signal showing
## Fired when the menu is going to hide
signal hiding

func _show() -> void:
	showing.emit()
	if !custom_transition:
		set_visible(true)
	if selectable_items.size() == 0: return
	selectable_items[0].grab_focus()

func _hide() -> void:
	hiding.emit()
	if !custom_transition:
		set_visible(false)
