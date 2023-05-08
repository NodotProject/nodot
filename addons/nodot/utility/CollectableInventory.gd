## An inventory for collectables
class_name CollectableInventory extends Nodot

## Enable the inventory
@export var enabled: bool = true
## The maximum number of slots/stacks in the inventory (0 for infinite)
@export var capacity: int = 25
## The maximum weight of the inventory (0 for infinite)
@export var max_weight: float = 20.0

signal collectable_added(index: int, collectable_id: String, quantity: int)

# Array of tuples. Collectable id (string) and quantity (int)
var collectable_stacks: Array = []
# Collectables that can't fit in storage
var overflow: Array = []

## Add a collectable to the inventory
func add(collectable_id: String, quantity: int):
	var collectable = CollectableManager.get(collectable_id)
	var weight = collectable.weight

	# Check that we have weight left
	if max_weight > 0.0:
		var stack_weight = quantity * weight
		var total = get_total_weight(stack_weight)
		if total > max_weight:
			return false
	
	var remaining_quantity = update_available_stack(stack)
	if remaining_quantity > 0:
		var available_slot = get_available_slot()
		if available_slot:
			collectable_stacks[available_slot] = [collectable_id, remaining_quantity]
			emit_signal("collectable_added", available_slot, collectable_id, remaining_quantity)
			return true

	return false


## Get the total weight of the inventory
func get_total_weight(additional_weight: float = 0.0):
	var total_weight = 0
	for stack in collectable_stacks:
		var id = stack[0]
		var quantity = stack[1]
		var collectable = CollectableManager.get(id)
		var weight = collectable.weight
		var stack_weight = quantity * weight
		total_weight += stack_weight
	total_weight += additional_weight
	return total_weight

## Get an available stack for the collectable
func update_available_stack(stack):
	var id = stack[0]
	var quantity = stack[1]

	for i in range(collectable_stacks.size()):
		var stored_stack = collectable_stacks[i]
		var stored_stack_id = stored_stack[0]
		var stored_stack_quantity = stored_stack[1]
		if stored_stack_id == id:
			var collectable = CollectableManager.get(id)
			var available = stored_stack_quantity + quantity
			if available > collectable.max_stack_size:
				collectable_stacks[i][1] = collectable.max_stack_size
				emit_signal("collectable_added", i, id, collectable.max_stack_size)
				get_available_stack(id, available - collectable.max_stack_size)
				return 0
			else:
				collectable_stacks[i][1] = available
				emit_signal("collectable_added", i, id, available)
				return 0
	
	return quantity


## Get available slot
func get_available_slot():
	# Get first empty slot
	for i in range(collectable_stacks.size()):
		var stored_stack = collectable_stacks[i]
		var stored_stack_quantity = stored_stack[1]
		if stored_stack_quantity == 0:
			return i
	
	# Get unused slot
	if collectable_stacks.size() < capacity:
		return collectable_stacks.size()