extends GutTest

var unique_set: UniqueSet

func before_each():
	unique_set = UniqueSet.new()
	add_child_autofree(unique_set)

func test_add_unique_item():
	unique_set.add("item1")
	assert_true(unique_set.has("item1"), "Should add unique item")
	assert_eq(unique_set.get_size(), 1, "Size should be 1 after adding item")

func test_add_duplicate_item():
	unique_set.add("item1")
	unique_set.add("item1")
	assert_eq(unique_set.get_size(), 1, "Should not add duplicate item")

func test_remove_item():
	unique_set.add("item1")
	unique_set.remove("item1")
	assert_false(unique_set.has("item1"), "Should remove item")
	assert_eq(unique_set.get_size(), 0, "Size should be 0 after removal")

func test_has_item():
	unique_set.add("item1")
	assert_true(unique_set.has("item1"), "Should return true for existing item")
	assert_false(unique_set.has("item2"), "Should return false for non-existent item")

func test_get_next_item():
	unique_set.add("item1")
	unique_set.add("item2")
	unique_set.add("item3")
	
	assert_eq(unique_set.get_next_item(), "item1", "First item should be item1")
	assert_eq(unique_set.get_next_item(), "item2", "Next item should be item2")
	assert_eq(unique_set.get_next_item(), "item3", "Next item should be item3")
	assert_eq(unique_set.get_next_item(), "item1", "Should wrap around to first item")

func test_get_size():
	assert_eq(unique_set.get_size(), 0, "Initial size should be 0")
	unique_set.add("item1")
	assert_eq(unique_set.get_size(), 1, "Size should be 1 after adding item")
	unique_set.add("item2")
	assert_eq(unique_set.get_size(), 2, "Size should be 2 after adding another item")
	unique_set.remove("item1")
	assert_eq(unique_set.get_size(), 1, "Size should be 1 after removing item")

func test_signals():
	watch_signals(unique_set)
	
	unique_set.add("item1")
	assert_signal_emitted(unique_set, "item_added", "Should emit item_added signal")
	assert_signal_emitted(unique_set, "items_updated", "Should emit items_updated signal")
	
	unique_set.remove("item1")
	assert_signal_emitted(unique_set, "item_removed", "Should emit item_removed signal")
	assert_signal_emitted(unique_set, "items_updated", "Should emit items_updated signal")
