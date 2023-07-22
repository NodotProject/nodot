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
## Collectable root node. Used to respawn an item into the world
@export var collectable_root_node: NodePath
## Time before the object is freed
@export var free_delay: float = 0.0

var actual_collectable_root_node: Node

## Triggered on collection
signal collected

func _enter_tree():
	if collectable_root_node:
		actual_collectable_root_node = get_node(collectable_root_node)
		
	CollectableManager.add(self)
	if collect_on_collision:
		connect("character_collided", interact)

func interact(player_node: CharacterBody3D = PlayerManager.node) -> void:
	if !enabled or disable_player_collect or !player_node.has_method("collect") or !player_node.collect(self):
		return
	
	enabled = false
	visible = false
	emit_signal("collected")
	
	if free_delay > 0.0:
		await get_tree().create_timer(free_delay, false).timeout
		
	if actual_collectable_root_node:
		actual_collectable_root_node.queue_free()
	else:
		queue_free()

func label() -> String:
	if !enabled: return ""
	return label_text % display_name
