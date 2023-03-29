# Health extends Nodot

## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[health_depleted](#health_depleted)|||
|[health_lost](#health_lost)|`float`|-|
|[health_gained](#health_gained)|`float`|-|
|[health_changed](#health_changed)|`float`|-|

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[max_health](#max_health)|`float`|`100.0`|
|[current_health](#current_health)|`float`|`max_health`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[set_health](#set_health)|`float`|-|

## Signals

### health_depleted

```gdscript
signal health_depleted
```

current_health has reached zero

### health_lost

```gdscript
signal health_lost(old_health: float, new_health: float)
```

current_health has been reduced

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`float`|-|
|`new_health`|`float`|-|

### health_gained

```gdscript
signal health_gained(old_health: float, new_health: float)
```

current_health has been increased

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`float`|-|
|`new_health`|`float`|-|

### health_changed

```gdscript
signal health_changed(old_health: float, new_health: float)
```

current_health has changed

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`old_health`|`float`|-|
|`new_health`|`float`|-|

## Variables

### max_health

```gdscript
@export var max_health : float = 100.0
```

The maximum health

|Name|Type|Default|
|:-|:-|:-|
|`max_health`|`float`|`100.0`|

### current_health

```gdscript
@export var current_health : float = max_health
```

The current health

|Name|Type|Default|
|:-|:-|:-|
|`current_health`|`float`|`max_health`|

## Functions

### set_health

```gdscript
func set_health(modifier: float) -> void
```

Offsets current_health by the modifier

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`modifier`|`float`|-|

