# FirstPersonIronSight extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`bool`|`true`|
|[zoom_speed](#zoom_speed)|`float`|`10.0`|
|[fov](#fov)|`float`|`75.0`|
|[enable_scope](#enable_scope)|`bool`|`false`|
|[scope_texture](#scope_texture)|`Texture2D`|-|
|[scope_fov](#scope_fov)|`float`|`45.0`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[zoom](#zoom)|||
|[zoomout](#zoomout)|||
|[scope](#scope)|||
|[unscope](#unscope)|||
|[deactivate](#deactivate)|||

## Variables

### enabled

```gdscript
@export var enabled : bool = true
```

Whether ironsight zoom is allowed

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`bool`|`true`|

### zoom_speed

```gdscript
@export var zoom_speed : float = 10.0
```

The speed to move the camera to the ironsight location

|Name|Type|Default|
|:-|:-|:-|
|`zoom_speed`|`float`|`10.0`|

### fov

```gdscript
@export var fov : float = 75.0
```

The ironsight field of view

|Name|Type|Default|
|:-|:-|:-|
|`fov`|`float`|`75.0`|

### enable_scope

```gdscript
@export var enable_scope : bool = false
```

Whether to enable a scope view after ironsight zoom is complete

|Name|Type|Default|
|:-|:-|:-|
|`enable_scope`|`bool`|`false`|

### scope_texture

```gdscript
@export var scope_texture: Texture2D
```

The scope texture that will cover the screen

|Name|Type|Default|
|:-|:-|:-|
|`scope_texture`|`Texture2D`|-|

### scope_fov

```gdscript
@export var scope_fov : float = 45.0
```

The scope field of view

|Name|Type|Default|
|:-|:-|:-|
|`scope_fov`|`float`|`45.0`|

## Functions

### zoom

```gdscript
func zoom() -> void
```

Initiates the ironsight zoom and shows scope when it approximately reaches its destination

### zoomout

```gdscript
func zoomout() -> void
```

Initiates ironsight zoom out

### scope

```gdscript
func scope() -> void
```

Show the scope image and set the field of view

### unscope

```gdscript
func unscope() -> void
```

Hide the scope image and reset the field of view

### deactivate

```gdscript
func deactivate() -> void
```

Restores all states to default

