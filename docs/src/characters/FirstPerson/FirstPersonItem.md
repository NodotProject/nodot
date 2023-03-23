# FirstPersonItem extends Nodot3D

## Table of contents

### Signals

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[ironsight_node](#ironsight_node)|`FirstPersonIronSight`|-|

### Functions

|Name|Type|Default|
|:-|:-|:-|

## Signals

### activated

```gdscript
signal activated
```

Triggered when the item is activated

### deactivated

```gdscript
signal deactivated
```

Triggered when the item is deactivated

## Variables

### ironsight_node

```gdscript
var ironsight_node: FirstPersonIronSight
```

Not exported as FirstPersonIronSight must be a child node of the FirstPersonItem

|Name|Type|Default|
|:-|:-|:-|
|`ironsight_node`|`FirstPersonIronSight`|-|

## Functions

### activate

```gdscript
func activate()
```

Async function to activate the weapon. i.e animate it onto the screen.

### deactivate

```gdscript
func deactivate()
```

Async function to deactivate the weapon. i.e animate it off of the screen.

### action

```gdscript
func action()
```

Triggered when the item is fired (i.e on left click to fire weapon)

### zoom

```gdscript
func zoom()
```

Triggered when the zoom/ironsight button is pressed

### zoomout

```gdscript
func zoomout()
```

Triggered when the zoom/ironsight button is released

### reload

```gdscript
func reload()
```

Triggered when the player requests that the item be reloaded

### connect_magazine

```gdscript
func connect_magazine()
```

Connect the magazine events to the hitscan node




