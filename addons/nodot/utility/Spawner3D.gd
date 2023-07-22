@tool
## Spawns an object or objects at the specified location
class_name Spawner3D extends Nodot3D

## Whether to enable the spawner
@export var enabled: bool = true
## Set a maximum amount of spawns (0 for infinite)
@export var spawn_limit: int = 0
## Number of spawns left
@export var spawns_left: int = 0
## The delay before spawning an item
@export var spawn_delay: float = 0.0
## Whether to spawn on start
@export var spawn_one_on_start: bool = false
## Spawn all on start
@export var spawn_all_on_start: bool = false
## Increase spawns_left when a spawned item is deleted
@export var monitor_deletions: bool = false
## The interval at which to check for deletions
@export var deletion_check_interval: float = 1.0
## Keep the number of spawned items in the tree equal to the spawn limit (overrides monitor_deletions to true)
@export var auto_spawn_all: bool = false

## Triggered when an item is spawned
signal spawned
## Triggered when an item is despawned (monitoring must be enabled)
signal despawned
## Triggered when the spawn limit is reached
signal spawn_limit_reached
## Triggered when the spawns_left is updated
signal spawns_left_updated(spawns_left: int)

var is_editor: bool = Engine.is_editor_hint()
var saved_children: Array = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !Nodot.get_first_child_of_type(self, Node3D):
		warnings.append("Should have a child of Node3D type")
	return warnings


func _enter_tree() -> void:
	if is_editor:
		return

	var node3d_children = Nodot.get_children_of_type(self, Node3D)
	for item in node3d_children:
		saved_children.append(item)
		remove_child(item)

	if monitor_deletions or auto_spawn_all:
		var timer = Timer.new()
		timer.set_wait_time(deletion_check_interval)
		timer.autostart = true
		timer.connect("timeout", check)
		add_child(timer)

	if spawn_all_on_start or auto_spawn_all:
		for i in spawn_limit:
			action()
	elif spawn_one_on_start:
		action()


## Spawn all children of Node3D type
func action() -> void:
	if !enabled or (spawn_limit > 0 and spawns_left == 0):
		if spawns_left == 0:
			emit_signal("spawn_limit_reached")
		return

	if spawn_delay > 0:
		await get_tree().create_timer(spawn_delay, false).timeout

	for child in saved_children:
		var new_child = child.duplicate(15)
		add_child(new_child)
		new_child.global_position = global_position
		new_child.global_rotation = global_rotation
	spawns_left -= 1
	emit_signal("spawned")
	emit_signal("spawns_left_updated", spawns_left)


## Reset the spawn limit
func reset() -> void:
	spawns_left = spawn_limit
	emit_signal("spawns_left_updated", spawns_left)


## Check the current number of spawned objects
func check() -> void:
	var current_spawns = floor(
		Nodot.get_children_of_type(self, Node3D).size() / saved_children.size()
	)
	if current_spawns < (spawn_limit - spawns_left):
		emit_signal("despawned")
	if current_spawns < spawn_limit:
		spawns_left = spawn_limit - current_spawns
		if auto_spawn_all:
			action()
	else:
		spawns_left = 0
	emit_signal("spawns_left_updated", spawns_left)
