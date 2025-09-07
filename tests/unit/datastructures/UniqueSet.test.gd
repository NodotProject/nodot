extends VestTest

var unique_set: UniqueSet

func before_case(_case):
	unique_set = UniqueSet.new()

func test_add_unique_item():
	unique_set.add("item1")
	expect_true(unique_set.has("item1"), "Should add unique item")
	expect_equal(unique_set.get_size(), 1, "Size should be 1 after adding item")

func test_add_duplicate_item():
	unique_set.add("item1")
	unique_set.add("item1")
	expect_equal(unique_set.get_size(), 1, "Should not add duplicate item")

func test_remove_item():
	unique_set.add("item1")
	unique_set.remove("item1")
	expect_false(unique_set.has("item1"), "Should remove item")
	expect_equal(unique_set.get_size(), 0, "Size should be 0 after removal")

func test_has_item():
	unique_set.add("item1")
	expect_true(unique_set.has("item1"), "Should return true for existing item")
	expect_false(unique_set.has("item2"), "Should return false for non-existent item")

func test_get_next_item():
	unique_set.add("item1")
	unique_set.add("item2")
	unique_set.add("item3")
	
	expect_equal(unique_set.get_next_item(), "item1", "First item should be item1")
	expect_equal(unique_set.get_next_item(), "item2", "Next item should be item2")
	expect_equal(unique_set.get_next_item(), "item3", "Next item should be item3")
	expect_equal(unique_set.get_next_item(), "item1", "Should wrap around to first item")

func test_get_size():
	expect_equal(unique_set.get_size(), 0, "Initial size should be 0")
	unique_set.add("item1")
	expect_equal(unique_set.get_size(), 1, "Size should be 1 after adding item")
	unique_set.add("item2")
	expect_equal(unique_set.get_size(), 2, "Size should be 2 after adding another item")
	unique_set.remove("item1")
	expect_equal(unique_set.get_size(), 1, "Size should be 1 after removing item")

func test_signals():
	capture_signal(unique_set.item_added, 1)
	capture_signal(unique_set.item_removed, 1)
	capture_signal(unique_set.items_updated)

	unique_set.add("item1")
	expect_equal(get_signal_emissions(unique_set.item_added).size(), 1)
	expect_equal(get_signal_emissions(unique_set.items_updated).size(), 1)
	
	unique_set.remove("item1")
	expect_equal(get_signal_emissions(unique_set.item_removed).size(), 1)
	expect_equal(get_signal_emissions(unique_set.items_updated).size(), 2)
