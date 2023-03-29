# Magazine extends Nodot

## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[magazine_depleted](#magazine_depleted)|||
|[supply_depleted](#supply_depleted)|||
|[reloading](#reloading)|||
|[discharged](#discharged)|||

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[capacity](#capacity)|`int`|`10`|
|[supply_count](#supply_count)|`int`|`20`|
|[supply_count_limit](#supply_count_limit)|`int`|`100`|
|[discharge_count](#discharge_count)|`int`|`1`|
|[fire_rate](#fire_rate)|`float`|`0.5`|
|[reload_time](#reload_time)|`float`|`1.0`|
|[auto_reload](#auto_reload)|`undefined`|`true`|
|[rounds_left](#rounds_left)|`undefined`|`capacity`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[action](#action)|||
|[reload](#reload)|||
|[resupply](#resupply)|`int`|-|

## Signals

### magazine_depleted

```gdscript
signal magazine_depleted
```

Emitted when there are no rounds left in the chamber

### supply_depleted

```gdscript
signal supply_depleted
```

Emitted when there is no supply left at all

### reloading

```gdscript
signal reloading
```

Emitted when the magazine begins reloading

### discharged

```gdscript
signal discharged
```

Emitted when a round is discharged

## Variables

### capacity

```gdscript
@export var capacity := 10
```

Total rounds per magazine

|Name|Type|Default|
|:-|:-|:-|
|`capacity`|`int`|`10`|

### supply_count

```gdscript
@export var supply_count := 20
```

Rounds available other than the loaded rounds

|Name|Type|Default|
|:-|:-|:-|
|`supply_count`|`int`|`20`|

### supply_count_limit

```gdscript
@export var supply_count_limit := 100
```

Round supply maximum

|Name|Type|Default|
|:-|:-|:-|
|`supply_count_limit`|`int`|`100`|

### discharge_count

```gdscript
@export var discharge_count := 1
```

Total rounds released per action

|Name|Type|Default|
|:-|:-|:-|
|`discharge_count`|`int`|`1`|

### fire_rate

```gdscript
@export var fire_rate := 0.5
```

Time between round releases

|Name|Type|Default|
|:-|:-|:-|
|`fire_rate`|`float`|`0.5`|

### reload_time

```gdscript
@export var reload_time := 1.0
```

Time to reload the magazine

|Name|Type|Default|
|:-|:-|:-|
|`reload_time`|`float`|`1.0`|

### auto_reload

```gdscript
@export var auto_reload := true
```

Automatically reloads the weapon when ammo has depleted and the player attempts to fire

|Name|Type|Default|
|:-|:-|:-|
|`auto_reload`|`undefined`|`true`|

### rounds_left

```gdscript
@export var rounds_left := capacity
```

Number of rounds currently loaded

|Name|Type|Default|
|:-|:-|:-|
|`rounds_left`|`undefined`|`capacity`|

## Functions

### action

```gdscript
func action()
```

Dispatches a round

### reload

```gdscript
func reload()
```

Initiates a reload of the magazine

### resupply

```gdscript
func resupply(amount: int) -> int
```

Adds rounds to the supply and returns rejected rounds if the supply_count_limit has been reached

**Returns**: `int`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`amount`|`int`|-|

