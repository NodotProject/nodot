## A collectable RigidBody3D that can be placed in inventories.
class_name RigidCollectable3D extends NodotRigidBody3D

## Enable the item for collection
@export var enabled: bool = true
## The collectables icon.
@export var icon: Texture2D
## The collectables name.
@export var display_name: String = "Item"
## The collectables description.
@export_multiline var description: String = "A collectable item."
## The quantity of the collectable.
@export var quantity: int = 1
## Maximum stack count
@export var stack_limit: int = 1
## The interactive label
@export var label_text: String = "Take %s"
## Allow the item to be collected by colliding with it.
@export var collect_on_collision: bool = true
## Don't trigger collect logic on the player
@export var disable_player_collect: bool = false

## Triggered on collection
signal collected

func _enter_tree():
	CollectableManager.add(self)
	if collect_on_collision:
		connect("character_collided", interact)

func interact(player_node: CharacterBody3D = PlayerManager.node) -> void:
	if enabled:
		if !disable_player_collect:
			if player_node.has_method("collect"):
				if player_node.collect(self):
					enabled = false
					emit_signal("collected")
					queue_free()

func label() -> String:
	return label_text % display_name
