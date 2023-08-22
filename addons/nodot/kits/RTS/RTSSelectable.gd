## A node that enables selection by an RTSMouseInput node.
class_name RTSSelectable extends Node

## The node that will be selected when this node is selected.
@export var target: Node

## Emitted when this node is selected.
signal selected
## Emitted when this node is deselected.
signal deselected
## Emitted when this node has an action request.
signal actioned(collision: Dictionary)

func _ready():
	if !target:
		target = get_parent()
	
	target.add_to_group("rts_selectable")

## Selects this node.
func select():
	emit_signal("selected")

## Deselects this node.
func deselect():
	emit_signal("deselected")

## Requests an action on this node.
func action(collision: Dictionary):
	emit_signal("actioned", collision)
