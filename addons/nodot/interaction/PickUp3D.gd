## A raycast for picking up, carrying and re-orienting objects
@tool
class_name PickUp3D extends RayCast3D

## The interact input action name
@export var pickup_action: String = "interact"
## The maximum mass (weight) that can be carried
@export var max_mass: float = 10.0
## The distance away from the raycast origin to carry the object
@export var carry_distance: float = 2.0

# RigidBody3D or null
var carried_body

func _input(event: InputEvent):
  if event.is_action_pressed(pickup_action):
    if is_instance_valid(carried_body):
      carried_body.gravity_scale = 1.0
      carried_body = null
    else:
      var collider = get_collider()
      if collider is RigidBody3D:
        if collider.mass <= max_mass:
          carried_body = collider
          carried_body.gravity_scale = 0.0

func _physics_process(delta):
  if is_instance_valid(carried_body):
    var spawn_position = global_transform.origin
    spawn_position -= global_transform.basis.z.normalized() * carry_distance
    carried_body.global_transform.origin = lerp(carried_body.global_transform.origin, spawn_position, 10.0 * delta)
    carried_body.rotation = lerp(carried_body.rotation, Vector3.ZERO, 10.0 * delta)
