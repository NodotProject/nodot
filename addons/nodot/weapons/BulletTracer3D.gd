## Credit: Majikayo Games - https://www.youtube.com/watch?v=vWHHXq8NAYw
## A 3D bullet tracer effect that can be attached to a weapon.
class_name BulletTracer3D extends Nodot3D

@export var enabled: bool = true
## The hitscan3d to trigger the effect
@export var hitscan: HitScan3D

var tracer_scene: PackedScene = load("res://addons/nodot/scenes/weapons/tracer.tscn")

func _ready():
	hitscan.target_hit.connect(action)

func action(target_hit: HitTarget):
	var tracer_mesh: Node3D = tracer_scene.instantiate()
	tracer_mesh.target_position = target_hit.collision_point
	get_tree().root.add_child(tracer_mesh)
	tracer_mesh.global_position = global_position
	tracer_mesh.look_at(tracer_mesh.target_position)
