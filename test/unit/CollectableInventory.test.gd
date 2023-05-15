extends GutTest

var inventory: CollectableInventory
var apple: RigidCollectable3D

func before_all():
	pass
	
func before_each():
	inventory = CollectableInventory.new()

# Add a collectable and check it exists in the inventory according to a stack_limit of 1
func test_add_collectable():
	apple = RigidCollectable3D.new()
	apple.display_name = "apple"
	CollectableManager.add(apple)
	
	inventory.add("apple", 2)
	assert_eq(inventory.collectable_stacks[0], ["apple", 1])
	assert_eq(inventory.collectable_stacks[1], ["apple", 1])

# Add a collectable and check it gets added to the existing stack

func after_all():
	apple.free()
	inventory.free()
