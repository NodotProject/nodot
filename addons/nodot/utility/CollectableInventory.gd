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
## Add an inventory to overflow into if the current one is full
@export var overflow_inventory: CollectableInventory

# Constants for better readability
const INFINITE_CAPACITY = 0
const INFINITE_WEIGHT = 0.0
const EMPTY_SLOT_ID = ""
const EMPTY_SLOT_QUANTITY = 0

## Triggered when a stack or slot is updated
signal collectable_updated(index: int, collectable_id: String, quantity: int)
## Triggered when the inventory overflows (useful to spawn excess items back into the world)
signal overflow(collectable_id: String, quantity: int)
## Triggered when the inventory is too heavy
signal max_weight_reached
## Triggered when the capacity is reached
signal capacity_reached

## Unique identifier for this inventory
var unique_name: String = ""

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
	if collectable_id != EMPTY_SLOT_ID and not is_allowed(collectable_id):
		push_error("Collectable %s is not allowed in this inventory" % collectable_id)
		return
	var collectable = null
	if collectable_id != EMPTY_SLOT_ID:
		collectable = CollectableManager.get_info(collectable_id)
	var final_quantity = quantity
	if collectable and quantity > collectable.stack_limit:
		final_quantity = collectable.stack_limit
	if final_quantity <= 0 or collectable_id == EMPTY_SLOT_ID:
		_collectable_stacks[index] = [EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY]
		collectable_updated.emit(index, EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY)
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


## Returns true if there is space for at least one of the given collectable
func has_space_for(collectable_id: String, quantity: int) -> bool:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		return false
	# Check for existing stack with space
	if _find_stackable_slot(collectable_id) >= 0:
		return true
	# Check for empty slot
	if _find_empty_slot() >= 0:
		return true
	# If capacity is infinite, always has space
	if capacity == INFINITE_CAPACITY or _collectable_stacks.size() < capacity:
		return true
	return false

## Find the first slot that can stack more of the given collectable
func _find_stackable_slot(collectable_id: String) -> int:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		return -1
	for i in range(_collectable_stacks.size()):
		var stack = _collectable_stacks[i]
		if stack[0] == collectable_id and stack[1] < collectable.stack_limit:
			return i
	return -1

## Find the first empty slot
func _find_empty_slot() -> int:
	for i in range(_collectable_stacks.size()):
		var stack = _collectable_stacks[i]
		if stack[0] == EMPTY_SLOT_ID or stack[1] == EMPTY_SLOT_QUANTITY:
			return i
	return -1

func _enter_tree():
	for i in capacity:
		_collectable_stacks.append([EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY])
	unique_name = "%s-%s" % [get_parent().name, name]
	CollectableManager.inventories.set(unique_name, self)

## Internal validation for collectable actions
func _validate_collectable_action(collectable_id: String, quantity: int, slot_index: int = -1) -> Dictionary:
	var result = {
		"valid": true,
		"error": "",
		"collectable": null
	}
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		result.valid = false
		result.error = "%s has not been registered in CollectableManager" % collectable_id
		return result

	if not is_allowed(collectable_id):
		result.valid = false
		result.error = "Collectable %s is not allowed in this inventory" % collectable_id
		return result

	if quantity <= 0:
		result.valid = false
		result.error = "Quantity must be greater than zero"
		return result

	if slot_index >= 0 and slot_index >= _collectable_stacks.size():
		result.valid = false
		result.error = "Invalid slot index: %d" % slot_index
		return result

	result.collectable = collectable
	return result

## Internal add logic (used by add and add_to_slot)
func _add(collectable_id: String, quantity: int, slot_index: int = -1) -> Dictionary:
	var result = {"success": false, "overflow": 0}
	
	var validation = _validate_collectable_action(collectable_id, quantity, slot_index)
	if !validation.valid:
		push_error(validation.error)
		return result

	var collectable = validation.collectable

	# Weight check
	if not _check_weight_capacity(collectable, quantity):
		max_weight_reached.emit()
		return result

	# Handle specific slot addition
	if slot_index >= 0:
		return _add_to_specific_slot(slot_index, collectable_id, quantity, collectable)
	
	# Handle general addition with capacity check
	if not has_space_for(collectable_id, quantity):
		return _handle_overflow(collectable_id, quantity)
	
	# Distribute items across available slots
	return _distribute_items(collectable_id, quantity, collectable)

## Check if adding items would exceed weight capacity
func _check_weight_capacity(collectable: Collectable, quantity: int) -> bool:
	if max_weight <= INFINITE_WEIGHT:
		return true
	var stack_weight = quantity * collectable.mass
	var total = get_total_weight(stack_weight)
	return total <= max_weight

## Add items to a specific slot
func _add_to_specific_slot(slot_index: int, collectable_id: String, quantity: int, collectable: Collectable) -> Dictionary:
	var result = {"success": false, "overflow": 0}
	var current_stack = _collectable_stacks[slot_index]
	
	if current_stack[0] != EMPTY_SLOT_ID and current_stack[0] != collectable_id:
		push_error("Slot %d is occupied by a different collectable: %s" % [slot_index, current_stack[0]])
		return result
	
	var current_quantity = current_stack[1]
	var new_quantity = current_quantity + quantity
	var final_quantity = min(new_quantity, collectable.stack_limit)
	var overflow_quantity = new_quantity - final_quantity
	
	_set_slot(slot_index, collectable_id, final_quantity)
	result.success = true
	
	if overflow_quantity > 0:
		overflow.emit(collectable_id, overflow_quantity)
		result.overflow = overflow_quantity
	
	return result

## Handle overflow when inventory is full
func _handle_overflow(collectable_id: String, quantity: int) -> Dictionary:
	var result = {"success": false, "overflow": quantity}
	
	if overflow_inventory != null:
		var overflow_result = overflow_inventory._add(collectable_id, quantity)
		if overflow_result.success:
			result.success = true
			result.overflow = 0
		else:
			_emit_overflow_signals(collectable_id, quantity)
	else:
		_emit_overflow_signals(collectable_id, quantity)
	
	return result

## Emit overflow and capacity signals
func _emit_overflow_signals(collectable_id: String, quantity: int) -> void:
	overflow.emit(collectable_id, quantity)
	capacity_reached.emit()

## Distribute items across available slots
func _distribute_items(collectable_id: String, quantity: int, collectable: Collectable) -> Dictionary:
	var result = {"success": false, "overflow": 0}
	var remaining_quantity = quantity
	
	# Fill existing stacks first
	remaining_quantity = _fill_existing_stacks(collectable_id, remaining_quantity, collectable)
	if remaining_quantity <= 0:
		result.success = true
		return result
	
	# Fill empty slots
	remaining_quantity = _fill_empty_slots(collectable_id, remaining_quantity, collectable)
	if remaining_quantity <= 0:
		result.success = true
		return result
	
	# Add new slots if capacity allows
	remaining_quantity = _add_new_slots(collectable_id, remaining_quantity, collectable)
	if remaining_quantity <= 0:
		result.success = true
		return result
	
	# Handle any remaining overflow
	if remaining_quantity > 0:
		return _handle_overflow(collectable_id, remaining_quantity)
	
	result.success = true
	return result

## Fill existing stacks with available space
func _fill_existing_stacks(collectable_id: String, quantity: int, collectable: Collectable) -> int:
	var remaining = quantity
	for i in range(_collectable_stacks.size()):
		var stack = _collectable_stacks[i]
		if stack[0] == collectable_id and stack[1] < collectable.stack_limit:
			var can_add = min(collectable.stack_limit - stack[1], remaining)
			_set_slot(i, collectable_id, stack[1] + can_add)
			remaining -= can_add
			if remaining <= 0:
				break
	return remaining

## Fill empty slots with items
func _fill_empty_slots(collectable_id: String, quantity: int, collectable: Collectable) -> int:
	var remaining = quantity
	for i in range(_collectable_stacks.size()):
		var stack = _collectable_stacks[i]
		if stack[0] == EMPTY_SLOT_ID or stack[1] == EMPTY_SLOT_QUANTITY:
			var can_add = min(collectable.stack_limit, remaining)
			_set_slot(i, collectable_id, can_add)
			remaining -= can_add
			if remaining <= 0:
				break
	return remaining

## Add new slots if capacity allows
func _add_new_slots(collectable_id: String, quantity: int, collectable: Collectable) -> int:
	var remaining = quantity
	while (capacity == INFINITE_CAPACITY or _collectable_stacks.size() < capacity) and remaining > 0:
		var can_add = min(collectable.stack_limit, remaining)
		_collectable_stacks.append([EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY])
		_set_slot(_collectable_stacks.size() - 1, collectable_id, can_add)
		remaining -= can_add
	return remaining

## Internal remove logic (used by remove and remove_from_slot)
func _remove(collectable_id: String, quantity: int, slot_index: int = -1) -> bool:
	var validation = _validate_collectable_action(collectable_id, quantity, slot_index)
	if !validation.valid:
		push_error(validation.error)
		return false

	if slot_index >= 0:
		return _remove_from_specific_slot(slot_index, collectable_id, quantity)
	else:
		return _remove_from_a_stack(collectable_id, quantity)

## Remove items from a specific slot
func _remove_from_specific_slot(slot_index: int, collectable_id: String, quantity: int) -> bool:
	var current_stack = _collectable_stacks[slot_index]
	if current_stack[0] != collectable_id or current_stack[1] == EMPTY_SLOT_QUANTITY:
		return false
	
	var remove_qty = min(quantity, current_stack[1])
	var new_qty = current_stack[1] - remove_qty
	var final_id = collectable_id if new_qty > 0 else EMPTY_SLOT_ID
	_set_slot(slot_index, final_id, new_qty)
	return true

## Remove items from a matching stacks
func _remove_from_a_stack(collectable_id: String, quantity: int) -> bool:
	var remaining = quantity
	for i in range(_collectable_stacks.size()):
		var stack = _collectable_stacks[i]
		if stack[0] == collectable_id and stack[1] > 0 and remaining > 0:
			var remove_qty = min(stack[1], remaining)
			var new_qty = stack[1] - remove_qty
			var final_id = collectable_id if new_qty > 0 else EMPTY_SLOT_ID
			_set_slot(i, final_id, new_qty)
			remaining -= remove_qty
			if remaining <= 0:
				return true
			break
	return remaining <= 0

## Add a collectable to the inventory (public API)
func add(collectable_id: String, quantity: int) -> bool:
	var result = _add(collectable_id, quantity)
	return result.success

## Remove a collectable from the inventory (public API)
func remove(collectable_id: String, quantity: int) -> bool:
	return _remove(collectable_id, quantity)

## Add a collectable to a specific slot (public API)
func add_to_slot(slot_index: int, collectable_id: String, quantity: int) -> bool:
	var result = _add(collectable_id, quantity, slot_index)
	return result.success

## Remove a collectable from a specific slot (public API)
func remove_from_slot(slot_index: int, quantity: int) -> bool:
	if slot_index < 0 or slot_index >= _collectable_stacks.size():
		push_error("Invalid slot index: %d" % slot_index)
		return false
	var current_stack = _collectable_stacks[slot_index]
	var collectable_id = current_stack[0]
	if collectable_id == EMPTY_SLOT_ID or quantity <= 0:
		return false
	return _remove(collectable_id, quantity, slot_index)

## Get the total weight of the inventory
func get_total_weight(additional_weight: float = 0.0) -> float:
	var total_weight = 0.0
	for stack in _collectable_stacks:
		var id = stack[0]
		if id != EMPTY_SLOT_ID:
			var quantity = stack[1]
			var collectable = CollectableManager.get_info(id)
			if collectable:
				var stack_weight = quantity * collectable.mass
				total_weight += stack_weight
	total_weight += additional_weight
	return total_weight


## Get the first index of a specific collectable
func get_collectable_index(collectable_id: String) -> int:
	for i in _collectable_stacks.size():
		var stack = _collectable_stacks[i]
		if stack[0] == collectable_id:
			return i
	return -1

## Get a total count of all items of a specific type
func get_collectable_count(collectable_id: String) -> int:
	return _collectable_stacks.reduce(func(total, stack):
		if stack[0] == collectable_id:
			return total + stack[1]
		return total
	, 0)
	
## Update a specific slot
func update_slot(slot_index: int, collectable_id: String, quantity: int, _overflow: int):
	if quantity > 0:
		_set_slot(slot_index, collectable_id, quantity)
	else:
		_set_slot(slot_index, EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY)

## Drop a slot item back into the real world
func drop_slot(slot_index: int, collectable_id: String, quantity: int):
	update_slot(slot_index, EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY, 0)
	_spawn_items_into_world(collectable_id, quantity)

## Spawn items into the world at the spawn location
func _spawn_items_into_world(collectable_id: String, quantity: int) -> void:
	var collectable_info = CollectableManager.get_info(collectable_id)
	if !collectable_info:
		push_error("Cannot spawn unknown collectable: %s" % collectable_id)
		return
	
	if !spawn_location_node:
		push_error("No spawn location node set for inventory")
		return
		
	var item_scene = collectable_info.scene
	for i in quantity:
		var item_instance = item_scene.instantiate()
		item_instance.top_level = true
		add_child(item_instance)
		item_instance.global_position = spawn_location_node.global_position
		item_instance.add_to_group("despawnable_item")


## Move a stack from one inventory/slot to another (for HUD drag-and-drop)
func move_between_slots(from_inventory: CollectableInventory, from_slot: int, to_inventory: CollectableInventory, to_slot: int) -> void:
	if not _validate_move_parameters(from_inventory, from_slot, to_inventory, to_slot):
		return

	var from_stack = from_inventory._collectable_stacks[from_slot]
	var to_stack = to_inventory._collectable_stacks[to_slot]

	var from_id = from_stack[0]
	var from_qty = from_stack[1]
	if from_id == EMPTY_SLOT_ID or from_qty == EMPTY_SLOT_QUANTITY:
		return

	var to_id = to_stack[0]
	var to_qty = to_stack[1]

	# Check if the item is allowed in the target inventory
	if not to_inventory.is_allowed(from_id):
		return

	_execute_move_operation(from_inventory, from_slot, to_inventory, to_slot, from_id, from_qty, to_id, to_qty)

## Validate parameters for move operation
func _validate_move_parameters(from_inventory: CollectableInventory, from_slot: int, to_inventory: CollectableInventory, to_slot: int) -> bool:
	if from_inventory == null or to_inventory == null:
		return false
	if from_slot == to_slot and from_inventory == to_inventory:
		return false
	if from_slot < 0 or from_slot >= from_inventory._collectable_stacks.size():
		return false
	if to_slot < 0 or to_slot >= to_inventory._collectable_stacks.size():
		return false
	return true

## Execute the actual move operation based on slot contents
func _execute_move_operation(from_inventory: CollectableInventory, from_slot: int, to_inventory: CollectableInventory, to_slot: int, from_id: String, from_qty: int, to_id: String, to_qty: int) -> void:
	# If target slot is empty, move the stack
	if to_id == EMPTY_SLOT_ID:
		to_inventory._set_slot(to_slot, from_id, from_qty)
		from_inventory._set_slot(from_slot, EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY)
	# If same item type, merge stacks up to stack limit
	elif to_id == from_id:
		_merge_stacks(from_inventory, from_slot, to_inventory, to_slot, from_id, from_qty, to_qty)
	# If different item types, swap the stacks (if both are allowed in their new inventories)
	else:
		_swap_stacks(from_inventory, from_slot, to_inventory, to_slot, from_id, from_qty, to_id, to_qty)

## Merge two stacks of the same item type
func _merge_stacks(from_inventory: CollectableInventory, from_slot: int, to_inventory: CollectableInventory, to_slot: int, item_id: String, from_qty: int, to_qty: int) -> void:
	var collectable = CollectableManager.get_info(item_id)
	var stack_limit = collectable.stack_limit
	var total = from_qty + to_qty
	var new_to_qty = min(total, stack_limit)
	var overflow = total - new_to_qty
	
	to_inventory._set_slot(to_slot, item_id, new_to_qty)
	if overflow > 0:
		from_inventory._set_slot(from_slot, item_id, overflow)
	else:
		from_inventory._set_slot(from_slot, EMPTY_SLOT_ID, EMPTY_SLOT_QUANTITY)

## Swap stacks between two slots
func _swap_stacks(from_inventory: CollectableInventory, from_slot: int, to_inventory: CollectableInventory, to_slot: int, from_id: String, from_qty: int, to_id: String, to_qty: int) -> void:
	if from_inventory.is_allowed(to_id):
		to_inventory._set_slot(to_slot, from_id, from_qty)
		from_inventory._set_slot(from_slot, to_id, to_qty)
