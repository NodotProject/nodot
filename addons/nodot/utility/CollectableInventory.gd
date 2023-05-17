## An inventory for collectables
class_name CollectableInventory extends Nodot

## Enable the inventory
@export var enabled: bool = true
## The maximum number of slots/stacks in the inventory (0 for infinite)
@export var capacity: int = 25
## The maximum weight of the inventory (0 for infinite)
@export var max_weight: float = 20.0

## Triggered when a stack or slot is updated
signal collectable_added(index: int, collectable_id: String, quantity: int)
## Triggered when the inventory overflows (useful to spawn excess items back into the world)
signal overflow(collectable_id: String, quantity: int)
## Triggered when the inventory is too heavy
signal max_weight_reached
## Triggered when the capacity is reached
signal capacity_reached

# Array of tuples. Collectable id (string) and quantity (int)
var collectable_stacks: Array = []


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
		var slot_updated = update_available_slot(collectable_id, remaining_quantity)
		if slot_updated:
			return true
	elif remaining_quantity == 0:
		return true
		
	
	emit_signal("overflow", remaining_quantity)
	emit_signal("capacity_reached")
	return false


## Get the total weight of the inventory
func get_total_weight(additional_weight: float = 0.0):
	var total_weight = 0
	for stack in collectable_stacks:
		var id = stack[0]
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
func update_available_slot(collectable_id: String, quantity: int) -> bool:
	if quantity <= 0: return true
	
	var available_slot
	
	# Get first empty slot
	for i in range(collectable_stacks.size()):
		var stored_stack = collectable_stacks[i]
		var stored_stack_quantity = stored_stack[1]
		if stored_stack_quantity == 0:
			available_slot = i

	# Get unused slot
	if collectable_stacks.size() < capacity:
		available_slot = collectable_stacks.size()
		
	if available_slot != null:
		var collectable = CollectableManager.get_info(collectable_id)
		var new_quantity = quantity
		if quantity > collectable.stack_limit:
			new_quantity = collectable.stack_limit
			update_available_slot(collectable_id, quantity - new_quantity)
		if available_slot in collectable_stacks:
			collectable_stacks[available_slot] = [collectable_id, new_quantity]
		else:
			collectable_stacks.append([collectable_id, new_quantity])
		emit_signal("collectable_added", available_slot, collectable_id, new_quantity)
		return true
	return false

## Get a total count of all items of a specific type
func get_collectable_count(collectable_id: String) -> int:
	return collectable_stacks.reduce(func (accum, stack):
		if stack[0] == collectable_id:
			return accum + stack[1]
		return accum
	, 0)
	
