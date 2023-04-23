##  Teleport3D is an Area3D which, when touched, teleports the collider to another location either instantly or after a defined time
class_name Teleport3D extends Area3D

@export_category("Nodes")
##  Target node for copy the coords
@export_node_path("Node3D") var target
##  Reference a node to teleport by target
@export_node_path("CharacterBody3D") var player

@export_category("Others Variables")
##  Size of collision area
@export var size = Vector3(3.372, 3.821, 1)
##  Time to teleport (in seconds, and this variable is optional)
@export var time_teleport : int = 0

##  Get position of "Player" 
@onready var node_player = get_node(player)
##  Get position of "Target"
@onready var position_target = get_node(target)

##  Collision Shape
var node_collision = CollisionShape3D.new()
##  Timer node
var node_time = Timer.new()

##  Check variable if "Player" is in "area"
var can_teleport_area = false
##  Check variable, if "Player" wait a time
var can_teleport_time = false

func _ready():
	##  add collision to scene
	node_collision.name = "CollisioArea"
	
	##  Procces to select automatic or manully a shape
	var shape
	var check_num_collision = 0
	
	##  Take first node and copy the shape, erase anothers nodes (automatic).
	for child in get_children():
		if child is CollisionShape3D:
			check_num_collision += 1
			if check_num_collision == 1:
				##  check if "child" have "shape"
				if child.shape != null:
					child.name = "CollisioArea"
					shape = child.shape
					node_collision.shape = shape
			else:
				child.free()
	
	##  check if shape have a form, if not have, create one (manully)
	if shape == null:
		shape = BoxShape3D.new()
		##  Add size to collision and add the shape to "CollisioArea"
		shape.size = size
		node_collision.shape = shape
		
		##  check if in the scene exist another collisionshape
		for child in get_children():
			if child is CollisionShape3D:
				child.free()
		
		add_child(node_collision)
	
	##  optional process to create a node_timer
	if time_teleport != 0:
		node_time.name = "TimerFreeze"
		add_child(node_time)
		$TimerFreeze.wait_time = time_teleport
		$TimerFreeze.one_shot = true
		$TimerFreeze.connect("timeout", timer_out)

	##  Connect signal of "Area3D" to "Teleport3D"
	connect("body_entered", body_entered)
	connect("body_exited", body_exited)

func _process(_delta):
	if can_teleport_area and can_teleport_time:
		node_player.global_position = position_target.global_position
		can_teleport_area = false
		can_teleport_time = false

##  When "player" entered to "Teleport3D"
func body_entered(body):
	if body == node_player:
		can_teleport_area = true
		
		if time_teleport == 0:
			can_teleport_time = true
		else:
			$TimerFreeze.start()
		
		##  Get position of target to teleport

##  When "player" exited to "Teleport3D"
func body_exited(_body):
	if time_teleport != 0:
		$TimerFreeze.wait_time = time_teleport

##  Emitted when time end
func timer_out():
	can_teleport_time = true
