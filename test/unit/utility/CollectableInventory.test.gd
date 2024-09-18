extends GutTest

var inventory: CollectableInventory
var apple: RigidCollectable3D

func before_all():
	pass
	
func before_each():
	CollectableManager.clear()
	inventory = CollectableInventory.new()

# Add a collectable and check it exists in the inventory according to a stack_limit of 1
func test_add_collectable():
	apple = RigidCollectable3D.new()
	apple.display_name = "apple"
	CollectableManager.add(apple)
	
	inventory.add("apple", 2)
	assert_eq(inventory.collectable_stacks[0], ["apple", 1])
	assert_eq(inventory.collectable_stacks[1], ["apple", 1])

# Add a collectable and check it gets added as a stack
func test_add_stackable_collectable():
	apple = RigidCollectable3D.new()
	apple.display_name = "apple"
	apple.stack_limit = 2
	CollectableManager.add(apple)
	
	inventory.add("apple", 1)
	inventory.add("apple", 2)
	inventory.add("apple", 4)
	assert_eq(inventory.collectable_stacks[0], ["apple", 2])
	assert_eq(inventory.collectable_stacks[1], ["apple", 2])
	assert_eq(inventory.collectable_stacks[2], ["apple", 2])
	assert_eq(inventory.collectable_stacks[3], ["apple", 1])
	
# Can handle when there are no stacks left
func test_handle_stacks_full():
	apple = RigidCollectable3D.new()
	apple.display_name = "apple"
	CollectableManager.add(apple)
	inventory.capacity = 1
	inventory.collectable_stacks = [["apple", 1]]
	
	inventory.add("apple", 1)
	assert_eq(inventory.collectable_stacks[0], ["apple", 1])
	assert_false(1 in inventory.collectable_stacks)
	
# Can handle when there are no slots left
func test_handle_slots_full():
	apple = RigidCollectable3D.new()
	apple.display_name = "apple"
	CollectableManager.add(apple)
	inventory.capacity = 1
	
	inventory.add("apple", 2)
	assert_eq(inventory.collectable_stacks[0], ["apple", 1])
	assert_false(1 in inventory.collectable_stacks)

func after_all():
	apple.free()
	inventory.free()
