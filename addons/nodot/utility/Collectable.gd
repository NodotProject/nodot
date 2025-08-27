class_name Collectable extends Resource

## The icon of the collectable.
@export var icon: Texture2D
## The sound effect when picking up the item
@export var pickup_sfx: AudioStream
## The collectables name.
@export var display_name: String = "Item"
## The collectables description.
@export var description: String = "A collectable item."
## Maximum stack count
@export var stack_limit: int = 1
## The weight of the collectable.
@export var mass: float = 0.1
## The in-game value of the item (-1 for not tradable)
@export var value: int
## Use item_groups to categorize your items
@export var item_groups: Array[String] = []
## The scene for this collactable
@export var scene: PackedScene
