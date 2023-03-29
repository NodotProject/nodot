@icon("../icons/menu_container.svg")
class_name MenuContainer extends Nodot2D

signal showing ## Fired when the menu is going to show
signal hiding ## Fired when the menu is going to hide

@export var custom_transition : bool = false ## Used to override the simple visibility transition with a custom one

func show() -> void:
  emit_signal("showing")
  if !custom_transition:
    set_visible(true)

func hide() -> void:
  emit_signal("hiding")
  if !custom_transition:
    set_visible(false)
