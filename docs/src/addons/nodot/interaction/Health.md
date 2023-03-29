# Health extends Nodot

## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[health_depleted](#health_depleted)|||
|[health_lost](#health_lost)|`int`|-|
|[health_gained](#health_gained)|`int`|-|
|[health_changed](#health_changed)|`int`|-|

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[max_health](#max_health)|`int`|`100`|
|[current_health](#current_health)|`undefined`|`max_health`|

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

## Variables

### max_health

```gdscript
@export var max_health := 100
```

The maximum health

|Name|Type|Default|
|:-|:-|:-|
|`max_health`|`int`|`100`|

### current_health

```gdscript
@export var current_health := max_health
```

The current health

|Name|Type|Default|
|:-|:-|:-|
|`current_health`|`undefined`|`max_health`|

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

