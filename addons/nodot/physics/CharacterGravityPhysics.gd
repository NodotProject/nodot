## Add gravity to the parent character
class_name CharacterGravityPhysics extends Nodot

## Gravity strength
@export var gravity : float = 9.8
## Gravity strength while submerged
@export var submerged_gravity : float = 0.3

@onready var parent: CharacterBody3D = get_parent()

var is_submerged: bool = false

func _ready():
  parent.connect("submerged", submerge)
  parent.connect("surfaced", surface)
  
func _physics_process(delta: float) -> void:
  if is_submerged:
    parent.velocity.y -= submerged_gravity * delta
  else:
    if not parent.is_on_floor():
      parent.velocity.y -= gravity * delta

## Change to submerge controls
func submerge():
  is_submerged = true

## Change back to normal controls
func surface():
  is_submerged = false
