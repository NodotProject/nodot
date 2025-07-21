## An inventory for collectables
class_name CollectableInventory extends Node

## Enable the inventory
@export var enabled: bool = true
## The maximum number of slots/stacks in the inventory (0 for infinite)
@export var capacity: int = 25
## The maximum weight of the inventory (0 for infinite)
@export var max_weight: float = 20.0
## A node3d used to position items back into the world
@export var spawn_location_node: Node3D
## Only these item groups are allowed in this inventory
@export var item_group_allowlist: Array[String] = []
## These item groups are not allowed in this inventory
@export var item_group_blocklist: Array[String] = []

# Array of tuples. Collectable id (string) and quantity (int)
var _collectable_stacks: Array = []

## Read-only getter for collectable stacks
func get_stacks() -> Array:
	return _collectable_stacks.duplicate(true)

## Centralized slot setter with allowlist/blocklist enforcement
func _set_slot(index: int, collectable_id: String, quantity: int) -> void:
	if index < 0 or index >= _collectable_stacks.size():
		push_error("Invalid slot index: %d" % index)
		return
	if collectable_id != "" and not is_allowed(collectable_id):
		push_error("Collectable %s is not allowed in this inventory" % collectable_id)
		return
	var collectable = null
	if collectable_id != "":
		collectable = CollectableManager.get_info(collectable_id)
	var final_quantity = quantity
	if collectable and quantity > collectable.stack_limit:
		final_quantity = collectable.stack_limit
	if final_quantity <= 0 or collectable_id == "":
		_collectable_stacks[index] = ["", 0]
		collectable_updated.emit(index, "", 0)
	else:
		_collectable_stacks[index] = [collectable_id, final_quantity]
		collectable_updated.emit(index, collectable_id, final_quantity)

## Allowlist/blocklist check
func is_allowed(collectable_id: String) -> bool:
	var collectable := CollectableManager.get_info(collectable_id)
	if !collectable:
		return false
	if item_group_allowlist.size() > 0:
		var allowed := false
		for group in collectable.item_groups:
			if item_group_allowlist.has(group):
				allowed = true
				break
		if !allowed:
			return false
	if item_group_blocklist.size() > 0:
		for group in collectable.item_groups:
			if item_group_blocklist.has(group):
				return false
	return true

## Triggered when a stack or slot is updated
signal collectable_updated(index: int, collectable_id: String, quantity: int)
## Triggered when the inventory overflows (useful to spawn excess items back into the world)
signal overflow(collectable_id: String, quantity: int)
## Triggered when the inventory is too heavy
signal max_weight_reached
## Triggered when the capacity is reached
signal capacity_reached

## Unique identifier for this inventory
@onready var unique_name: String = "%s-%s" % [get_parent().name, name]

# Returns true if there is space for at least one of the given collectable
func has_space_for(collectable_id: String, quantity: int) -> bool:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		return false
	# Check for existing stack with space
	for stack in _collectable_stacks:
		if stack[0] == collectable_id and stack[1] < collectable.stack_limit:
			return true
	# Check for empty slot
	for stack in _collectable_stacks:
		if stack[0] == "" or stack[1] == 0:
			return true
	# If capacity is 0 (infinite), always has space
	if capacity == 0 or _collectable_stacks.size() < capacity:
		return true
	return false

func _enter_tree():
	for i in capacity:
		_collectable_stacks.append(["", 0])
	CollectableManager.inventories.set(unique_name, self)

## Add a collectable to the inventory
func add(collectable_id: String, quantity: int) -> bool:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		push_error("%s has not been registered in CollectableManager" % collectable_id)
		return false

	if not is_allowed(collectable_id):
		return false

	if not has_space_for(collectable_id, quantity):
		capacity_reached.emit()
		return false

	var weight = collectable.mass

	if max_weight > 0.0:
		var stack_weight = quantity * weight
		var total = get_total_weight(stack_weight)
		if total > max_weight:
			max_weight_reached.emit()
			return false

	var remaining_quantity = _update_available_stack(collectable_id, quantity)
	if remaining_quantity > 0:
		var overflow = _update_available_slot(collectable_id, remaining_quantity)
		if overflow > 0:
			return add(collectable_id, overflow)
		else:
			return true
	elif remaining_quantity == 0:
		return true

	if remaining_quantity > 0:
		overflow.emit(remaining_quantity)
	capacity_reached.emit()
	return false

## Remove a collectable from the inventory
func remove(collectable_id: String, quantity: int) -> bool:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable or quantity == 0:
		push_error("%s has not been registered in CollectableManager" % collectable_id)
		return false

	var collectable_index = get_collectable_index(collectable_id)
	if collectable_index < 0:
		return false

	var stack_quantity = _collectable_stacks[collectable_index][1]
	if stack_quantity >= quantity:
		_set_slot(collectable_index, collectable_id, stack_quantity - quantity)
		return true
	if stack_quantity > 0:
		_set_slot(collectable_index, collectable_id, 0)
		return remove(collectable_id, quantity - stack_quantity)

	return false

func add_to_slot(slot_index: int, collectable_id: String, quantity: int) -> bool:
	if slot_index < 0 or slot_index >= _collectable_stacks.size():
		push_error("Invalid slot index: %d" % slot_index)
		return false

	if not is_allowed(collectable_id):
		return false

	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		push_error("%s has not been registered in CollectableManager" % collectable_id)
		return false

	var weight = collectable.mass
	var stack_weight = quantity * weight
	var total_weight = get_total_weight(stack_weight)
	if max_weight > 0.0 and total_weight > max_weight:
		max_weight_reached.emit()
		return false

	var current_stack = _collectable_stacks[slot_index]
	if current_stack[0] == "" or current_stack[0] == collectable_id:
		var current_quantity = current_stack[1]
		var new_quantity = current_quantity + quantity
		var final_quantity = min(new_quantity, collectable.stack_limit)
		var overflow_quantity = new_quantity - final_quantity

		_set_slot(slot_index, collectable_id, final_quantity)

		if overflow_quantity > 0:
			overflow.emit(collectable_id, overflow_quantity)
			return false
		return true
	else:
		push_error("Slot %d is occupied by a different collectable: %s" % [slot_index, current_stack[0]])
		return false

func remove_from_slot(slot_index: int, quantity: int) -> bool:
	if slot_index < 0 or slot_index >= _collectable_stacks.size():
		push_error("Invalid slot index: %d" % slot_index)
		return false

	var current_stack = _collectable_stacks[slot_index]
	var collectable_id = current_stack[0]
	if collectable_id == "" or quantity <= 0:
		return false

	var current_quantity = current_stack[1]
	if quantity >= current_quantity:
		# Clear the slot
		_set_slot(slot_index, "", 0)
	else:
		_set_slot(slot_index, collectable_id, current_quantity - quantity)

	return true

## Get the total weight of the inventory
func get_total_weight(additional_weight: float = 0.0):
	var total_weight = 0
	for stack in _collectable_stacks:
		var id = stack[0]
		if id != "":
			var quantity = stack[1]
			var collectable = CollectableManager.get_info(id)
			var weight = collectable.mass
			var stack_weight = quantity * weight
			total_weight += stack_weight
	total_weight += additional_weight
	return total_weight


## Update an available stack for the collectable
func _update_available_stack(collectable_id: String, quantity: int):
	for i in range(_collectable_stacks.size()):
		var stored_stack = _collectable_stacks[i]
		var stored_stack_id = stored_stack[0]
		if stored_stack_id == collectable_id:
			var collectable = CollectableManager.get_info(collectable_id)
			var stored_stack_quantity = stored_stack[1]
			if stored_stack_quantity >= collectable.stack_limit:
				continue
			var available = stored_stack_quantity + quantity
			if available > collectable.stack_limit:
				_set_slot(i, collectable_id, collectable.stack_limit)
				return _update_available_stack(collectable_id, available - collectable.stack_limit)
			else:
				_set_slot(i, collectable_id, available)
				return 0

	return quantity


## Get available slot
func _update_available_slot(collectable_id: String, quantity: int) -> int:
	if quantity <= 0: return 0

	var available_slot

	var current_stack_size = _collectable_stacks.size()

	# Get first empty slot
	for i in current_stack_size:
		var stored_stack = _collectable_stacks[i]
		var stored_stack_quantity = stored_stack[1]
		if stored_stack_quantity == 0:
			available_slot = i
			break

	if available_slot == null:
		# TODO: Add a test for when capacity is 0 (infinite)
		if capacity == 0 or current_stack_size < capacity:
			available_slot = current_stack_size
			_collectable_stacks.append(["", 0])
	else:
		var collectable := CollectableManager.get_info(collectable_id)
		var new_quantity := quantity
		var overflow = 0
		if quantity > collectable.stack_limit:
			new_quantity = collectable.stack_limit
			_update_available_slot(collectable_id, quantity - new_quantity)
		overflow = quantity - new_quantity
		_set_slot(available_slot, collectable_id, new_quantity)
		return overflow
	
	return 0

## Get the last index of a specific collectable
func get_collectable_index(collectable_id: String):
	for i in _collectable_stacks.size():
		var stack = _collectable_stacks[i]
		if stack[0] == collectable_id:
			return i
	return -1

## Get a total count of all items of a specific type
func get_collectable_count(collectable_id: String) -> int:
	return _collectable_stacks.reduce(func(accum, stack):
		if stack[0] == collectable_id:
			return accum + stack[1]
		return accum
	, 0)
	
## Update a specific slot
func update_slot(slot_index: int, collectable_id: String, quantity: int, _overflow: int):
	if quantity > 0:
		_set_slot(slot_index, collectable_id, quantity)
	else:
		_set_slot(slot_index, "", 0)

## Drop a slot item back into the real world
func drop_slot(slot_index: int, collectable_id: String, quantity: int):
	update_slot(slot_index, "", 0, 0)
	var collectable_info = CollectableManager.get_info(collectable_id)
	if !collectable_info: return
	
	var item_scene = collectable_info.scene
	for i in quantity:
		var item_instance = item_scene.instantiate()
		item_instance.top_level = true
		if spawn_location_node:
			spawn_location_node.add_child(item_instance)
			item_instance.global_position = spawn_location_node.global_position
		else:
			push_error("No spawn location node set")


func _check_allowlist(collectable: Collectable):
	if item_group_allowlist.size() == 0:
		return true
	for group in collectable.item_groups:
		if group in item_group_allowlist:
			return true
	return false
	
func _check_blocklist(collectable: Collectable):
	if item_group_blocklist.size() == 0:
		return true
	for group in collectable.item_groups:
		if group in item_group_blocklist:
			return false
	return true
# Move a stack from one slot to another (for HUD drag-and-drop)
func move_between_slots(from_slot: int, to_slot: int) -> void:
	if from_slot == to_slot:
		return
	if from_slot < 0 or from_slot >= _collectable_stacks.size():
		return
	if to_slot < 0 or to_slot >= _collectable_stacks.size():
		return

	var from_stack = _collectable_stacks[from_slot]
	var to_stack = _collectable_stacks[to_slot]

	var from_id = from_stack[0]
	var from_qty = from_stack[1]
	if from_id == "" or from_qty == 0:
		return

	var to_id = to_stack[0]
	var to_qty = to_stack[1]

	if to_id == "":
		# Move stack to empty slot
		_set_slot(to_slot, from_id, from_qty)
		_set_slot(from_slot, "", 0)
	elif to_id == from_id:
		var collectable = CollectableManager.get_info(from_id)
		var stack_limit = collectable.stack_limit
		var total = from_qty + to_qty
		var new_to_qty = min(total, stack_limit)
		var overflow = total - new_to_qty
		_set_slot(to_slot, from_id, new_to_qty)
		if new_to_qty == total:
			_set_slot(from_slot, "", 0)
		else:
			_set_slot(from_slot, from_id, overflow)
	else:
		# Swap stacks
		_set_slot(to_slot, from_id, from_qty)
		_set_slot(from_slot, to_id, to_qty)
