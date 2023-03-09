class_name GravityPhysics extends Nodot

## Add gravity to the parent object

@export var gravity := 9.8 ## Gravity strength

@onready var parent = get_parent()

func _physics_process(delta):
  if not parent.is_on_floor():
    parent.velocity.y -= gravity * delta
