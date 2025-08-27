## A collectable RigidBody3D that can be placed in inventories.
class_name RigidCollectable3D extends NodotRigidBody3D

## Enable the item for collection
@export var enabled: bool = true
## The quantity of the collectable.
@export var quantity: int = 1
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
## The collectable path associated with this node
@export_file("*.tres") var collectable_path: String

var collectable: Collectable
var actual_collectable_root_node: Node

## Triggered on collection
signal collected

func _enter_tree():
	contact_monitor = true
	max_contacts_reported = 1
	if collectable_root_node:
		actual_collectable_root_node = get_node(collectable_root_node)
	
	collectable = load(collectable_path)
	if !collectable:
		push_error("Unable to load collectable: %s" % collectable_path)
		return
	CollectableManager.add(collectable)

func _physics_process(delta: float) -> void:
	if !collect_on_collision: return
	for body in get_colliding_bodies():
		if body is CharacterBody3D and body.is_current_player:
			interact(body)

func interact(player_node: CharacterBody3D = PlayerManager.node) -> void:
	var valid_pickup: bool = false
	
	if player_node.has_method("collect"):
		valid_pickup = player_node.collect(self)
	
	if !valid_pickup: return
	
	enabled = false
	visible = false
	collected.emit()
	
	if free_delay > 0.0:
		await get_tree().create_timer(free_delay, false).timeout
		
	if actual_collectable_root_node:
		actual_collectable_root_node.queue_free()
	else:
		queue_free()

func label() -> String:
	if !enabled: return ""
	
	return label_text % collectable.display_name
