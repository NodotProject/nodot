# FirstPersonViewport extends SubViewportContainer

## Table of contents

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[next_item](#next_item)|||
|[previous_item](#previous_item)|||
|[get_active_item](#get_active_item)|||
|[get_all_items](#get_all_items)|||
|[change_item](#change_item)|`int`|-|

## Functions

### next_item

```gdscript
func next_item() -> void
```

Select the next item

### previous_item

```gdscript
func previous_item() -> void
```

Select the previous item

### get_active_item

```gdscript
func get_active_item()
```

Get the active item if there is one TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162

### get_all_items

```gdscript
func get_all_items() -> Array[FirstPersonItem]
```

Get all FirstPersonItems

**Returns**: `Array[FirstPersonItem]`

### change_item

```gdscript
func change_item(new_index: int) -> void
```

Change which item is active.

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`new_index`|`int`|-|

