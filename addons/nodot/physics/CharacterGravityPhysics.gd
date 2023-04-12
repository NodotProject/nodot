## Add gravity to the parent character
class_name CharacterGravityPhysics extends Nodot

@export var gravity : float = 9.8 ## Gravity strength

@onready var parent: CharacterBody3D = get_parent()

func _physics_process(delta: float) -> void:
  if not parent.is_on_floor():
    parent.velocity.y -= gravity * delta
