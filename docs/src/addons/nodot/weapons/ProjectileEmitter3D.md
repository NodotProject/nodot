# ProjectileEmitter3D extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`true`|
|[accuracy](#accuracy)|`float`|`0.0`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[aim_emitter](#aim_emitter)|||
|[action](#action)|||

## Variables

### enabled

```gdscript
@export var enabled = true
```

Whether to enable the projectile emitter or not

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`undefined`|`true`|

### accuracy

```gdscript
@export var accuracy := 0.0
```

The accuracy of the emission (0.0 = emit with 100% accuracy, 50.0 = emit in any forward direction, 100.0 = emit in any direction)

|Name|Type|Default|
|:-|:-|:-|
|`accuracy`|`float`|`0.0`|

## Functions

### aim_emitter

```gdscript
func aim_emitter()
```

Apply the accuracy to the emitter

### action

```gdscript
func action()
```

Execute the emitter

