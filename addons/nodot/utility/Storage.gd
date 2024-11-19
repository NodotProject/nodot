@icon("../icons/storage.svg")
## Redis-like class to store key-value pairs
class_name Storage extends Nodot

## Dictionary to store key-value pairs
@export var data: Dictionary = {}

signal value_changed(key, new_value)
signal key_deleted(key)

## Method to set a value for a given key
func set_item(key: Variant, value: Variant):
	data[key] = value
	value_changed.emit(key, value)
	if key is String:
		_emit_signal(key, value)

## Method to get the value for a given key
func get_item(key: Variant):
	return data.get(key)

## Method to check if a key exists
func has_item(key: Variant):
	return data.has(key)

## Method to delete a key-value pair
func delete_item(key: Variant):
	if has_item(key):
		var value = data[key]
		data.erase(key)
		key_deleted.emit(key)
		if key is String:
			_emit_signal(key, null)
		
## Method returns whether there are any keys in the Storage
func is_empty():
	return data.is_empty()

## Add a signal for a specific key
func add_signal(signal_name: String):
	if not has_user_signal(signal_name):
		add_user_signal(signal_name, [{ "name": "value", "type": TYPE_OBJECT }])

## Emit a signal for a specific key
func _emit_signal(signal_name: String, arg: Variant = null):
	add_signal(signal_name)
	emit_signal(signal_name, arg)
