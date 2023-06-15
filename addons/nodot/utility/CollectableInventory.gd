## An inventory for collectables
class_name CollectableInventory extends Nodot

## Enable the inventory
@export var enabled: bool = true
## The maximum number of slots/stacks in the inventory (0 for infinite)
@export var capacity: int = 25
## The maximum weight of the inventory (0 for infinite)
@export var max_weight: float = 20.0
## A node3d used to position items back into the world
@export var spawn_location_node: Node3D

# Array of tuples. Collectable id (string) and quantity (int)
@export var collectable_stacks: Array = []

## Triggered when a stack or slot is updated
signal collectable_added(index: int, collectable_id: String, quantity: int)
## Triggered when the inventory overflows (useful to spawn excess items back into the world)
signal overflow(collectable_id: String, quantity: int)
## Triggered when the inventory is too heavy
signal max_weight_reached
## Triggered when the capacity is reached
signal capacity_reached

func _enter_tree():
	for i in capacity:
		collectable_stacks.append(["", 0])

## Add a collectable to the inventory
func add(collectable_id: String, quantity: int) -> bool:
	var collectable = CollectableManager.get_info(collectable_id)
	if !collectable:
		push_error("%s has not been registered in CollectableManager" % collectable_id)
		return false
	
	var weight = collectable.mass

	# Check that we have weight left
	if max_weight > 0.0:
		var stack_weight = quantity * weight
		var total = get_total_weight(stack_weight)
		if total > max_weight:
			emit_signal("max_weight_reached")
			return false

	var remaining_quantity = update_available_stack(collectable_id, quantity)
	if remaining_quantity > 0:
		var overflow = update_available_slot(collectable_id, remaining_quantity)
		if overflow > 0:
			return add(collectable_id, overflow)
		else:
			return true
	elif remaining_quantity == 0:
		return true
		
	
	if remaining_quantity > 0:
		emit_signal("overflow", remaining_quantity)
	emit_signal("capacity_reached")
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
	
	var stack_quantity = collectable_stacks[collectable_index][1]
	if stack_quantity >= quantity:
		update_slot(collectable_index, collectable_id, stack_quantity - quantity, 0)
		return true
	if stack_quantity > 0:
		update_slot(collectable_index, collectable_id, 0, 0)
		return remove(collectable_id, quantity - stack_quantity)
	
	return false
	

## Get the total weight of the inventory
func get_total_weight(additional_weight: float = 0.0):
	var total_weight = 0
	for stack in collectable_stacks:
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
func update_available_stack(collectable_id: String, quantity: int):
	for i in range(collectable_stacks.size()):
		var stored_stack = collectable_stacks[i]
		var stored_stack_id = stored_stack[0]
		if stored_stack_id == collectable_id:
			var collectable = CollectableManager.get_info(collectable_id)
			var stored_stack_quantity = stored_stack[1]
			if stored_stack_quantity >= collectable.stack_limit:
				continue
			var available = stored_stack_quantity + quantity
			if available > collectable.stack_limit:
				collectable_stacks[i][1] = collectable.stack_limit
				emit_signal("collectable_added", i, collectable_id, collectable.stack_limit)
				return update_available_stack(collectable_id, available - collectable.stack_limit)
			else:
				collectable_stacks[i][1] = available
				emit_signal("collectable_added", i, collectable_id, available)
				return 0

	return quantity



## Get available slot
func update_available_slot(collectable_id: String, quantity: int) -> int:
	if quantity <= 0: return 0
	
	var available_slot
	
	var current_stack_size = collectable_stacks.size()
	
	# Get first empty slot
	for i in current_stack_size:
		var stored_stack = collectable_stacks[i]
		var stored_stack_quantity = stored_stack[1]
		if stored_stack_quantity == 0:
			available_slot = i
			break
	
	if available_slot == null:
		# TODO: Add a test for when capacity is 0 (infinite)
		if capacity == 0 or current_stack_size < capacity:
			available_slot = current_stack_size
			collectable_stacks.append(["", 0])
		
	if available_slot != null:
		var collectable = CollectableManager.get_info(collectable_id)
		var new_quantity = quantity
		var overflow = 0
		if quantity > collectable.stack_limit:
			new_quantity = collectable.stack_limit
			update_available_slot(collectable_id, quantity - new_quantity)
		overflow = quantity - new_quantity
		collectable_stacks[available_slot] = [collectable_id, new_quantity]
		emit_signal("collectable_added", available_slot, collectable_id, new_quantity)
		return overflow
	
	return 0

## Get the last index of a specific collectable
func get_collectable_index(collectable_id: String):
	for i in collectable_stacks.size():
		var stack = collectable_stacks[i]
		if stack[0] == collectable_id:
			return i
	return -1

## Get a total count of all items of a specific type
func get_collectable_count(collectable_id: String) -> int:
	return collectable_stacks.reduce(func (accum, stack):
		if stack[0] == collectable_id:
			return accum + stack[1]
		return accum
	, 0)
	
## Update a specific slot
func update_slot(slot_index: int, collectable_id: String, quantity: int, _overflow: int):
	if quantity > 0:
		collectable_stacks[slot_index] = [collectable_id, quantity]
		emit_signal("collectable_added", slot_index, collectable_id, quantity)
	else:
		collectable_stacks[slot_index] = ["", 0]
		emit_signal("collectable_added", slot_index, "", 0)

## Drop a slot item back into the real world
func drop_slot(slot_index: int, collectable_id: String, quantity: int):
	collectable_stacks[slot_index] = ["", 0]
	emit_signal("collectable_added", slot_index, "", 0)
	var collectable_info = CollectableManager.get_info(collectable_id)
	if !collectable_info: return
	
	var item_node = collectable_info.node
	for i in quantity:
		var item_instance = item_node.duplicate(15)
		item_instance.top_level = true
		if spawn_location_node:
			spawn_location_node.add_child(item_instance)
		else:
			push_error("No spawn location node set")
	
