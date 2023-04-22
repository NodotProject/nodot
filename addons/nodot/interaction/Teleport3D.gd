## Teleport3D node
class_name Teleport3D extends Area3D

@export_category("Nodes")
## Target node for copy the coords
@export_node_path("Node3D") var Target
## Player node or other objective to teleport
@export_node_path("CharacterBody3D") var Player

@export_category("Size collision")
## Size of collision area
@export var size = Vector3(3.372, 3.821, 1)

## Get position of "Player" 
@onready var position_player = get_node(Player)
## Get position of "Target"
@onready var position_target = get_node(Target)

## Collision Shape
var node_collision : CollisionShape3D

## Check variable for telepor 
var can_teleport = false

func _enter_tree():
	# add collision to scene
	node_collision = CollisionShape3D.new()
	node_collision.name = "CollisioArea"
	add_child(node_collision)
	
	# Create a CollisionShape
	var CollNode = $CollisioArea
	# Create a Shape for "CollisioArea"
	var Shape = BoxShape3D.new()
	
	#Add size to collision and add the shape to "CollisioArea"
	Shape.size = size
	node_collision.shape = Shape
	
	# Connect signal of "Area3D" to "Teleport3D"
	self.connect("body_entered", body_entered)
	self.connect("body_exited", body_exited)


func _process(delta: float) -> void:
	# Get position of target to teleport
	var target_positon = Vector3(position_target.position.x, position_target.position.y, position_target.position.z)
	
	if can_teleport:
		position_player.position = target_positon

## When "player" entered to "Teleport3D"
func body_entered(body):
	if body == position_player:
		can_teleport = true

## When "player" exited to "Teleport3D"
func body_exited(body):
	if body == position_player:
		can_teleport = false
