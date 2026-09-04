@tool
## Spawns an object or objects at the specified location
class_name Spawner3D extends Node3D

## Whether to enable the spawner
@export var enabled: bool = true
## Set a maximum amount of spawns (0 for infinite)
@export var spawn_limit: int = 0
## Number of spawns left. Runtime state: initialised from [member spawn_limit] on ready.
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
## Keep the number of spawned items in the tree equal to the spawn limit
## (overrides monitor_deletions to true)
@export var auto_spawn_all: bool = false
## Keep deleted spawns deleted when restoring persisted spawn state
@export var persist_deletions: bool = false

## Triggered when an item is spawned
signal spawned
## Triggered when an item is despawned (monitoring must be enabled)
signal despawned
## Triggered when the spawn limit is reached
signal spawn_limit_reached
## Triggered when the spawns_left is updated
signal spawns_left_updated(spawns_left: int)

var is_editor: bool = Engine.is_editor_hint()
## The template children, detached from the tree and duplicated on every spawn
var saved_children: Array = []

## One entry per [method action] call, holding the nodes that call produced
var _spawned_batches: Array = []
## Spawns that have taken their budget but are still waiting on [member spawn_delay]
var _pending_spawns: int = 0
## Invalidates delayed actions when a persistence system restores a different state
var _spawn_epoch: int = 0
## State supplied before this node is ready
var _pending_restore_state: Dictionary = {}


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !Nodot.get_first_child_of_type(self, Node3D):
		warnings.append("Should have a child of Node3D type")
	if spawn_limit < 1 and (spawn_all_on_start or auto_spawn_all):
		warnings.append(
			"spawn_all_on_start and auto_spawn_all spawn nothing while spawn_limit is 0"
		)
	return warnings


func _enter_tree() -> void:
	if is_editor or !saved_children.is_empty():
		return

	# Detach the templates before they can enter the tree, so their _ready()
	# never runs. Spawned duplicates are children too, so this must only ever
	# happen on the first _enter_tree.
	for item in Nodot.get_children_of_type(self, Node3D):
		saved_children.append(item)
		remove_child(item)


func _ready() -> void:
	if is_editor:
		return

	if spawn_limit > 0:
		reset()

	if monitor_deletions or auto_spawn_all:
		var timer := Timer.new()
		timer.wait_time = maxf(deletion_check_interval, 0.05)
		timer.autostart = true
		timer.timeout.connect(check)
		add_child(timer)

	if !_pending_restore_state.is_empty():
		var state := _pending_restore_state
		_pending_restore_state = {}
		_restore_spawn_state_now(state)
	elif spawn_all_on_start or auto_spawn_all:
		for i in maxi(spawn_limit, 0):
			action()
	elif spawn_one_on_start:
		action()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# The templates are parented to nothing, so nothing else will free them
		for child in saved_children:
			if is_instance_valid(child) and !child.is_inside_tree():
				child.free()
		saved_children.clear()


## Spawn all children of Node3D type
func action() -> void:
	if !enabled or saved_children.is_empty():
		return

	if spawn_limit > 0 and spawns_left < 1:
		spawn_limit_reached.emit()
		return

	# Take the budget before waiting out the delay, so a pending spawn cannot be
	# double booked by another action() call or by check() while it waits
	_take_spawn_budget(1)
	var spawn_epoch := _spawn_epoch

	if spawn_delay > 0:
		_pending_spawns += 1
		await get_tree().create_timer(spawn_delay, false).timeout
		if spawn_epoch != _spawn_epoch:
			return
		_pending_spawns -= 1
		if !is_inside_tree() or !enabled:
			_refund_spawn_budget(1)
			return

	var batch := _spawn_batch()
	if batch.is_empty():
		_refund_spawn_budget(1)
		return

	_spawned_batches.append(batch)
	if !_is_monitoring():
		# check() is not running to prune these, so drop dead batches here rather
		# than hold references to every spawn the node ever made
		_spawned_batches = _spawned_batches.filter(_is_batch_alive)

	spawned.emit()


## Reset the spawn limit
func reset() -> void:
	spawns_left = maxi(spawn_limit, 0)
	spawns_left_updated.emit(spawns_left)


## Return the number of complete spawn batches which are still alive
func get_current_spawn_count() -> int:
	var count: int = 0
	for batch in _spawned_batches:
		if _is_batch_alive(batch):
			count += 1
	return count


## Capture portable state for any persistence system
func get_spawn_state() -> Dictionary:
	return {"spawned_count": get_current_spawn_count()}


## Restore portable state captured by [method get_spawn_state]
func restore_spawn_state(state: Dictionary) -> void:
	if !is_node_ready():
		_pending_restore_state = state.duplicate(true)
		return
	_restore_spawn_state_now(state)


## Optional Saver adapter; other persistence systems can use the public state methods
func _saver_serialize() -> Variant:
	if !persist_deletions:
		return null
	return get_spawn_state()


## Optional Saver adapter
func _saver_deserialize(state: Dictionary) -> void:
	if persist_deletions:
		restore_spawn_state(state)


## Check the current number of spawned objects
func check() -> void:
	var alive: Array = []
	var lost: int = 0
	for batch in _spawned_batches:
		if _is_batch_alive(batch):
			alive.append(batch)
		else:
			lost += 1
	_spawned_batches = alive

	if lost > 0:
		for i in lost:
			despawned.emit()
		if _is_monitoring():
			_refund_spawn_budget(lost)

	if !auto_spawn_all or persist_deletions:
		return

	# Spawns still waiting on their delay are already paid for and on their way,
	# so they must count towards the total or the spawner overshoots the limit
	var missing: int = spawn_limit - alive.size() - _pending_spawns
	for i in maxi(missing, 0):
		action()


func _is_monitoring() -> bool:
	return monitor_deletions or auto_spawn_all


func _spawn_batch() -> Array:
	var batch: Array = []
	for child: Node3D in saved_children:
		if !is_instance_valid(child):
			continue
		var new_child: Node3D = child.duplicate(
			DUPLICATE_SIGNALS | DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_USE_INSTANTIATION
		)
		# Place it before it enters the tree so it never renders a frame at the
		# spawner's origin. A zeroed local transform is the spawner's global one.
		new_child.position = Vector3.ZERO
		new_child.rotation = Vector3.ZERO
		add_child(new_child)
		batch.append(new_child)
	return batch


func _restore_spawn_state_now(state: Dictionary) -> void:
	if !state.has("spawned_count"):
		return

	# Any delayed actions belong to the state being replaced and must not arrive
	# after the restored batches have been reconciled.
	_spawn_epoch += 1
	_pending_spawns = 0

	var alive: Array = []
	for batch in _spawned_batches:
		if _is_batch_alive(batch):
			alive.append(batch)
	_spawned_batches = alive

	var target_count := maxi(int(state["spawned_count"]), 0)
	if spawn_limit > 0:
		target_count = mini(target_count, spawn_limit)

	while _spawned_batches.size() > target_count:
		var batch: Array = _spawned_batches.pop_back()
		for node in batch:
			if is_instance_valid(node) and node.get_parent() == self:
				node.queue_free()

	while _spawned_batches.size() < target_count:
		var batch := _spawn_batch()
		if batch.is_empty():
			break
		_spawned_batches.append(batch)

	if spawn_limit > 0:
		spawns_left = maxi(spawn_limit - _spawned_batches.size(), 0)
	spawns_left_updated.emit(spawns_left)


## A batch counts as spawned for as long as any of its nodes is still a child
func _is_batch_alive(batch: Array) -> bool:
	for node in batch:
		if (
			is_instance_valid(node)
			and !node.is_queued_for_deletion()
			and node.get_parent() == self
		):
			return true
	return false


func _take_spawn_budget(amount: int) -> void:
	if spawn_limit < 1:
		return
	spawns_left = maxi(spawns_left - amount, 0)
	spawns_left_updated.emit(spawns_left)


func _refund_spawn_budget(amount: int) -> void:
	if spawn_limit < 1:
		return
	spawns_left = mini(spawns_left + amount, spawn_limit)
	spawns_left_updated.emit(spawns_left)
