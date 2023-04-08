# Interaction3D extends RayCast3D

## Table of contents

### Signals

|Name|Type|Default|
|:-|:-|:-|
|[carry_started](#carry_started)|`Node3D`|-|
|[carry_ended](#carry_ended)|`Node3D`|-|
|[interacted](#interacted)|`Node3D`|-|

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[interact_action](#interact_action)|`String`|`"interact"`|
|[font_color](#font_color)|`Color`|`Color.WHITE`|
|[font_size](#font_size)|`int`|`18`|
|[enable_pickup](#enable_pickup)|`bool`|`true`|
|[max_mass](#max_mass)|`float`|`10.0`|
|[carry_distance](#carry_distance)|`float`|`2.0`|

## Signals

### carry_started

```gdscript
signal carry_started(carried_node: Node3D)
```

Triggered when starting to carry an object

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`carried_node`|`Node3D`|-|

### carry_ended

```gdscript
signal carry_ended(carried_node: Node3D)
```

Triggered when dropping an object that was being carried

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`carried_node`|`Node3D`|-|

### interacted

```gdscript
signal interacted(interacted_node: Node3D)
```

Triggered when the interact function on an object was fired

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`interacted_node`|`Node3D`|-|

## Variables

### interact_action

```gdscript
@export var interact_action: String = "interact"
```

The interact input action name

|Name|Type|Default|
|:-|:-|:-|
|`interact_action`|`String`|`"interact"`|

### font_color

```gdscript
@export var font_color : Color = Color.WHITE
```

The font color of the interaction label

|Name|Type|Default|
|:-|:-|:-|
|`font_color`|`Color`|`Color.WHITE`|

### font_size

```gdscript
@export var font_size : int = 18
```

The font size of the interaction label

|Name|Type|Default|
|:-|:-|:-|
|`font_size`|`int`|`18`|

### enable_pickup

```gdscript
@export var enable_pickup: bool = true
```

Enable the pick up functionality

|Name|Type|Default|
|:-|:-|:-|
|`enable_pickup`|`bool`|`true`|

### max_mass

```gdscript
@export var max_mass: float = 10.0
```

The maximum mass (weight) that can be carried

|Name|Type|Default|
|:-|:-|:-|
|`max_mass`|`float`|`10.0`|

### carry_distance

```gdscript
@export var carry_distance: float = 2.0
```

The distance away from the raycast origin to carry the object

|Name|Type|Default|
|:-|:-|:-|
|`carry_distance`|`float`|`2.0`|

