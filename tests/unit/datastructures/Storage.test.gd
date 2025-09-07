extends VestTest

var storage: Storage

func before_case(_case):
	storage = Storage.new()

func after_case(_case):
	storage.free()

func test_store_and_retrieve_data():
	var key = "test_key"
	var value = "test_value"
	storage.set_item(key, value)
	var retrieved_value = storage.get_item(key)
	expect_equal(retrieved_value, value, "Should retrieve the stored value")

func test_retrieve_nonexistent_key():
	var key = "nonexistent_key"
	var retrieved_value = storage.get_item(key)
	expect_null(retrieved_value, "Should return null for a nonexistent key")

func test_clear_storage():
	var key = "test_key"
	var value = "test_value"
	storage.set_item(key, value)
	storage.delete_item(key)
	var retrieved_value = storage.get_item(key)
	expect_null(retrieved_value, "Should delete the stored data")

func test_has_key():
	var key = "test_key"
	var value = "test_value"
	storage.set_item(key, value)
	expect_true(storage.has_item(key), "Should return true for an existing key")
	expect_false(storage.has_item("nonexistent_key"), "Should return false for a nonexistent key")

func test_is_empty():
	expect_true(storage.is_empty(), "New storage should be empty")
	storage.set_item("test_key", "test_value")
	expect_false(storage.is_empty(), "Storage with items should not be empty")
	storage.delete_item("test_key")
	expect_true(storage.is_empty(), "Storage should be empty after deleting all items")
