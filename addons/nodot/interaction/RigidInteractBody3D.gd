## RigidBody3D that fires a signal on interaction
class_name RigidInteractBody3D extends NodotRigidBody3D

## Whether to enable the interaction logic
@export var enabled: bool = true
## The label to show
@export var label_text: String = ""

## Triggered when the node is interacted with by a player
signal interacted


func interact() -> void:
	interacted.emit()


func label() -> String:
	return label_text
