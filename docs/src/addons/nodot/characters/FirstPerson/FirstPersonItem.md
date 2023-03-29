# FirstPersonItem extends Nodot3D

## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[activated](#activated)|||
|[deactivated](#deactivated)|||

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[active](#active)|`undefined`|`false`|
|[mesh](#mesh)|`Mesh`|-|
|[hitscan_node](#hitscan_node)|`HitScan3D`|-|
|[projectile_emitter_node](#projectile_emitter_node)|`ProjectileEmitter3D`|-|
|[ironsight_node](#ironsight_node)|`FirstPersonIronSight`|-|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[activate](#activate)|||
|[deactivate](#deactivate)|||
|[action](#action)|||
|[zoom](#zoom)|||
|[zoomout](#zoomout)|||
|[reload](#reload)|||
|[connect_magazine](#connect_magazine)|||

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

### active

```gdscript
@export var active = false
```

If the weapon is visible or not

|Name|Type|Default|
|:-|:-|:-|
|`active`|`undefined`|`false`|

### mesh

```gdscript
@export var mesh: Mesh
```

(optional) The mesh of the weapon

|Name|Type|Default|
|:-|:-|:-|
|`mesh`|`Mesh`|-|

### hitscan_node

```gdscript
@export var hitscan_node: HitScan3D
```

(optional) A hitscan node

|Name|Type|Default|
|:-|:-|:-|
|`hitscan_node`|`HitScan3D`|-|

### projectile_emitter_node

```gdscript
@export var projectile_emitter_node: ProjectileEmitter3D
```

(optional) A project emitter node

|Name|Type|Default|
|:-|:-|:-|
|`projectile_emitter_node`|`ProjectileEmitter3D`|-|

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

