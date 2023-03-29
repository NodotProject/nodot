# BulletHole extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[textures](#textures)|`Array[StandardMaterial3D]`|-|
|[random_rotation](#random_rotation)|`bool`|`true`|
|[lifespan](#lifespan)|`float`|`20.0`|
|[sfx_player](#sfx_player)|`SFXPlayer3D`|-|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[action](#action)|`HitTarget`|-|

## Variables

### textures

```gdscript
@export var textures: Array[StandardMaterial3D]
```

An array of StandardMaterial3Ds to use as the bullethole decal. The material index can be retrieved from the target nodes "physical_material" property. The first material is the fallback default.

|Name|Type|Default|
|:-|:-|:-|
|`textures`|`Array[StandardMaterial3D]`|-|

### random_rotation

```gdscript
@export var random_rotation : bool = true
```

Randomly rotate the decal

|Name|Type|Default|
|:-|:-|:-|
|`random_rotation`|`bool`|`true`|

### lifespan

```gdscript
@export var lifespan : float = 20.0
```

Seconds before the bullet hole is removed. (0.0 to keep forever)

|Name|Type|Default|
|:-|:-|:-|
|`lifespan`|`float`|`20.0`|

### sfx_player

```gdscript
@export var sfx_player: SFXPlayer3D
```

For playing a sound when created

|Name|Type|Default|
|:-|:-|:-|
|`sfx_player`|`SFXPlayer3D`|-|

## Functions

### action

```gdscript
func action(hit_target: HitTarget) -> void
```

Creates a bullethole decale, applies the texture and rotation/position calculations and removes the bullethole after the lifespan

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`hit_target`|`HitTarget`|-|

