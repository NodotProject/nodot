## Teleport3D node
class_name Teleport3D extends Area3D

@export_category("Nodes")
## Target node for copy the coords
@export_node_path("Node3D") var Target
## Player node or other objective to teleport
@export_node_path("CharacterBody3D") var Player

@export_category("Others Variables")
## Size of collision area
@export var size = Vector3(3.372, 3.821, 1)
## Time to teleport (in seconds, and this variable is optional)
@export var time_teleport : int = 0

## Get position of "Player" 
@onready var position_player = get_node(Player)
## Get position of "Target"
@onready var position_target = get_node(Target)

## Collision Shape
var node_collision : CollisionShape3D
## Timer node
var node_time : Timer

## Check variable if "Player" is in "area"
var can_teleport_area = false
## Check variable, if "Player" wait a time
var can_teleport_time = false

func _enter_tree():
	# add collision to scene
	node_collision = CollisionShape3D.new()
	node_collision.name = "CollisioArea"
	add_child(node_collision)
	
	# Create a Shape for "CollisioArea"
	var Shape = BoxShape3D.new()
	
	# Add size to collision and add the shape to "CollisioArea"
	Shape.size = size
	node_collision.shape = Shape
	
	# optional process to create a node_timer
	if time_teleport == 0:
		pass
	else: 
		node_time = Timer.new()
		node_time.name = "TimerFreeze"
		add_child(node_time)
		$TimerFreeze.wait_time = time_teleport
		$TimerFreeze.connect("timeout", self.timer_out)

	# Connect signal of "Area3D" to "Teleport3D"
	self.connect("body_entered", body_entered)
	self.connect("body_exited", body_exited)

func _process(_delta) -> void:
	# Get position of target to teleport
	var target_positon = Vector3(position_target.position.x, position_target.position.y, position_target.position.z)
	
	if can_teleport_area and can_teleport_time:
		position_player.position = target_positon

## When "player" entered to "Teleport3D"
func body_entered(body):
	if body == position_player:
		can_teleport_area = true
		
		if time_teleport == 0:
			can_teleport_time = true
		else:
			$TimerFreeze.start()

## When "player" exited to "Teleport3D"
func body_exited(body):
	if body == position_player:
		can_teleport_area = false
		
		if time_teleport == 0:
			can_teleport_time = false
		else:
			can_teleport_time = false
			$TimerFreeze.wait_time = time_teleport

## Emitted when time end
func timer_out():
	can_teleport_time = true
