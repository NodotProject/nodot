class_name RTSSelectable extends Node

@export var target: Node

signal selected
signal deselected
signal actioned(collision: Dictionary)

func _ready():
	if !target:
		target = get_parent()
	
	target.add_to_group("rts_selectable")

func select():
	emit_signal("selected")
	
func deselect():
	emit_signal("deselected")

func action(collision: Dictionary):
	emit_signal("actioned", collision)
