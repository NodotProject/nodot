class_name Projectile3D extends RigidBody3D

## The speed of the projectile
@export var speed := 50.0
## Applies the speed consistently
@export var self_propelling := true
## Destroys the projectile after this timespan (0.0 for never)
@export var lifespan := 0.0
## Destroys the projectile on impact
@export var destroy_on_impact := false

signal collision(position: Vector3, rotation: Vector3, colliders: Array[Node3D])
signal timeout(position: Vector3, rotation: Vector3)
signal destroyed(position: Vector3, rotation: Vector3)

var is_editor = Engine.is_editor_hint()
var explosion: Explosion3D

func _enter_tree():
  contact_monitor = true
  max_contacts_reported = 1
  if !is_editor:
    for child in get_children():
      if child is Explosion3D:
        explosion = child
        remove_child(explosion)

func _ready():
  gravity_scale = 1.0 if !self_propelling else 0.0
  
  if lifespan > 0.0:
    await get_tree().create_timer(lifespan).timeout
    emit_signal("timeout", position, rotation)
    destroy()
    
func _physics_process(_delta):
  var force = get_propulsion_force()

  if self_propelling:
    apply_central_force(force)
  
  if destroy_on_impact and get_contact_count() > 0:
    emit_signal("collision", position, rotation, get_colliding_bodies())
    destroy()
    
func propel():
  if !self_propelling:
    apply_central_impulse(get_propulsion_force())

func get_propulsion_force():
  # Get the angle between the rocket's current direction and the desired direction.
  var angle = global_rotation.dot(global_transform.basis[2])

  # Calculate the vector3 of the desired thrust.
  var force = speed * global_transform.basis[2] * cos(angle)
  
  return -force

func destroy():
  if is_instance_valid(self):
    emit_signal("destroyed", position, rotation)
    if explosion:
      get_tree().root.add_child(explosion)
      explosion.global_position = global_position
      explosion.action()
    queue_free()
