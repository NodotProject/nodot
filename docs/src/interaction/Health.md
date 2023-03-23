# Health extends Nodot





## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[health_lost](#health_lost)|`int`|-|
|[health_gained](#health_gained)|`int`|-|
|[health_changed](#health_changed)|`int`|-|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[set_health](#set_health)|`int`|-|

## Signals

### health_depleted

```gdscript
signal health_depleted
```

current_health has reached zero

### health_lost

```gdscript
signal health_lost(old_health: int, new_health: int)
```

current_health has been reduced

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`int`|-|
|`new_health`|`int`|-|

### health_gained

```gdscript
signal health_gained(old_health: int, new_health: int)
```

current_health has been increased

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`int`|-|
|`new_health`|`int`|-|

### health_changed

```gdscript
signal health_changed(old_health: int, new_health: int)
```

current_health has changed

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`int`|-|
|`new_health`|`int`|-|

## Functions

### set_health

```gdscript
func set_health(modifier: int)
```

Offsets current_health by the modifier

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`modifier`|`int`|-|




