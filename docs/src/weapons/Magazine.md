# Magazine extends Nodot

## Table of contents

### Signals

### Functions

|Name|Type|Default|
|:-|:-|:-|
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




