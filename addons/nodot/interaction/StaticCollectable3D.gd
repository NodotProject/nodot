## A collectable StaticBody3D that can be placed in inventories.
class_name StaticCollectable3D extends NodotStaticBody3D

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
## The weight of the collectable (kg each).
@export var mass: float = 0.1
## Maximum stack count
@export var stack_limit: int = 1
## The interactive label
@export var label_text: String = "Take %s"
## Allow the item to be collected by colliding with it.
# TODO: Figure this out: @export var collect_on_collision: bool = true

## Triggered on collection
signal collected

func _init():
	CollectableManager.add(self)
	
#func _physics_process(delta: float) -> void:
#	if collect_on_collision:
#		for body in get_overlapping_bodies():
#			if body is CharacterBody3D:
#				interact(body)

func interact(player_node: CharacterBody3D) -> void:
	if player_node.has_method("collect"):
		player_node.collect(self)
		emit_signal("collected")
		queue_free()

func label() -> String:
	return label_text % display_name
