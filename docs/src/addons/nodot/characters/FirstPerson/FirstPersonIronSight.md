# FirstPersonIronSight extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`true`|
|[zoom_speed](#zoom_speed)|`float`|`10.0`|
|[fov](#fov)|`int`|`75`|
|[enable_scope](#enable_scope)|`undefined`|`false`|
|[scope_texture](#scope_texture)|`Texture2D`|-|
|[scope_fov](#scope_fov)|`int`|`45`|

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
@export var enabled := true
```

Whether ironsight zoom is allowed

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`undefined`|`true`|

### zoom_speed

```gdscript
@export var zoom_speed := 10.0
```

The speed to move the camera to the ironsight location

|Name|Type|Default|
|:-|:-|:-|
|`zoom_speed`|`float`|`10.0`|

### fov

```gdscript
@export var fov := 75
```

The ironsight field of view

|Name|Type|Default|
|:-|:-|:-|
|`fov`|`int`|`75`|

### enable_scope

```gdscript
@export var enable_scope := false
```

Whether to enable a scope view after ironsight zoom is complete

|Name|Type|Default|
|:-|:-|:-|
|`enable_scope`|`undefined`|`false`|

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
@export var scope_fov := 45
```

The scope field of view

|Name|Type|Default|
|:-|:-|:-|
|`scope_fov`|`int`|`45`|

## Functions

### zoom

```gdscript
func zoom()
```

Initiates the ironsight zoom and shows scope when it approximately reaches its destination

### zoomout

```gdscript
func zoomout()
```

Initiates ironsight zoom out

### scope

```gdscript
func scope()
```

Show the scope image and set the field of view

### unscope

```gdscript
func unscope()
```

Hide the scope image and reset the field of view

### deactivate

```gdscript
func deactivate()
```

Restores all states to default

