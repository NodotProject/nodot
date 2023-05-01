@icon("../icons/menu_container.svg")
## A container for menus
class_name MenuContainer extends Nodot2D

## Fired when the menu is going to show
signal showing
## Fired when the menu is going to hide
signal hiding

@export var custom_transition: bool = false  ## Used to override the simple visibility transition with a custom one


func show() -> void:
	emit_signal("showing")
	if !custom_transition:
		set_visible(true)


func hide() -> void:
	emit_signal("hiding")
	if !custom_transition:
		set_visible(false)
